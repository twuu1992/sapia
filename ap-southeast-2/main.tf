module "ecs_nginx" {
  source = "../modules/nginx"
  
  ami_id_asg_template = var.ami_id_asg_template
}

output "alb_dns" {
  value = module.ecs_nginx.alb_dns
}