#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determine input type
# added input validation
# added input validatio
# added input validati
# added input validat

if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE e.atomic_number = $1;")
else
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE e.symbol = '$1' OR e.name = '$1';")
fi

# If not found
if [[ -z $QUERY_RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$QUERY_RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MP BP
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
  done
fi
