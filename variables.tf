#Region in which search option needs to be performed
variable "region" {
  type        = string
  description = "Enter the region in which you want to search your VPC"
}

#VPC ID - To fetch its details
variable "vpc_id" {
  type        = string
  description = "Enter the VPC id of which you want to get details"
}
