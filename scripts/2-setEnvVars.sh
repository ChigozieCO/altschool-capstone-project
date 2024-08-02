#!/usr/bin/env bash

# This script sets environment variables from Terraform outputs for use in connect our kubectl to our cluster. Run this after applying the k8s-terraform configuration.

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

# Generate env.sh file with export commands
echo "$TF_OUTPUT" | jq -r 'to_entries[] | "export " + .key + "=" + (.value.value | tostring)' > "$RUN_FROM/env.sh"
echo "Environment variables export script has been created as env.sh."
echo "Run the 3-connect-kubectl.sh script now to connect Kubectl to your EKS cluster"