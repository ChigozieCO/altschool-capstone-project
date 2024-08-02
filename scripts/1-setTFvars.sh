#!/usr/bin/env bash

# This script sets the Terraform variables from the outputs of the Terraform configuration. Run this script immediately after the first terraform apply that creates the EKS cluster.

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

# Get the Terraform outputs and check if they are non-empty
TF_OUTPUT=$(terraform output -json)

if [ -z "$TF_OUTPUT" ] || [ "$TF_OUTPUT" == "{}" ]; then
  echo "No terraform outputs found or outputs are empty. Please run 'terraform apply' first."
  exit 1
fi

# Generate TFenv.sh file with export commands
echo "$TF_OUTPUT" | jq -r 'to_entries[] | "export TF_VAR_" + .key + "=" + (.value.value | tostring)' > "$RUN_FROM/TFenv.sh"
echo "Terraform variables export script has been created as TFenv.sh."

# Source the TFenv.sh script to export the variables into the current shell
source "$RUN_FROM/TFenv.sh"

echo "Environment variables have been exported and are available for Terraform."