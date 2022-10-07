output "region" {
  description = "AWS region"
  value = var.region-master
}

output "Application-LB-URL" {
  value = aws_lb.application-lb.dns_name
}


output "elb_example" {
  description = "The DNS name of the ELB"
  value = aws_lb.application-lb.dns_name
}


output "url" {
  value = aws_route53_record.webservers.fqdn
}