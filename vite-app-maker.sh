#!/bin/bash

# Prompt user for app name
read -p "Enter the name of your vite app: " app_name

# Step 1: Create Remix app using npx
npx create-vite "$app_name"
cd "$app_name"
code .
npm i
npm install express cors body-parser dotenv typescript @types/express @types/node ts-node --save-dev 

EOF

# SETUP EXPRESS SERVER
cat << EOF > server.ts
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World from Express server!");
});

export default app;

EOF

# start server file
cat <<EOF > start.js
import app from "./server";

const port = process.env.PORT || 4001;

app.listen(port, () => {
  console.log(\`Example app listening on port \${port}\`);
});
EOF

# Output success message
echo "Generated server.js file:"
cat server.js

# node server.js & 

# SETUP DB
cat << EOF > docker-compose.yml
version: "3.9"
services:
  testfunkydb:
    image: postgres:13
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      DB_NAME: postgres
    command: -c fsync=off -c full_page_writes=off -c synchronous_commit=off -c max_connections=500
    ports:
      - 10004:5432
EOF

docker-compose up -d

npx tsc --init
npm install prisma --save-dev
npx prisma init --datasource-provider postgresql
touch script.ts

cat << 'EOF' > prisma/schema.prisma
// This is your Prisma schema file

// Define the User model
model User {
  id       Int      @id @default(autoincrement())
  email    String   @unique
  name     String?
  posts    Post[]
}

// Define the Post model
model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
}
EOF

# Step 6: Add Prisma script to script.ts
cat << EOF > script.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  const user = await prisma.user.create({
    data: {
      name: 'Alice',
      email: 'alice@prisma.io',
    },
  })
  console.log(user)
}

main()
  .then(async () => {
    await prisma.\$disconnect();
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.\$disconnect();
    process.exit(1)
  })
EOF

DEFAULT_DATABASE_URL="postgresql://username:password@localhost:5432/mydatabase"

# Create or overwrite .env.local file
cat << EOF > .env.local
DATABASE_URL=${DATABASE_URL:-$DEFAULT_DATABASE_URL}
# Add other environment variables here if needed
EOF

# Define the updated scripts object as a variable
UPDATED_SCRIPTS='
{
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview",
    "test:run": "npx vitest run",
    "test:db:up": "docker compose -f docker-compose-test.yml up -d",
    "test:db:down": "docker compose -f docker-compose-test.yml down",
    "db:migrate": "npx prisma migrate dev",
    "test": "npm run test:db:up && npx dotenv-cli -e .env.test -- npm run db:migrate && npx dotenv-cli -e .env.test -- npm run test:run && npm run test:db:down"
}
'

# Use jq to update only the scripts section in package.json
jq '.scripts |= '"$UPDATED_SCRIPTS"'' package.json > temp.json && mv temp.json package.json

# Verify the update
echo "Updated package.json with new scripts:"
cat package.json



# echo "✨ Successfully set up your app with Vite!"