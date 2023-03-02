resource "aws_eip" "urotaxi_eip" {
  vpc = true
}

resource "aws_nat_gateway" "urotaxi_nat" {
  allocation_id     = aws_eip.urotaxi_eip.id
  subnet_id         = var.public_subnet_id
  connectivity_type = "public"
  tags = {
    "Name" = var.nat_name
  }
}

resource "aws_route_table" "urotaxi_nat_rt" {
    vpc_id = var.vpc_id
  route {
    gateway_id = aws_nat_gateway.urotaxi_nat.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    "Name" = var.nat_rt_name
  }
}
resource "aws_route_table_association" "urotaxi_rt_nat_assocation" {
    count = length(var.subnet_id)
    route_table_id = aws_route_table.urotaxi_nat_rt.id
    subnet_id = element(var.subnet_id,count.index) 
}