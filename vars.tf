variable "region-master" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.region-master
}

data "aws_availability_zones" "available" {}


variable "health_check" {
  type = map(string)
  default = {
    "timeout"             = "10"
    "interval"            = "20"
    "path"                = "/"
    "port"                = "80"
    "unhealthy_threshold" = "2"
    "healthy_threshold"   = "3"
  }
}

variable "dns-name" {
  type    = string
  default = "cmcloudlab1603.info"
}
variable "profile" {
  type    = string
  default = "default"
}
variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}
variable "site-name" {
  type    = string
  default = ""
}