variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type = string 
}

variable "security_group_alb_id" {
  description = "ALB Security Group ID from VPC module"
  type = string
}

variable "project" {
  description = "Project name"
  type = string
  default = "meetlyomni"
}

variable "environment" {
  description = "Application environment"
  type = string
  default = "dev"
}

variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1" 
  
}

variable "vpc_id" {
  description = "VPC ID where ECS Fargate service will be deployed"
  type = string   
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type = list(string) 
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs from VPC module"
  type = list(string) 
}

variable "ecs_security_group_id" {
    description = "ECS Security Group ID"
    type = string
}

variable "container_image" {
    description = "Container image for the ECS task"
    type = string   
    default = "972502737060.dkr.ecr.us-east-1.amazonaws.com/meetlyomni-backend:latest"
}

variable "ecs_task_execution_role_arn" {
    description = "ECS Task Definition ARN"
    type = string   
    default = "arn:aws:iam::972502737060:role/ecsTaskExecutionRole"
  
}

variable "connection_string" {
    description = "Database connection string"
    type = string   
    default = "arn:aws:ssm:us-east-1:972502737060:parameter/ConnectionStrings__MeetlyOmniDb"
  
}
