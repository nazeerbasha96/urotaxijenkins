terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "urotaxi1.0-tfstate-bucket"
    region = "ap-south-1"
    key = "terraform.tfstate"
    dynamodb_table = "urotaxi-terraform-lock"
  }
}

provider "aws" {
  region = var.region
}
module "urotaxi_vpc" {
  source   = "../modules/services/network/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}
module "urotaxi_subnet" {
  source            = "../modules/services/network/subnet"
  count             = length(var.subnet_block.subnet_cidr)
  vpc_id            = module.urotaxi_vpc.vpc_id
  subnet_cidr       = element(var.subnet_block.subnet_cidr, count.index)
  availability_zone = element(var.subnet_block.availability_zone, count.index % 2)
  subnet_name       = "${var.subnet_block.subnet_name}_${count.index + 1}"
}
module "urotaxi_ig" {
  source     = "../modules/services/network/gateway/ig"
  vpc_id     = module.urotaxi_vpc.vpc_id
  subnet_id  = [module.urotaxi_subnet[4].subnet_id, module.urotaxi_subnet[5].subnet_id]
  ig_name    = var.ig_block.ig_name
  ig_rt_name = var.ig_block.ig_rt_name
}
module "urotaxi_nat" {
  source           = "../modules/services/network/gateway/nat"
  vpc_id           = module.urotaxi_vpc.vpc_id
  subnet_id        = [module.urotaxi_subnet[0].subnet_id, module.urotaxi_subnet[1].subnet_id]
  public_subnet_id = module.urotaxi_subnet[4].subnet_id
  nat_name         = var.nat_block.nat_name
  nat_rt_name      = var.nat_block.nat_rt_name
  depends_on = [
    module.urotaxi_ig
  ]
}
module "ec2_keypair" {
  source     = "../modules/services/compute/keypair"
  key_name   = var.ec2_keypair.key_name
  public_key = var.ec2_keypair.public_key
}
module "application_server" {
  source                      = "../modules/services/compute/ec2"
  count                       = 2
  vpc_id                      = module.urotaxi_vpc.vpc_id
  subnet_id                   = module.urotaxi_subnet[count.index].subnet_id
  ami                         = var.application_server.ami
  instance_type               = var.application_server.instance_type
  associate_public_ip_address = false
  key_name                    = var.application_server.key_name
  instance_name               = "${var.application_server.instance_name}_${count.index + 1}"
  depends_on = [
    module.urotaxi_nat

  ]
}
module "jumpbox_ec2" {
  source                      = "../modules/services/compute/ec2"
  vpc_id                      = module.urotaxi_vpc.vpc_id
  subnet_id                   = module.urotaxi_subnet[4].subnet_id
  ami                         = var.application_server.ami
  instance_type               = var.application_server.instance_type
  associate_public_ip_address = true
  key_name                    = var.application_server.key_name
  instance_name               = "jumpbox_urotaxi"
  depends_on = [
    module.application_server,
    module.db_server

  ]
}
module "db_server" {
  source               = "../modules/services/database"
  vpc_id               = module.urotaxi_vpc.vpc_id
  db_cidr           = [module.urotaxi_vpc.vpc_cidr]
  allocated_storage    = var.db_server.allocated_storage
  db_name              = var.db_server.db_name
  db_username          = var.db_server.db_username
  db_password          = var.db_server.db_password
  instance_class       = var.db_server.instance_class
  subnet_id            = [module.urotaxi_subnet[2].subnet_id, module.urotaxi_subnet[3].subnet_id]
  db_subnet_group_name = var.db_server.db_subnet_group_name
  depends_on = [
    module.urotaxi_nat
  ]
}
module "lbr" {
  source    = "../modules/services/compute/elb"
  vpc_id    = module.urotaxi_vpc.vpc_id
  subnet_id = [module.urotaxi_subnet[4].subnet_id, module.urotaxi_subnet[5].subnet_id]
  tg_name   = var.lbr_config.tg_name
  instance1 = module.application_server[0].instance_id
  instance2 = module.application_server[1].instance_id
  lbr_name  = var.lbr_config.lbr_name
  depends_on = [
    module.application_server,
    resource.null_resource.config_file_copy
  ]
}
resource "null_resource" "config_file_copy" {
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = module.jumpbox_ec2.jumpbox_public_ip
      user = "ubuntu"
      private_key = file("../../keypair/urotaxi")
    }
    inline = [
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install mysql-client-8.0 -y",
      "sudo apt install maven -y",
      "cd /tmp/",
      "git clone https://github.com/nazeerbasha96/urotaxijenkins.git",
      "sudo cp /tmp/urotaxijenkins/config/keypair/urotaxi ~/.ssh/",
      "sudo chmod 600 /home/ubuntu/.ssh/urotaxi",
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/urotaxi",
      "sed -i 's/#dbhost#/${module.db_server.db_address}/g' /tmp/urotaxijenkins/src/main/resources/application.yml && mvn -f /tmp/urotaxijenkins/pom.xml clean verify",
      "sed -i 's/#dbhost#/${module.db_server.db_address}/g' /tmp/urotaxijenkins/config/ansible/roles/appdeploy/tasks/mysql-db.yml",
      "sed -i 's #dbusername# ${var.db_server.db_username} g' /tmp/urotaxijenkins/src/main/resources/application.yml",
      "sed -i 's #dbuserpassword# ${var.db_server.db_password} g' /tmp/urotaxijenkins/src/main/resources/application.yml",
      "printf '%s\n%s' ${module.application_server[0].appserver_private_ip} ${module.application_server[1].appserver_private_ip} > /tmp/urotaxihosts",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/urotaxi -i /tmp/urotaxihosts /tmp/urotaxijenkins/config/ansible/tomcat-playbook.yml",
      "mysql -h ${module.db_server.db_address} -u${var.db_server.db_username} -p${var.db_server.db_password} < /tmp/urotaxijenkins/src/main/db/urotaxidb.sql"    

    ]
   # sed -i 's #dbusername# root g' /tmp/urotaxijenkins/src/main/resources/application.yml
      
  }
   depends_on = [
    module.application_server,
    module.jumpbox_ec2
  ]
  
}