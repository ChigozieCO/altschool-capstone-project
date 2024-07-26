#!/usr/bin/env bash

# Check that AWS CLI is installed, if it isn't stop the script
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install AWS CLI and try again."
  exit 1
fi

# Check that the kubectl is configured, if it isn't stop the script
if ! command -v kubectl &> /dev/null; then
  echo "kubectl is not installed. Please install kubectl and try again."
  exit 1
fi

# Connect kubectl to your EKS cluster
echo "Connecting kubectl to your EKS cluster......"
aws eks update-kubeconfig --region $region --name $cluster_name