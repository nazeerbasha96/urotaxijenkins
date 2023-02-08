region = "ap-south-1"
vpc_cidr = "10.0.0.0/16"
vpc_name = "urotaxi_vpc"
subnet_block = {
  subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  subnet_name = "urotaxi_subnet_"
  availability_zone = ["ap-south-1a", "ap-south-1b"]
}
ig_block = {
  ig_name = "urotaxi_ig"
  ig_rt_name = "urotaxi_ig_rt"
}
nat_block = {
  nat_name = "urotaxi_nat"
  nat_rt_name = "urotaxi_nat_rt"
}
ec2_keypair = {
  key_name = "urotaxi_kp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCay+2Jy+SnVbINDD/7nPgfFMUxnQG+n1znc/BRUp9Hb2DxGwlQ5P6jDS9dixXWl0JTK9xg4RW0cNyRjraamtwQiB3ZfGjcZAqrs+XbIkYLCszx5NK+npZsEQdk0G2kRjE8ChEBgHRVP5lCC7QMfyXOk0HapCsbWSNuAOfPngrkYa4d4q8967z0pcYp383+zjPWkw7ZwHuC36uY57DYxTNJkDXmU5F8bLDRQOQoWRTEp7IV7AEb27KmGJatGbvFeDWxG3vCl4RHCp5Jox85NMKMVIaUV3UcIDTl0YWN+99wlxq8LJ61Fc69GaT3Gq8U27hqkFQR1judnmCE+9uYwfYtSJmv75NP/kB2KNSmC1faRL1hK0mWRoCHNsbCCQxBTrzAtP8c9mvHWzbHffCiGJ1+xe97GpnXSzhi/l/PLyhz7xLlGo+gOGuhrdALpgNN4jT4wBhL49Y1iJE10340WlOB7KJOMHXIfx6CHIdpzlDO+UEWshC55O+/IOKGNZF6hYc= nazee@BASHA"
}
application_server = {
  ami = "ami-06984ea821ac0a879"
  instance_name = "urotaxi"
  instance_type = "t2.micro"
  key_name = "urotaxi_kp"
}

#db
db_server = {
  allocated_storage = "10"
  db_name = "urotaxi_db"
  db_username = "root"
  db_password = "welcome#123"
  db_subnet_group_name = "urotaxi_subnetgroup"
  instance_class = "db.t3.micro"
}
lbr_config = {
  lbr_name = "urotaxi-lbr"
  lbr_sg_name = "lbr_sg"
  tg_name = "urotaxi-tg"
}