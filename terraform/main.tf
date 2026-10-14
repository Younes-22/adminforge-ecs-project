module "vpc" {
  source = "./modules/vpc"
}

module "ecs" {
  source                = "./modules/ecs"
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id

  private_subnet_ids = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  target_group_arn   = module.alb.target_group_arn
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  container_image    = var.container_image

}

module "iam" {
  source = "./modules/iam"
}

module "route53" {
  source       = "./modules/route53"
  zone_id      = module.route53.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "acm" {
  source = "./modules/acm"

  domain_name     = var.domain_name
  route53_zone_id = module.route53.zone_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = [
    module.vpc.public_subnet_1_id,
    module.vpc.public_subnet_2_id
  ]
vpc_cidr = var.vpc_cidr
  
  certificate_arn        = module.acm.certificate_arn
}