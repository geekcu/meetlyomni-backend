variable "module" {
    description = "Module name"
    type = string
    default = "meetlyomni" 
}

variable "container_image" {
  description = "Container image for the ECS task"
  type = string   
  default = "972502737060.dkr.ecr.us-east-1.amazonaws.com/meetlyomni-backend:latest"
}

variable "ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  type = string   
  default = "arn:aws:iam::972502737060:role/ecsTaskExecutionRole"
}

variable "connection_string" {
  description = "Database connection string"
  type = string   
  default = "arn:aws:ssm:us-east-1:972502737060:parameter/ConnectionStrings__MeetlyOmniDb"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block range for vpc"
}

variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"         
}

variable "project" {
  description = "Project name"
  type = string
  default = "meetlyomni" 
}

variable "platform" {
  description = "Platform name"
  type = string
  default = "dev"
}

variable "environment" {
  description = "Applicaiton environment"
  type = string
  default = "dev"
}

variable "aws_availability_zones" {
  description = "List of AWS availability zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"] 
}

variable "max_capacity" {
  description = "The maximum capacity for the ECS service."
  type        = number  
  default     = 4   
  
}

variable "min_capacity" {
  description = "The minimum capacity for the ECS service."
  type        = number  
  default     = 1   
  
}