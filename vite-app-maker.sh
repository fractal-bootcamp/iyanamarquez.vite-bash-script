#!/bin/bash

# Prompt user for app name
read -p "Enter the name of your vite app: " app_name

# Step 1: Create Remix app using npx
npx create-vite "$app_name"
cd "$app_name"
code .
npm i
npm install express cors body-parser dotenv typescript @types/express @types/node ts-node --save-dev 

npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
cat << 'EOF' > tailwind.config.js
/** @type {import('tailwindcss').Config} */
const withMT = require("@material-tailwind/react/utils/withMT");

module.exports = withMT({
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
});
EOF

# Step 4: Add Tailwind CSS directives to index.css
cat << 'EOF' | tee -a src/index.css > /dev/null
@tailwind base;
@tailwind components;
@tailwind utilities;
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

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(\`Server is running on http://localhost:\${port}\`);
});
EOF

# node server.js & 

# SETUP DB
cat << EOF > docker-compose.yml
version: "3.9"
services:
  db_name:
    image: postgres:13
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    command: >
      -c fsync=off 
      -c full_page_writes=off 
      -c synchronous_commit=off 
      -c max_connections=500
    ports:
      - "10004:5432"

  my-vite-app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db_name

  express-server:
    build: .
    command: node server.js
    ports:
      - "3001:3001"
    depends_on:
      - db_name
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
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })
EOF

DEFAULT_DATABASE_URL="postgresql://username:password@localhost:5432/mydatabase"

# Create or overwrite .env.local file
cat << EOF > .env.local
DATABASE_URL=${DATABASE_URL:-$DEFAULT_DATABASE_URL}
# Add other environment variables here if needed
EOF



# echo "✨ Successfully set up your app with Vite!"