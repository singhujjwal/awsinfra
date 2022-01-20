output "instances" {
  // value       = aws_instance.master_jenkins.public_ip
  value       = aws_instance.master_jenkins.private_ip
  description = "PrivateIP address details"
}
