resource "aws_security_group" "ingress-ssh-http-https" {
  name   = "allow-ssh-http-https-sg"
  vpc_id = module.vpc.vpc_id


  dynamic "ingress" {
    for_each = ["80", "8080", "443", "22"]
    content {
      description = "allow http, https, ssh"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}