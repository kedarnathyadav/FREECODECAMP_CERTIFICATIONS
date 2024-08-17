#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# Display services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo -e "\nHere are the services we offer:"
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
  echo -e "\nInvalid service. Please try again."
  exec $0
fi

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # New customer, prompt for name
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME

INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi


CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")


echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")


echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."