pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['create', 'destroy'], description: 'Choose action to perform')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
        vpcname = credentials('vpcname')
        cluster_name = credentials('cluster_name')
        namespace = credentials('namespace')
        service_account_name = credentials('service_account_name')
        email = credentials('email')
        domain = credentials('domain')
        slack_hook_url = credentials('slack_hook_url')
    }
    stages {
        stage('Checkout SCM'){
            steps{
                script{
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ChigozieCO/altschool-capstone-project.git']])
                }
            }
        }
        stage('Initialize Terraform'){
            steps{
                dir('terraform'){
                    sh 'terraform init -upgrade'
                }
            }
        }
        stage('Create EKS Cluster'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('terraform'){
                    sh """
                    terraform apply \
                    -var='vpcname=${vpcname}' \
                    -var='cluster_name=${cluster_name}' \
                    -var='namespace=${namespace}' \
                    -var='service_account_name=${service_account_name}' \
                    -var='email=${email}' \
                    -var='domain=${domain}' \
                    --auto-approve
                    """
                }
            }
        }
        stage('Initialize New Terraform Config'){
            steps{
                dir('k8s-terraform'){
                    sh 'terraform init'
                }
            }
        }
        stage('Run script to set K8s Terraform Evinornment Variables then Build Certificate and Ingress resources'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('k8s-terraform'){
                    sh """
                    source ../scripts/1-setTFvars.sh
                    terraform apply \
                    -var='slack_hook_url=${slack_hook_url}' \
                    --auto-approve
                    """
                }
            }
        }
        stage('Set env vars and Connect kubectl to cluster'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('scripts'){
                    sh """
                    source ./2-setEnvVars.sh
                    source ./3-connect-kubectl.sh
                    """
                }
            }
        }
        stage('Deploy Application in EKS Cluster'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('app'){
                    sh 'kubectl apply -f ./complete-demo.yaml'
                }
            }
        }
        stage('Deploy Alermanager'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('alerting'){
                    sh 'kubectl apply -f .'
                }
            }
        }
        stage('Deploy Prometheus and Grafana'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('monitoring'){
                    sh 'kubectl apply -f .'
                }
            }
        }
        stage('Deploy Elasticsearch, Fluentd and Kibana'){
            when {
                expression { params.ACTION == 'create' }
            }
            steps{
                dir('logging'){
                    sh 'kubectl apply -f .'
                }
            }
        }
        stage('Destroy K8s Terraform Resources') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('k8s-terraform'){
                    sh """
                    source ../scripts/1-setTFvars.sh
                    terraform destroy \
                    -var='slack_hook_url=${slack_hook_url}' \
                    --auto-approve
                    """
                }
            }
        }
        stage('Clear Cert-Manager Resources') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('k8-terraform'){
                    sh """
                    kubectl delete crd certificaterequests.cert-manager.io \
                    certificates.cert-manager.io \
                    challenges.acme.cert-manager.io \
                    clusterissuers.cert-manager.io \
                    issuers.cert-manager.io \
                    orders.acme.cert-manager.io
                    """
                }
            }
        }
        stage('Destroy EKS Cluster') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('terraform') {
                    sh """
                    terraform destroy \
                    -var='vpcname=${vpcname}' \
                    -var='cluster_name=${cluster_name}' \
                    -var='namespace=${namespace}' \
                    -var='service_account_name=${service_account_name}' \
                    -var='email=${email}' \
                    -var='domain=${domain}' \
                    --auto-approve
                    """
                }
            }
        }
        
    }
}