# GitHub Actions Workflows

This repository contains two GitHub Actions workflows for infrastructure deployment and destruction.

## Workflows

### 1. deploy.yml

**Purpose**: Build and deploy the application with Terraform infrastructure provisioning

**Trigger**: 
- Push to `devops-di` branch
- Pull requests to `devops-di` branch

**Jobs**:
1. **terraform-deploy**: Deploys AWS infrastructure using Terraform
   - Initializes Terraform with S3 backend
   - Validates Terraform configuration
   - Creates and applies Terraform plan
   - Deploys VPC, ECS cluster, Fargate service, ALB, and Route53 DNS

2. **build-and-deploy**: Builds and deploys the application container
   - Builds Docker image and pushes to ECR
   - Updates ECS task definition with new image
   - Deploys to ECS service

**Required GitHub Variables**:
- `AWS_REGION`: AWS region (e.g., us-east-1)
- `ECR_REPOSITORY`: ECR repository URI
- `AWS_OIDC_PROVIDER_ARN`: OIDC provider ARN for GitHub Actions
- `AWS_ROLE_ARN`: IAM role ARN for deployment

### 2. destroy.yml

**Purpose**: Destroy Terraform-managed infrastructure

**Trigger**: Manual workflow dispatch from GitHub UI

**Inputs**:
- `environment`: Environment to destroy (dev, staging, prod)

**Jobs**:
1. **terraform-destroy**: Destroys AWS infrastructure
   - Initializes Terraform
   - Validates configuration
   - Creates destroy plan
   - Applies destroy plan to remove all resources

**Required GitHub Variables**:
- `AWS_REGION`: AWS region
- `AWS_OIDC_PROVIDER_ARN`: OIDC provider ARN
- `AWS_ROLE_ARN`: IAM role ARN

## Usage

### Automated Deployment
1. Push to the `devops-di` branch
2. The workflow will automatically:
   - Deploy Terraform infrastructure
   - Build and deploy the application

### Manual Destruction
1. Go to GitHub Actions → Workflows → Terraform Destroy Resources
2. Click "Run workflow"
3. Select the environment to destroy
4. Confirm execution

## Terraform Backend Configuration

The Terraform state is stored in S3 with the following naming convention:
- Bucket: `meetlyomni-tf-state-bucket-{environment}`
- Key: `{environment}/terraform.tfstate`
- Locking: DynamoDB table `terraform-state-locks-{environment}`

## Security Notes

- Ensure the IAM role used has appropriate permissions for Terraform operations
- Review Terraform plan output before applying changes
- Use the destroy workflow carefully as it will remove all infrastructure
