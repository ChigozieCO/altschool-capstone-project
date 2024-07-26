This project is about deploying a microservices-based application using automated tools to ensure quick, reliable, and secure deployment on Kubernetes. By focusing on Infrastructure as Code, you'll create a reproducible and maintainable deployment process that leverages modern DevOps practices and tools.

For a detailed breakdown of what this project is trying to achieve check out [the requirements here](./Requirements.md)

# Prerequisites

- An AWS Account
- AWS CLI installed and configured
- Terraform installed
- Kubectl installed
- Helm
- A custom domain

Here is a brief breakdown how I executed this project, for a more comprehensive and detailed step by step process check out this [walkthrough](=====link to post=====) I wrote.

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

I broke down my code into several files for readability and maintainability, it makes the code easier to read and maintain when all scripts that fall into the same group are found in the same place.

The script will create the VPC we will use for the EKS cluster and every other networking resources as well provision the EKS cluster for us.

As you can see, when I run the `terraform plan` command it lets me know the resources and the the number of resources it is about to create.

(image 3)

# Create Policy and Role for Route53 to Assume in the ClusterIssuer Process

While writing the configuration to spin up my VPC and other networking resources as well as my EKS I also added configuration to configure IAM roles and policies for Route 53 with cert-manager.

I created an IAM role with a trust policy that specifies the OIDC provider and conditions for when the role can be assumed based on the service account and namespace.

The ClusterIssuer will need these credentials for the certificate issuing process and as a safe way to handle my secrets I will use IAM roles associated with Kubernetes service accounts to manage access to AWS services securely. This is why it is necessary to create the this policy and role for Route53 and I did it using terraform.

========> bp 3

You can find the script to create the role [here](./terraform/route53-role-policy.tf)

========> bp 4

# Set Environment Variables

I will export some out my terraform output values as environment variables to use with kubectl. This will aid to make the who process more automated reducing the manual configurations.

I wrote a script to do this, find the [script here](./scripts/exp-tf-env-vars.sh)

========> bp 5

# Connect Kubectl to EKS Cluster

Once my EKS Cluster is fully provisioned on AWS, the next thing to do is to connect Kubectl to the cluster so that I can use kubectl right from local machine to define, create, update and delete my Kubernetes resources as necessary.

The command to do this is shown below:

```sh
aws eks update-kubeconfig --region <region-code> --name <cluster name>
```

However since this is an imperative command I decided to create a script out of it for easier automation and reproduction of the process. Find the script [here](./scripts/connect-kubectl.sh)

There will be more scripts as I go along the project, all my scripts can be found in the [`scripts` directory](./scripts/)

