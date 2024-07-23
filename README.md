This project is about deploying a microservices-based application using automated tools to ensure quick, reliable, and secure deployment on Kubernetes. By focusing on Infrastructure as Code, you'll create a reproducible and maintainable deployment process that leverages modern DevOps practices and tools.

For a detailed breakdown of what this project is trying to achieve check out [the requirements here](./Requirements.md)

# Prerequisites

- An AWS Account
- AWS CLI installed and configured
- Terraform installed
- Kubectl installed
- Helm
- A custom domain

# Set Up AWS Hosted Zone and Custom Domain

The first thing to do to begin this project is to create a hosted zone and configure our custom domain.

I have already purchased a custom domain [projectchigozie.me](http://projectchigozie.me/) and so I will create an AWS hosted zone to host this domain. I won't be using terraform to create this hosted zone because this step still requires manually configuration to add the nameservers to the domain.

========> bp 1

Once the hosted zone is created, we then retrieve the namespaces from the created hosted zone and use it to replace those already in our custom domain.

The specific steps to take to do this will vary depending on your domain name registrar but it's pretty much very easy across board.

(image 2)

# Provision AWS EKS Cluster with Terraform

For automation and to speed up the process, we will write a terraform script to deploy an EKS cluster and configure the necessary VPC, subnets, security groups and IAM roles.

We won't be reinventing the wheel here as there are a lot of terraform modules out there that do just exactly what we are trying to do. I will be using the official terraform/aws vpc and eks modules.

My terraform script can be found in the [terraform directory](./terraform/)

========> bp 2

