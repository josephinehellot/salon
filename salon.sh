#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ SALON APPOINTMENT SCHEDULER ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

# Display available services
echo "Please choose a service from the list below:"
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services;")

#get services
echo "$SERVICE_LIST" | while IFS='|' read SERVICE_ID SERVICE_NAME; 
do
    SERVICE_ID=$(echo "$SERVICE_ID" | sed 's/^[ \t]*//;s/[ \t]*$//')
    SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt user for input
read SERVICE_ID_SELECTED

# Process user input
case $SERVICE_ID_SELECTED in
  1) echo "You selected: CUT";;
  2) echo "You selected: COLOR";;
  3) echo "You selected: PERM";;
  4) echo "You selected: STYLE";;
  *) MAIN_MENU "Invalid selection. Please enter a number between 1 and 4.";;
esac
} 

MAIN_MENU

# Prompt user for phone number
echo "Enter your phone number: "
read CUSTOMER_PHONE

# Check if the phone number already exists in the customers table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [ -z "$CUSTOMER_ID" ]; then
    # If the phone number doesn't exist, prompt for the name and add the customer
    echo "Enter your name: "
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
    # Retrieve the new customer's ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
    # If the phone number exists, retrieve the name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

# Prompt for appointment time
echo "Enter appointment time (e.g., 10:30): "
read SERVICE_TIME

# Insert the appointment into the database
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Retrieve the service name for the confirmation message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

# Output confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
