output "appserver_private_ip" {
  value = aws_instance.applicationserver.private_ip
}
output "jumpbox_public_ip" {
    value = aws_instance.applicationserver.public_ip  
}
output "instance_id" {
  value = aws_instance.applicationserver.id
  
}