output "nat_instance_id" {
  description = "NAT instance ID"
  value       = aws_instance.nat.id
}

output "nat_instance_public_ip" {
  description = "Public IP of NAT instance"
  value       = aws_eip.nat_instance.public_ip
}

output "nat_instance_private_ip" {
  description = "Private IP of NAT instance"
  value       = aws_instance.nat.private_ip
}

output "security_group_id" {
  description = "Security group ID of NAT instance"
  value       = aws_security_group.nat_instance.id
}

output "nat_dns_record" {
  description = "DNS record for NAT instance (if created)"
  value       = var.create_dns_record ? "nat.${var.environment}.${var.route53_zone_name}" : "N/A - DNS record not created"
}
