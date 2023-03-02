variable "vpc_cidr" {
  type        = string
  description = "urotaxi vpc cidr block"
}
variable "region" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "subnet_block" {
  type = object({
    subnet_cidr       = list(any)
    subnet_name       = string
    availability_zone = list(any)
  })
}
variable "ig_block" {
  type = object({
    ig_name    = string
    ig_rt_name = string

  })

}
variable "nat_block" {
  type = object({
    nat_name    = string
    nat_rt_name = string
  })
}
variable "ec2_keypair" {
  type = object({
    key_name   = string
    public_key = string
  })
}
variable "application_server" {
  type = object({
    ami           = string
    instance_type = string
    instance_name = string
    key_name      = string
  })

}
variable "db_server" {
  type = object({
    allocated_storage    = string
    db_name              = string
    db_username          = string
    db_password          = string
    instance_class       = string
    db_subnet_group_name = string
  })
}
variable "lbr_config" {
  type = object({
    tg_name =string
    lbr_name =string
    lbr_sg_name=string

  })
}