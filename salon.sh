#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CREATE_APPOINTMENT() {
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
  SELECTED_SERVICE_FORM=$(echo $SELECTED_SERVICE | sed 's/\s//g' -E)
  CUSTOMER_NAME_FORM=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $SELECTED_SERVICE_FORM, $CUSTOMER_NAME_FORM?"
  read SERVICE_TIME
  INSERTED_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SELECTED_SERVICE_FORM at $SERVICE_TIME, $CUSTOMER_NAME_FORM."
  return
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
    return
  fi
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_AVAILABLE ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
    return
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_CUST ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED_CUST_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    #SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
   # CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
   # SELECTED_SERVICE_FORM=$(echo $SELECTED_SERVICE | sed 's/\s//g' -E)
    #CUSTOMER_NAME_FORM=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
    #echo -e "\nWhat time would you like your $SELECTED_SERVICE_FORM, $CUSTOMER_NAME_FORM?"
    #read SERVICE_TIME
    CREATE_APPOINTMENT
  else
    CREATE_APPOINTMENT
   # echo -e "\nI have put you down for a $SELECTED_SERVICE_FORM at $SERVICE_TIME, $CUSTOMER_NAME_FORM."
  fi
}

MAIN_MENU

