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

My terraform script for the EKS cluster provisioning can be found in the [terraform directory](./terraform/)

========> bp 2

I broke down my code into several files for readability and maintainability, it makes the code easier to read and maintain when all scripts that fall into the same group are found in the same place.

The scripts will create the VPC we will use for the EKS cluster and every other networking resources as well provision the EKS cluster for us.

As you can see, when I run the `terraform plan` command it lets me know the resources and the the number of resources it is about to create.

(image 3)

# Create Policy and Role for Route53 to Assume in the ClusterIssuer Process

While writing the configuration to spin up my VPC and other networking resources as well as my EKS I also added configuration to configure IAM roles and policies for Route 53 with cert-manager.

I created an IAM role with a trust policy that specifies the OIDC provider and conditions for when the role can be assumed based on the service account and namespace.

The ClusterIssuer will need these credentials for the certificate issuing process and as a safe way to handle my secrets I will use IAM roles associated with Kubernetes service accounts to manage access to AWS services securely. This is why it is necessary to create this policy and role for Route53 and I did it using terraform.

You can find the script to create the role [here](./terraform/route53-role-policy.tf)

========> bp 3

# Create EKS Resources

I provisioned my EKS cluster at this point.

========> bp 4

The screenshots below show a successful deployment of the EKS cluster.

#### **Terraform CLI Showing the Successful Deployment of the Resources**

(image 4)

#### **AWS Console Showing the EKS Cluster**

(image 5)

#### **AWS Console Showing the VPC Deployed Along with the EKS Cluster**

(image 6)

# Set Environment Variables

My setup is in such a way that I will build the EKS cluster first, then using the outputs from that deployment I will set the environment variables for my next terraform build tio create my ingress resources and and SSL certificate.

I will also export my terraform output values as environment variables to use with kubectl and other configurations. This will aid to make the whole process more automated reducing the manual configurations.

I wrote different scripts to do this, find the [scripts here](./scripts), the first script will create the terraform variables that I will use to run my next deployment, find it [here](./scripts/1-setTFvars.sh)

========> bp 5

The new script generated from this script is not committed to version control as it contains some sensitive values.

# Configure HTTPS Using Let’s Encrypt

Before I provision my EKS cluster and deploy my application I decided to go ahead and configure HTTPS using Let's Encrypt. I did this using terraform as well, using the Kubernetes provider and the kubectl provider.

You can find the terraform scripts for this deployment in the [K8s-terraform directory here](./k8s-terraform/)

===============> bp 7

### Create Kubernetes Service Account for the Cert Manager to use

Earlier, while writing my EKS cluster configuration, I added a configuration to create an IAM role for service account (IRSA) so now the first thing I did here was to create the namespace for cert-manager and also create a service account and annotate it with the IAM role.

==============> bp 8

### Configure Ingress Controller

Before creating the cert-manager resource I configured my ingress controller, it's crucial to ensure that your Ingress controller is deployed and running before you create Ingress resources that it will manage.

You can find the configuration of my ingress controller [here](./k8s-terraform/ingress.tf). I deployed this using helm, using the `helm_release` resource in terraform.

===============> bp 14

### Configure Cert-Manager

After configuring the ingress controller, the next thing to do is to configure the cert-manager, I did this also using helm. Find the configuration [here](./k8s-terraform/cert-manager.tf)

=============> bp 15

### RBAC

In order to allow cert-manager to issue a token using your ServiceAccount you must deploy some RBAC to the cluster. Find my code [here](./k8s-terraform/role-roleBinding.tf)

=============> bp 16

### Configure ClusterIssuer

Next I configured the ClusterIssuer manifest file with the `kubectl_manifest` resource from the kubectl provider so that terraform can adequately use it in the certificate issuing process. I opted to use the DNS01 resolver instead of HTTP01

I had wanted to use the `kubernetes_manifest` resource from the kubernetes provider even though I knew would require two stages of the `terraform apply` command however from research I was able to discover that the kubectl's `kubectl_manifest` resource handles manifest files better and allows for a single stage run of the `terraform apply` command

Find the [ClusterIssuer configuration file here](./k8s-terraform/cluster-issuer.tf)

===============> bp 9

### Create Certificate

To create the certificate we will use the `kubectl_manifest` resource to define our manifest file for the certificate creation. You can find my certificate manifest file [here](./k8s-terraform/certificate.tf)

==============> 10

### Configure Ingress

Now that we have configured Cert Manager, Cluster Issuer and Certificate we need to setup our Ingress Controller and Ingress resource that will allow us access to our application, we will also be doing this using our terraform configuration.

Find my [ingress configuration here](./k8s-terraform/ingress.tf)

=================> 11

### Connect Domain to LoadBalancer

The Ingress-controller will create a LoadBalancer that give us an external IP to us in access our resources and we will point our domain to.

I used this LoadBalancer to create an A record with my domain name and now I will be able to access the sock shop application from my domain.

=================> 12

# Connect Kubectl to EKS Cluster

Once my EKS Cluster is fully provisioned on AWS and I have deployed my ingress and certificate resources in the cluster, the next thing to do is to connect kubectl to the cluster so that I can use kubectl right from my local machine to define, create, update and delete my Kubernetes resources as necessary.

The command to do this is shown below:

```sh
aws eks update-kubeconfig --region <region-code> --name <cluster name>
```

However since this is an imperative command I decided to create a script out of it for easier automation and reproduction of the process. Find the script [here](./scripts/3-connect-kubectl.sh)

There will be more scripts as I go along the project, all my scripts can be found in the [`scripts` directory](./scripts/)

==============> bp 6

# Deploy Application

Previously I had wanted to deploy my application using terraform but it seems like an overkill seeing as we using a CI/CD pipeline to automate the whole flow eventually resolved to use kubectl to deploy the application to the cluster. 

I retrieved the [complete-demo.yaml application file](./app/complete-demo.yaml) from the project repo which is a combination of all the manifests for all the microservices required for our application to be up and running.

=================> bp 13

# Monitoring and Logging and Alerting

To setup prometheus, grafana, alertmanager and Kibana for monitoring, logging and alerting i retrieved the respective manifest files from the project repo and then created two additional ingresses that will exist in the monitoring namespace and the kube-system namespace so that I can access these dashboards from my subdomain.

The code for these ingresses can be found in my [ingress file](./k8s-terraform/ingress.tf) as well.

After creating the ingress, I then created route53 records for them.

==================> bp 17