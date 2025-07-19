resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  target_subnet_id = { for k, s in aws_subnet.public : k => s.id if s.cidr_block == "10.0.1.0/24" }
}
