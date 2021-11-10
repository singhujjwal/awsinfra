output "instances" {
  value       = aws_instance.master_jenkins.public_ip
  description = "PrivateIP address details"
}