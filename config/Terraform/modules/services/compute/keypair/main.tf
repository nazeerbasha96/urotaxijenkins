resource "aws_key_pair" "urotaxi_kp" {
  key_name = var.key_name
  public_key = var.public_key
  tags = {
    "Name" = var.key_name
  }
}