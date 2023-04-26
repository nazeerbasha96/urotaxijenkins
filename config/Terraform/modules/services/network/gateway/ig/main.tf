resource "aws_internet_gateway" "urotaxi_ig" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = var.ig_name
  }
}
resource "aws_route_table" "urotaxi_ig_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.urotaxi_ig.id
  }
  tags = {
    "Name" = var.ig_rt_name
  }
}
resource "aws_route_table_association" "urotaxi_rt_assocation" {
  count          = length(var.subnet_id)
  route_table_id = aws_route_table.urotaxi_ig_rt.id
  subnet_id      = element(var.subnet_id, count.index)
}