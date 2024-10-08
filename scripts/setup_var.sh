#!/bin/sh

# Paths to your Laravel .env and env_example files
ENV_FILE="/var/www/html/laravel/.env"
ENV_EXAMPLE_FILE="/var/www/html/laravel/env_example"

# Temporary file to hold the updated .env content
TEMP_ENV_FILE="/var/www/html/laravel/temp_env"

# Check if the .env file exists, if not, create an empty one
if [ ! -f "$ENV_FILE" ]; then
  echo ".env file not found, creating a new one at $ENV_FILE"
  touch "$ENV_FILE"
fi

# Backup the original .env file
cp "$ENV_FILE" "$ENV_FILE.bak"

# Check if env_example file exists
if [ ! -f "$ENV_EXAMPLE_FILE" ]; then
  echo "Error: env_example file not found at $ENV_EXAMPLE_FILE"
  exit 1
fi

# Iterate through each variable in the env_example file
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments in env_example
  if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
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

  # If a value is found, add it to the .env file
  if [ -n "$PARAM_VALUE" ]; then
    echo "$VAR_NAME=$PARAM_VALUE" >> "$TEMP_ENV_FILE"
  else
    echo "Warning: No value found in SSM for $VAR_NAME, keeping original or adding placeholder"
    echo "$VAR_NAME=" >> "$TEMP_ENV_FILE"
  fi
done < "$ENV_EXAMPLE_FILE"

# Replace the original .env file with the updated one
mv "$TEMP_ENV_FILE" "$ENV_FILE"

echo "Parameters from env_example written successfully to $ENV_FILE"
