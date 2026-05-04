#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -q -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -q -c"
fi

# clear tables
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

# read csv
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then

    # -------------------------
    # WINNER TEAM (safe insert)
    # -------------------------
    WINNER_ID=$($PSQL "INSERT INTO teams(name)
    SELECT '$WINNER'
    WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name='$WINNER')
    RETURNING team_id")

    if [[ -z $WINNER_ID ]]
    then
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # -------------------------
    # OPPONENT TEAM (safe insert)
    # -------------------------
    OPPONENT_ID=$($PSQL "INSERT INTO teams(name)
    SELECT '$OPPONENT'
    WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name='$OPPONENT')
    RETURNING team_id")

    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # -------------------------
    # INSERT GAME (NO echo, NO capture)
    # -------------------------
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"

  fi
done