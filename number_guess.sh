#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

# ask for username 
echo "Enter your username:"
read USERNAME

# get user_id
USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username = '$USERNAME'")

# check if USERNAME exists
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # save username
  SAVE_RES=$($PSQL "INSERT INTO usernames (username) VALUES ('$USERNAME')")
  # get user_id
  USER_ID=$($PSQL "SELECT user_id FROM usernames WHERE username = '$USERNAME'")

else
  GAME_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guess_number) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# set up random number between 1 and 1000
RNUMBER=$((RANDOM % 1000 + 1))

# guess counter
COUNTER=0

# initial guess
echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
COUNTER=$((COUNTER+1))
while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESSED_NUMBER
  COUNTER=$((COUNTER+1))
done

while [[ $GUESSED_NUMBER -ne $RNUMBER ]]
do

  # in case guess too low
  if [[ $GUESSED_NUMBER -lt $RNUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESSED_NUMBER
    COUNTER=$((COUNTER+1))
    while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESSED_NUMBER
      COUNTER=$((COUNTER+1))
    done
  fi

  # in case guess too high
  if [[ $GUESSED_NUMBER -gt $RNUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESSED_NUMBER
    COUNTER=$((COUNTER+1))
    while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read GUESSED_NUMBER
      COUNTER=$((COUNTER+1))
    done
  fi

done

# in case guess correctly
echo "You guessed it in $COUNTER tries. The secret number was $RNUMBER. Nice job!"

# save result
SAVE_RES=$($PSQL "INSERT INTO games (user_id, guess_number, won) VALUES ($USER_ID, $COUNTER, true)")
