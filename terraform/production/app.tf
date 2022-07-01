module "app" {
  source                 = "../app"
  env                    = "production"
  vpc_cidr_prefix        = "10.99"
  subdomain              = "prod"
  noco_image_version     = "0.91.7-finn.0"
  nc_auth_jwt_secret     = "f565b408-f621-11ec-b939-0242ac120002"
  desired_ecs_task_count = 6
  redis_instance_type    = "cache.r6.large"
}