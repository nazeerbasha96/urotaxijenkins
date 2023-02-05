output "appserver_private_ip" {
  value = module.application_server.private_ip
}
output "jumpbox_public_ip" {
  value = module.application_server.public_ip
}
output "db_endpoint" {
  value = module.db_server.db_endpoint
}