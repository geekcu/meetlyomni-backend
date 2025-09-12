resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.meetlyomni-dev-vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.ecs_tasks.id]

  private_dns_enabled = true

  tags = {
    Name = "meetlyomni-ssm-endpoint-${var.environment}"
  }
  
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.meetlyomni-dev-vpc.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.ecs_tasks.id]

  private_dns_enabled = true

  tags = {
    Name = "meetlyomni-logs-endpoint-${var.environment}"
  }
}
