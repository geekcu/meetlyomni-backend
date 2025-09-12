output "vpc_arn" {
  value = aws_vpc.meetlyomni-dev-vpc.arn    
}

output "vpc_id" {
  value = aws_vpc.meetlyomni-dev-vpc.id 
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "security_group_alb_id" {
  value = aws_security_group.meetlyomni-dev-sg.id
}

output "ecs_tasks_sg_id" {
  value = aws_security_group.ecs_tasks.id
}
