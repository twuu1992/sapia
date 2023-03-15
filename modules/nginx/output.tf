output "alb_dns" {
  value = aws_lb.alb_nginx.dns_name
}