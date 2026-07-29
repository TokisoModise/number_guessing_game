#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

# Look up the user by username
USER_ROW=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ROW ]]
then
  # New user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, null)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=""
else
  USER_ID=$(echo $USER_ROW | cut -d "|" -f 1)
  GAMES_PLAYED=$(echo $USER_ROW | cut -d "|" -f 2)
  BEST_GAME=$(echo $USER_ROW | cut -d "|" -f 3)
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( ( RANDOM % 1000 ) + 1 ))
GUESS_COUNT=0

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

while true
do
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read GUESS
  else
    echo -e "\nIt's lower than that, guess again:"
    read GUESS
  fi
done

NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ -z $BEST_GAME || $BEST_GAME == "" ]]
then
  NEW_BEST_GAME=$GUESS_COUNT
elif [[ $GUESS_COUNT -lt $BEST_GAME ]]
then
  NEW_BEST_GAME=$GUESS_COUNT
else
  NEW_BEST_GAME=$BEST_GAME
fi

UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE user_id=$USER_ID")

echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
# Random number guessing game
# Database connection setup

