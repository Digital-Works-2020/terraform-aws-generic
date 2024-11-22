#Configure Provider
provider "aws" {
  region = var.region
}

#Get VPC Info
data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

#Get Subnet ID's associated to VPC
data "aws_subnets" "my_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

#Get All Subnets info associated to VPC in Detail
data "aws_subnet" "my_vpc_subnet" {
  for_each = toset(data.aws_subnets.my_vpc_subnets.ids)
  id       = each.value
}

#Get Internet Gateway Associated to VPC
data "aws_internet_gateway" "my_vpc_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

#Get NAT Gateway ID's Associated to VPC
data "aws_nat_gateways" "my_vpc_ngws" {
  vpc_id = var.vpc_id
  filter {
    name   = "state"
    values = ["available"]
  }
}

#Get All NAT Gateway Info Associated to VPC
data "aws_nat_gateway" "my_vpc_ngw" {
  for_each = toset(data.aws_nat_gateways.my_vpc_ngws.ids)
  id       = each.value
}

#Get Route Table ID's Associated to VPC
data "aws_route_tables" "my_vpc_route_tables" {
  vpc_id = var.vpc_id
}

#Get All Route Tables Info Associated to VPC
data "aws_route_table" "my_vpc_route_table" {
  route_table_id = each.value
  for_each       = toset(data.aws_route_tables.my_vpc_route_tables.ids)
}

#Local Variable to create outputs
locals {
  vpc_name           = lookup(data.aws_vpc.my_vpc.tags, "Name", "NA")
  total_subnets      = length(data.aws_subnets.my_vpc_subnets.ids)
  total_nat_gateways = length(data.aws_nat_gateways.my_vpc_ngws.ids)
  total_route_tables = length(data.aws_route_tables.my_vpc_route_tables.ids)
  cidr_blocks        = join(",", [for assoc in data.aws_vpc.my_vpc.cidr_block_associations : assoc.cidr_block])
  subnet_info = [
    for subnet_id, subnet in data.aws_subnet.my_vpc_subnet : {
      Name              = lookup(subnet.tags, "Name", "NA")
      CidrBlock         = subnet.cidr_block
      ID                = subnet.id
      Public_or_Private = subnet.map_public_ip_on_launch ? "Public" : "Private"
      Associated_Route_Tables = join(",", [
        for route_table in data.aws_route_table.my_vpc_route_table :
        route_table.tags["Name"] if contains(route_table.associations[*].subnet_id, subnet_id)
      ])
    }
  ]
  igw_name = lookup(data.aws_internet_gateway.my_vpc_igw.tags, "Name", "NA")
  public_subnet_count = length([for subnet in data.aws_subnet.my_vpc_subnet: subnet if subnet.map_public_ip_on_launch == true])
  private_subnet_count= length([for subnet in data.aws_subnet.my_vpc_subnet: subnet if subnet.map_public_ip_on_launch == false])
}

