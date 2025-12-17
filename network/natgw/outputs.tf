output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IPs assigned to NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "elastic_ip_ids" {
  description = "List of Elastic IP IDs"
  value       = aws_eip.nat[*].id
}

output "nat_gateway_subnet_ids" {
  description = "List of subnet IDs where NAT Gateways are deployed"
  value       = aws_nat_gateway.main[*].subnet_id
}
