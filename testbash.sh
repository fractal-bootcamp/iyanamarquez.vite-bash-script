#!/bin/bash

# Define your ASCII art animations in an array
ASCII_ARTS=(
'
  _____ _             _____                      
 / ____| |           |  __ \                     
| |    | | ___  _ __ | |__) |___ _ __   ___ _ __ 
| |    | |/ _ \|  _ \|  _  // _ \  _ \ / _ \  __|
| |____| | (_) | | | | | \ \  __/ | | |  __/ |   
 \_____|_|\___/|_| |_|_|  \_\___|_| |_|\___|_|   
'
'
  ____  _              _     ____              
 / ___|| |_ __ _ _ __ | | __/ ___| _   _ _ __  
 \___ \| __/ _` |  _ \| |/ /\___ \| | | |  _ \ 
  ___) | || (_| | |_) |   <  ___) | |_| | | | |
 |____/ \__\__,_| .__/|_|\_\|____/ \__,_|_| |_|
                |_|                            
'
)

# Number of times to repeat each ASCII art animation
REPEATS=5

# Function to alternate between ASCII arts and clear terminal before each print
alternate_ascii_arts() {
    local arts=("$@")  # All arguments passed to the function are stored in array 'arts'
    local num_arts="${#arts[@]}"  # Number of ASCII arts in the array
    
    for (( i=0; i < REPEATS; i++ )); do
        for (( j=0; j < num_arts; j++ )); do
            # Clear terminal screen
            clear
            # Print ASCII art
            echo "${arts[j]}"
            # Sleep for 0.5 seconds (adjust as needed for animation speed)
            sleep 0.5
        done
    done
}

# Call function to alternate between ASCII arts
alternate_ascii_arts "${ASCII_ARTS[@]}"
