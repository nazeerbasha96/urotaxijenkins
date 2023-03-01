resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = var.db_cidr
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "db_security_group"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}
resource "aws_db_subnet_group" "db_subnetgroup" {
  subnet_ids = var.subnet_id
  tags = {
    "Name" = var.db_subnet_group_name
  }
}
resource "aws_db_instance" "urotaxi_db" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0.31"
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  tags = {
    "Name" = var.db_name
  }
}
