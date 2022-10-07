
resource "aws_instance" "Magento2-1" {
  ami                    = "ami-0ee23bfc74a881de5"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.ingress-ssh-http-https.id}"]
  subnet_id              = element(module.vpc.public_subnets, 0)
  tags = {
    Name = "Magento2-1"
  }
}
resource "aws_instance" "Magento2-2" {
  ami                    = "ami-0ee23bfc74a881de5"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.ingress-ssh-http-https.id}"]
  subnet_id              = element(module.vpc.public_subnets, 0)
  tags = {
    Name = "Magento2-2"
  }
}

resource "aws_instance" "Varnish" {
  ami                    = "ami-0ee23bfc74a881de5"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.ingress-ssh-http-https.id}"]
  subnet_id              = element(module.vpc.public_subnets, 0)
  tags = {
    Name = "Varnish"
  }
}

# module "key_pair" {
#   source = "terraform-aws-modules/key-pair/aws"
#   key_name           = "user1"
#   create_private_key = true
# }


# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"
#   for_each = var.instance_names
#   name = each.value
#   ami                    = "ami-0ee23bfc74a881de5"
#   instance_type          = "t2.micro"
#   key_name               = "user1"
#   monitoring             = true
#   vpc_security_group_ids = ["${aws_security_group.ingress-ssh-http-https.id}"]
#   subnet_id       = element(module.vpc.public_subnets, 0)


#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }