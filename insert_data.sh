#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~ SETTING STUFF UP ~~\n"
$PSQL "TRUNCATE TABLE games, teams" >&1 >/dev/null
echo -e "~~ THERE YOU GO! ~~\n"
csv_file="./games.csv"
echo -e " STARTING INSERTION:\n"

exec 3< "$csv_file"
while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [ "$YEAR" != 'year' ];
then
if [ $($PSQL "SELECT COUNT(*) FROM teams WHERE name='$WINNER'") -le 0 ];
then
$PSQL "INSERT INTO teams(name) VALUES('$WINNER')" 2>&1 >/dev/null
fi
if [ $($PSQL "SELECT COUNT(*) FROM teams WHERE name='$OPPONENT'") -le 0 ];
then
$PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')" 2>&1 >/dev/null
fi

WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
echo "Inserting Game for $WINNER & $OPPONENT, year $YEAR"
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)" 2>&1 >/dev/null
fi
done <&3
exec 3<&-