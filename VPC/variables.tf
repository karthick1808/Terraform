variable "variables_sub_cidr" {
  type        = string
  description = "CIDR Block for Variables Subnet"
  default     = "192.168.4.0/24"
}

variable "variables_sub_az" {
  type        = string
  description = "Avaliablity Zone Used for Variables Subnet"
  default     = "ap-south-1c"
}

variable "variables_auto_ip" {
  type        = bool
  description = "Set Automatic IP Assignment fro Variables Subnet"
  default     = true
}

variable "environment" {
  description = "Environment fro Development"
  type        = string
  default     = "dev"
}
