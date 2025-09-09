output "kafka_public_ips" {
  value = aws_instance.kafka[*].public_ip
}

output "kafka_private_ips" {
  value = aws_instance.kafka[*].private_ip
}
