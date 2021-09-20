output "Node1_Public_IP" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.node1.public_ip
}

output "Node2_Public_IP" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.node2.public_ip
}