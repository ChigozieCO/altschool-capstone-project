#!/usr/bin/env bash

# Set the path where the script is being run from
RUN_FROM=$(pwd)

# Define the directory containing your Terraform configuration files by walking backwards to the project root path so that this script works from whatever directory it is run.
ABS_PATH=$(readlink -f "$0")
DIR_PATH=$(dirname "$ABS_PATH")
PROJECT_PATH=$(dirname "$DIR_PATH")
TF_PATH="$PROJECT_PATH/terraform"

# Change to the Terraform directory
cd "$TF_PATH" || { echo "Failed to change directory to $TF_PATH"; exit 1; }

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Please install jq and try again."
  return 1
fi

# Check if there are terraform outputs and generate env.sh file with export commands
if terraform output -json | jq -r 'to_entries[] | .key + "=" + (.value.value | tostring)' > "$RUN_FROM/env.sh"; then
  echo "Environment variables export script has been created as env.sh."
else
  echo "No terraform outputs found. Please run 'terraform apply' first."
  exit 1
fi