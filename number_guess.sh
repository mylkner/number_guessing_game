#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=user_data -t --no-align -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

while true
do
  echo "Enter your username:"
  read USERNAME

  if [[ ${#USERNAME} -gt 22 || -z $USERNAME ]]
  then
    echo "Invalid username, username must be less than 22 characters and not empty."
  else 
    break
  fi
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

if [[ -z $USER_ID ]]
then 
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM user_games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guess_count) FROM user_games WHERE user_id=$USER_ID")

  if [[ $GAMES_PLAYED == 0 ]]
  then
    echo -e "\nWelcome back, $USERNAME! You have played 0 games."
  else 
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
fi

echo -e "\nGuess the secret number between 1 and 1000:"

COUNT=1
while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
     echo -e "\nThat is not an integer, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    (( COUNT++ ))
    echo -e "\nIt's higher than that, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    (( COUNT++ ))
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nYou guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

    INSERT_GAME_RESULTS=$($PSQL "INSERT INTO user_games(user_id, guess_count) VALUES($USER_ID, $COUNT)")
    break
  fi
done
