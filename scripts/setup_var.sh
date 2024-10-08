#!/bin/bash

# Path to your Laravel .env file
ENV_FILE="/var/www/html/laravel/.env"

# Temporary file to hold the updated .env content
TEMP_ENV_FILE="/var/www/html/laravel/env_example"

# Backup the original .env file
cp $ENV_FILE "$ENV_FILE.bak"

# Iterate through each line in the .env file
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  if [[ -z "$line" || $line == \#* ]]; then
    echo "$line" >> $TEMP_ENV_FILE
    continue
  fi

  # Extract the variable name (before the '=' sign)
  VAR_NAME=$(echo "$line" | cut -d '=' -f 1)

  # Fetch the value from AWS SSM Parameter Store using the variable name
  PARAM_VALUE=$(aws ssm get-parameter \
    --name "$VAR_NAME" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text)

  # If a value is found, replace it in the .env file; otherwise, keep the existing value
  if [[ -n "$PARAM_VALUE" ]]; then
    echo "$VAR_NAME=$PARAM_VALUE" >> $TEMP_ENV_FILE
  else
    echo "$line" >> $TEMP_ENV_FILE
  fi
done < "$ENV_FILE"

# Replace the original .env file with the updated one
mv $TEMP_ENV_FILE $ENV_FILE

echo "Parameters written successfully to $ENV_FILE"
