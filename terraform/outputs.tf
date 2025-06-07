output "alb_dns_name" {
  description = "DNS endpoint ALB-a"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID ALB-a"
  value       = aws_lb.main.zone_id
}

output "alb_url" {
  description = "Puna URL aplikacije"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ec2_public_ip" {
  description = "Javna IP adresa EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_private_ip" {
  description = "Privatna IP adresa EC2 instance"
  value       = aws_instance.app.private_ip
}

output "frontend_url" {
  description = "URL frontend aplikacije"
  value       = "http://${aws_lb.main.dns_name}/"
}

output "backend_api_url" {
  description = "URL backend API-ja"
  value       = "http://${aws_lb.main.dns_name}/api/"
}
