# Ilios Golang API

Part one of the final project for the Ilios LLC internship program.

This API returns AWS metadata for the currently configured AWS account using the AWS SDK v2 for Go.

Each endpoint will return associated data for VPCs (/vpcs), EC2 instances (/ec2s), or EKS clusters (/eks) using their respective paths, as well as a health check using /health.

## Deployment Guide

This application requires a two-phase deployment process:

1. First, deploy the base infrastructure (VPC, EKS cluster, etc.)
2. Then, deploy the API application itself

### Prerequisites

- **AWS Account**: You need an AWS account with administrator access
- **AWS CLI**: [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) with appropriate credentials
- **Terraform**: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version 1.0.0 or later)
- **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **GitHub Account**: You'll need a GitHub account to fork this repository and run the workflows
- **Git**: [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Step 1: Deploy Base Infrastructure

The base infrastructure must be deployed first since it creates essential AWS resources like the EKS cluster. The base infrastructure code is included as a submodule in this repository.

1. **Clone This Repository with Submodules**

   ```sh
   git clone --recurse-submodules https://github.com/tdthurston/ilios-golang-api.git
   cd ilios-golang-api
   ```

   If you've already cloned the repository without submodules:

   ```sh
   git submodule update --init --recursive
   ```

2. **Navigate to the Infrastructure Submodule**

   ```sh
   cd infra
   ```

3. **Initialize and Apply Terraform**
IMPORTANT NOTE: The `terraform.tfvars` file included with the base infra submodule contains arbitrary values for testing purposes. These values should by changed to your desired values before deploying infrastructure.
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

4. **Save the Outputs**

   After successful deployment, save these important outputs - you'll need them for Step 2:
   
   ```sh
   # Note down these values
   terraform output eks_cluster_name
   terraform output irsa_role_arn
   terraform output github_actions_role_arn
   ```

### Step 2: Configure GitHub Repository and Workflow

1. **Set Up GitHub Repository Variables**

   Go to your GitHub repository → Settings → Secrets and variables → Actions → Variables:
   
   - Add `AWS_REGION`: The region where you deployed infrastructure (e.g., `us-east-1`)
   - Add `EKS_CLUSTER_NAME`: Use the value from Step 1
   - Add `IRSA_ROLE_ARN`: Use the value from Step 1

2. **Set Up GitHub Repository Secrets**

   Go to GitHub repository → Settings → Secrets and variables → Actions → Secrets:
   
   - Add `AWS_ROLE_TO_ASSUME`: The GitHub Actions role ARN from Step 1

### Step 3: Deploy the API Application

1. **Run the GitHub Actions Workflow**

   Go to your GitHub repository → Actions → "CI/CD Pipeline" → Run workflow

   This workflow will:
   - Deploy the Kubernetes resources (service account, deployment, service)
   - Build and deploy the API application

2. **Monitor Deployment Progress**

   Watch the workflow execution in the Actions tab. When completed successfully, proceed to the next step.

### Step 4: Access the API

1. **Get the Load Balancer URL**

   ```sh
   # Configure kubectl to use your EKS cluster
   aws eks update-kubeconfig --name YOUR_CLUSTER_NAME --region YOUR_REGION
   
   # Get the external URL
   kubectl get service golang-api-service
   ```

2. **Test the API Endpoints**

   Use the Load Balancer URL to access the following endpoints:
   
   - `http://{LOAD_BALANCER_URL}/vpcs` - View VPCs in your AWS account
   - `http://{LOAD_BALANCER_URL}/ec2s` - View EC2 instances
   - `http://{LOAD_BALANCER_URL}/eks` - View EKS clusters
   - `http://{LOAD_BALANCER_URL}/health` - Check API health

## Infrastructure Components

This project deploys and manages the following components:

- **VPC**: A Virtual Private Cloud with public and private subnets
- **EKS Cluster**: An Amazon Elastic Kubernetes Service cluster
- **Load Balancer**: An Application Load Balancer to distribute traffic
- **Kubernetes Deployment**: A deployment for the Golang API
- **Kubernetes Service**: A service to expose the API
- **IAM Roles**: Required IAM roles and policies for IRSA (IAM Roles for Service Accounts)

## Cleaning Up Resources

When you're done with the project, follow these steps to destroy all resources and avoid unnecessary AWS charges:

1. **Delete Kubernetes Resources First**

   You can use the GitHub Actions workflow to destroy all Kubernetes resources:

   Go to your GitHub repository → Actions → "Destroy" → Run workflow

   This workflow will automatically remove all deployed Kubernetes resources from your cluster (including the API).

2. **Destroy Base Infrastructure Resources**

   ```sh
   # Navigate to the infrastructure submodule
   cd infra
   
   # Destroy all Terraform-managed resources
   terraform destroy -auto-approve
   ```

3. **Confirm Deletion**

   Verify that all resources have been properly removed by checking the AWS Management Console.

## License

This project is licensed under the MIT License.
