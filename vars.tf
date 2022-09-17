
variable "AWS_REGION" {
	default = "eu-central-1"
}

# If you are using diffrent region (other than us-east-1) please find ubuntu 18.04 ami for that region and change here.
variable "ami_id" {
    type = string
    default = "ami-0f64f746a3cb9a16e"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a"]
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

# variable "private_subnets" {
#     type = list(string)
#     default = ["10.0.1.0/24"]
# }

variable "public_subnets" {
    type = list(string)
    default = ["10.0.101.0/24"]
}

# variable "master_node_count" {
#     type = number
#     default = 1
# }

# variable "worker_node_count" {
#     type = number
#     default = 1
# }

variable "ssh_user" {
    type = string
    default = "ubuntu"
}

variable "master_instance_type" {
    type = string
    default = "t3.micro"
}

variable "worker_instance_type" {
    type = string
    default = "t3.micro"
}