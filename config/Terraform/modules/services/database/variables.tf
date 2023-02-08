variable "allocated_storage" {
  type = string
}
variable "db_name" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}
variable "subnet_id" {
  type = list
}
variable "db_cidr" {
  type = list(string)
}
variable "db_subnet_group_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
