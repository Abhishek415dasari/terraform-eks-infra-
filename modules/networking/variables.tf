variable "vpc_cidr"     { type = string default = "10.0.0.0/16" }
variable "public_subnets"  { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24"] }
variable "private_subnets" { type = list(string) default = ["10.0.11.0/24","10.0.12.0/24"] }
variable "azs"             { type = list(string) default = ["us-east-1a","us-east-1b"] }
