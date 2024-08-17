#!/bin/bash

# Define the PSQL command with database details
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to fetch and display element information
fetch_element_info() {
  local input=$1

  # Determine if input is numeric or not
  if [[ $input =~ ^[0-9]+$ ]]; then
    # Input is numeric, so use it as atomic_number
    local query="SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
                 FROM elements e
                 JOIN properties p ON e.atomic_number = p.atomic_number
                 JOIN types t ON p.type_id = t.type_id
                 WHERE e.atomic_number = $input;"
  else
    # Input is a string, so use it as symbol or name
    local query="SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
                 FROM elements e
                 JOIN properties p ON e.atomic_number = p.atomic_number
                 JOIN types t ON p.type_id = t.type_id
                 WHERE e.symbol = '$input' OR e.name = '$input';"
  fi

  # Execute the query and store the result
  result=$($PSQL "$query")

  # Check if the result is empty
  if [[ -z "$result" ]]; then
    echo "I could not find that element in the database."
  else
    # Format and display the result
    IFS="|" read -r atomic_number name symbol atomic_mass melting_point boiling_point type <<< "$result"
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
  fi
}

# Check if the user provided an argument
if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
else
  # Call the function with the user's argument
  fetch_element_info "$1"
fi
