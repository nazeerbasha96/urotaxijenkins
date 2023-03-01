output "appserver_public_ip" {
  value = module.application_server[*].appserver_public_ip
}
# output "jumpbox_ec2_public_ip" {
#   value = module.jumpbox_ec2.jumpbox_public_ip
# }
output "db_endpoint" {
  value = module.db_server.db_endpoint
}
output "db_address" {
  value = module.db_server.db_address
  

}
output "lbr_endpoint" {
  value = module.lbr.lbr_endpoint
  
}