#Printing VPC info
output "VPC_Details" {
  value = <<EOT
 The details of VPC ${var.vpc_id} are as below:
 ===========================================================================
 VPC Name                : ${local.vpc_name}
 Total Subnets           : ${local.total_subnets}
 Total Route Tables      : ${local.total_route_tables}
 NAT Gateways            : ${local.total_nat_gateways}
 DNS HostName Enablement : ${data.aws_vpc.my_vpc.enable_dns_hostnames}
 DNS Support Enablement  : ${data.aws_vpc.my_vpc.enable_dns_support}
 CIDR Blocks             : ${local.cidr_blocks}
 Internet Gateway Name   : ${local.igw_name}
 Public Subnet Count     : ${local.public_subnet_count}
 Private Subnet Count    : ${local.private_subnet_count}
 EOT
}

#Printing Basic Subnets Info associated to VPC as Dictionary
output "Subnet_Info" {
  value = local.subnet_info
}   

#Printing Basic Route Tables Info associated to VPC as Dictionary
output "Route_Tables_Info" {
  value = [
    for route_table in data.aws_route_table.my_vpc_route_table : {
      Name    = lookup(route_table.tags, "Name", "NA")
      Id      = route_table.id
      Subnets = join(",", [for subnet_association in route_table.associations : subnet_association.subnet_id])
    }
  ]
}

#Printing Basic NAT Gateway Info associated to VPC as Dictionary
output "NAT_Gateway_Info" {
  value = [
    for each_ngw in data.aws_nat_gateway.my_vpc_ngw : {
      Name              = lookup(each_ngw.tags, "Name", "NA")
      Id                = each_ngw.id
      Connectivity_Type = each_ngw.connectivity_type
      Public_IP         = lookup(each_ngw, "public_ip", "NA")
      Private_IP        = lookup(each_ngw, "private_ip", "NA")
      Subnet_ID         = lookup(each_ngw, "subnet_id", "NA")
    }
  ]
}
