#!/usr/bin/env bash

# Define the directory containing your Terraform configuration files by walking backwards to the project root path so that this script works from whatever directory it is run.
ABS_PATH=$(readlink -f "$0")
DIR_PATH=$(dirname "$ABS_PATH")
PROJECT_PATH=$(dirname "$DIR_PATH")
TF_PATH="$PROJECT_PATH/terraform"

# Change to the Terraform directory
cd "$TF_PATH" || { echo "Failed to change directory to $TF_PATH"; exit 1; }

# Check if there are any outputs defined
output_check=$(terraform output | length > 0)

if [ -z "$output_check" ]; then
  echo "No outputs found in Terraform state. Please ensure 'terraform apply' has been run successfully."
  exit 1
fi

# # Check if there are any outputs defined
# output_exists=$(terraform output -json | jq -r 'keys | length > 0')

# if [ "$output_exists" != "true" ]; then
#   echo "No outputs found in Terraform state. Please ensure 'terraform apply' has been run successfully."
#   exit 1
# fi

# # Extract the outputs from Terraform
# outputs=$(terraform output -json)

# # Check if there are any outputs
# if [ -z "$outputs" ] || [ "$outputs" == "{}" ]; then
#   echo "No outputs found in Terraform state. Please ensure 'terraform apply' has been run successfully."
#   exit 1
# fi

# # Loop through the JSON and set environment variables
# # jq is used to parse the JSON output, `jq -r 'keys[]'` will extract all keys (output names) from the JSON.
# for key in $(echo $outputs | jq -r 'keys[]'); do
#   # Check if the output is sensitive (contains the 'sensitive' key)
#   sensitive=$(echo $outputs | jq -r --arg key "$key" '.[$key].sensitive')
#   # If the output is sensitive, retrieve its value using `terraform output -raw`
#   if [ "$sensitive" == "true" ]; then
#     value=$(terraform output -raw $key)
#   # Otherwise, retrieve its value using `jq -r '.[$key].value'`
#   else
#     value=$(echo $outputs | jq -r --arg key "$key" '.[$key].value')
#   fi

#   # Set each output as an environment variable.
#   export $key=$value
#   echo "Exported $key=$value"
# done