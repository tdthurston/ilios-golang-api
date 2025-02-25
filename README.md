### Ilios Golang API

Part one of the final project for the Ilios LLC internship program.

This API returns AWS metadata for the currently configured AWS account using the AWS SDK v2 for Go.

Each endpoint will return associated data for VPCs (/vpcs), EC2 instances (/ec2s), or EKS clusters (/eks) using their respective paths, as well as a health check using /health.

## Infrastructure Overview

The infrastructure for this project is managed using Terraform and includes the following components:

- **VPC**: A Virtual Private Cloud (VPC) with public and private subnets.
- **EKS Cluster**: An Amazon Elastic Kubernetes Service (EKS) cluster for running the Golang API.
- **Load Balancer**: An Application Load Balancer (ALB) to distribute traffic to the Kubernetes service.
- **Kubernetes Deployment**: A Kubernetes deployment for the Golang API.
- **Kubernetes Service**: A Kubernetes service to expose the Golang API deployment.

### Usage

### Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate credentials.
- kubectl installed and configured.

### Steps

1. **Initialize Terraform**: Initialize the Terraform configuration.

    ```sh
    terraform init
    ```

2. **Plan the Deployment**: Review the changes that Terraform will make.

    ```sh
    terraform plan -var-file=test_deploy.tfvars
    ```

3. **Apply the Deployment**: Apply the Terraform configuration to create the infrastructure.

    ```sh
    terraform apply -var-file=test_deploy.tfvars
    ```

4. **Access the API**: Once the deployment is complete, you can access the Golang API using the DNS name of the load balancer.

## Endpoints

- **/vpcs**: Returns metadata for VPCs.
- **/ec2s**: Returns metadata for EC2 instances.
- **/eks**: Returns metadata for EKS clusters.
- **/health**: Health check endpoint.

## License

This project is licensed under the MIT License.