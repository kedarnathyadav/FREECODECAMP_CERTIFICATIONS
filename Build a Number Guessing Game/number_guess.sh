#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

target=$(( RANDOM % 1000 + 1 ))


user_data=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $user_data ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  ($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  games_played=0
  best_game="N/A"
else
  IFS='|' read games_played best_game <<< "$user_data"
  echo "Welcome back, $USERNAME! You have played $games_played games, and your best game took $best_game guesses."
fi

echo "Guess the secret number between 1 and 1000:"

num_guesses=0

while true; do
    read -p "Enter your guess: " guess
      ((num_guesses++))
    if [[ ! "$guess" =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi
    
    if (( guess < target )); then
        echo "It's lower than that, guess again:"
    elif (( guess > target )); then
        echo "It's higher than that, guess again:"
    else
        echo "You guessed it in $num_guesses tries. The secret number was $target. Nice job!"
        if [[ "$best_game" == "N/A" ]] || (( num_guesses < best_game )); then
            ($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $num_guesses WHERE username='$USERNAME';" > /dev/null)
        else
            ($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME';" > /dev/null)
        fi
        break
    fi
done