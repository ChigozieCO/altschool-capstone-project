# Project Requirements & Overview

This project is about deploying a microservices-based application using automated tools to ensure quick, reliable, and secure deployment on Kubernetes. By focusing on Infrastructure as Code, you'll create a reproducible and maintainable deployment process that leverages modern DevOps practices and tools.

Your main task is to set up the Socks Shop application, a demonstration of a microservices architecture, available on [GitHub](https://github.com/microservices-demo/microservices-demo/tree/master). You'll be using tools and technologies that automate the setup process, ensuring that the application can be deployed quickly and consistently.

# Task Instructions

- **Use Infrastructure as Code**: Automate the deployment process. This means all the steps to get the application running on Kubernetes should be scripted and easily executable.

- **Focus on Clarity and Maintenance**: Your deployment scripts and configurations should be easy to understand and maintain. Think of someone else (or yourself in the future) needing to update or replicate your setup.

- **Security and HTTPS**: Make sure the application is accessible over HTTPS by using Let’s Encrypt for certificates. Consider implementing network security measures and use Ansible Vault for handling sensitive information securely.

## Key Evaluation Criteria:

- **Deployment Pipeline**: How the application moves from code to a running environment.

- **Monitoring and Alerts**: Implement Prometheus for monitoring and set up Alertmanager for alerts.
Logging: Ensure the application's operations can be tracked and analyzed through logs.

- **Tools for Setup**: Use either Ansible or Terraform for managing configurations. Choose an Infrastructure as a Service (IaaS) provider where your Kubernetes cluster will live.

# Extra Project Requirements for Bonus Points

- **HTTPS Requirement**: The application must be securely accessible over HTTPS.

- **Infrastructure Security**: Enhance security by setting up network perimeter security rules.
Sensitive Information: Use Ansible Vault to encrypt sensitive data, adding an extra layer of security.