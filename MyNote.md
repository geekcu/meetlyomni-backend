[2025-8-18 Note]
  - Rewrite Dockerfile 
  - Create an .env file, Add ConnectionStrings__MeetlyOmniDb
  - Build Image: docker build -f src/MeetlyOmni.Api/Dockerfile . -t meetlyomni-api:latest --no-cache 
  - Start new container: docker run -d --env-file .env -e ASPNETCORE_ENVIRONMENT=Development -p 5000:8080 --name meetlyomni-api meetlyomni-api:latest
  - Open Browser to verify:  http://localhost:5000/health & http://localhost:5000/swagger/index.html


[2025-08-20 Note]

AWS Infrastructure 

VPC CIDR: 10.0.0.0/16

Subnets: 
Public Subnet 1:  10.0.1.0/24
Public Subnet 2:  10.0.2.0/24
Private Subnet 1: 10.0.3.0/24 
Private Subnet 2: 10.0.4.0/24 

Route tables: 
public-rt: associate with public subnet 1 and subnet 2. Route with local and Internet Gateway
private-rt: associate with private subnet 1 and subnet 2. Route with local and NAT Gateway

Internet Gateway (igw)
Attached to public-rt

NAT-Gateway 
Subnet: select an Private subnet
Connectivity Type: Public

ECS Configure:
1. Create Cluster
2. Create Task definiations 
    - Task Execution role: ecsTaskExecutionRole
    - Container Port: 8080
    - Add environment variable 
3. Under Cluster to Create an Service
    - Select VPC for the ECS
    - Select Subnets (Public & Private)
    - Create an new security Group. Port Range:8080
    - Enable Turned on Public IP 
4. Loading Balance 
    - Listeners: 8080
    - Target Group: HTTP 8080


[2025-08-22 Note]

1. Github Action: Add Repository secrets from the Deploy.yml
2. Configure AWS Credentials: IAM -> Add Identity Providers (Provider + Audience, ARN Address aws-oidc-provider-arn: ${{ secrets.AWS_OIDC_PROVIDER_ARN }})
3. Create an IAM Role: Allow AWS and Github Actions trust. For example: GitHub-Deploy-Role has Permissions Policies [ AmazonEC2ContainerRegistryFullAccess] and [AmazonECS_FullAccess]
The "Trust Relationships"
    -"Federated": "arn:aws:iam::972502737060:oidc-provider/token.actions.githubusercontent.com"
    - "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    - "token.actions.githubusercontent.com:sub": "repo:geekcu/meetlyomni-backend:ref:refs/heads/devops-di"
4. ecsTaskExecutionRole has permission policies: [AmazonECSTaskExecutionRolePolicy] [ROSAKMSProviderPolicy] [SecretsManagerReadWrite] 
5. Repo CI need to have an pre-configured from the ECS Cluster:
    - Create cluster
    - Task definitions (ece-task-definiation.json)
    - Create Service 
    - Cloud Watch - Log groups 
 
