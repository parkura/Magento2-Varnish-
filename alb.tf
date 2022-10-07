
resource "aws_lb" "application-lb" {
  name               = "webservers-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ingress-ssh-http-https.id]
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = true
  tags = {
    Environment = "Production"
    Role        = "Sample-Application"
  }
}

#Target group and attachment for Magento2 web servers
resource "aws_lb_target_group" "app-lb-tg" {
  provider    = aws.region-master
  name        = "app-lb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
  }
  tags = {
    Name = "webserver-target-group"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.Magento2-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test1" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.Magento2-2.id
  port             = 80
}

#Target group and attachment for Varnish server
resource "aws_lb_target_group" "for-Varnish" {
  provider    = aws.region-master
  name        = "for-Varnish"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
    timeout             = var.health_check["timeout"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
  }
  tags = {
    Name = "Varnish-target-group"
  }
}

resource "aws_lb_target_group_attachment" "varnish" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.for-Varnish.arn
  target_id        = aws_instance.Varnish.id
  port             = 80
}



resource "aws_lb_listener" "lb-https-listener" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.aws-ssl-cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_listener" "lb-http-listener" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Rules for /static/* and /media/*
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.lb-http-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }

  condition {
    host_header {
      values = ["cmcloudlab1603.info"]
    }
  }
}

resource "aws_lb_listener_rule" "media" {
  listener_arn = aws_lb_listener.lb-http-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }

  condition {
    path_pattern {
      values = ["/media/*"]
    }
  }

  condition {
    host_header {
      values = ["cmcloudlab1603.info"]
    }
  }
}

#Rule for /*, redirect to Varnish

resource "aws_lb_listener_rule" "redirectToVarnish" {
  listener_arn = aws_lb_listener.lb-http-listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for-Varnish.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    host_header {
      values = ["cmcloudlab1603.info"]
    }
  }
}


#ACM CONFIGURATION
resource "aws_acm_certificate" "aws-ssl-cert" {
  provider          = aws.region-master
  domain_name       = join(".", [var.site-name, data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags = {
    Name = "Webservers-ACM"
  }

}

#Validates ACM issued certificate via Route53
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.region-master
  certificate_arn         = aws_acm_certificate.aws-ssl-cert.arn
  for_each                = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

