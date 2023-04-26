resource "aws_vpc" "urotaxivpc" {
    cidr_block = var.vpc_cidr
    tags = {
      "Name" = var.vpc_name
    }
}