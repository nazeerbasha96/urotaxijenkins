resource "aws_security_group" "appsever_sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "ssh access for for instances"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    description = "application access from anywhere"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  
}

resource "aws_instance" "applicationserver" {
  subnet_id                   = var.subnet_id
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = [aws_security_group.appsever_sg.id]
  key_name = var.key_name
  tags = {
    "Name" = var.instance_name
  }


}
