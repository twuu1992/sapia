module "ecs_nginx" {
  source = "./modules/nginx"

  vpc_id = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids
  ecs_sg_id = aws_security_group.nginx_http_sg.id
  alb_sg_id = aws_security_group.alb_http_sg.id
  ecs_role_arn = aws_iam_role.ecs_role.arn
  ecs_role_policy = aws_iam_role_policy.ecs_policy
}