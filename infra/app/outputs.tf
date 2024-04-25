# output "backend_alb_url" {
#   value = module.ecs_cluster.alb_url
# }


output "test_alb_url" {
  value = module.ecs_ec2_cluster.alb_url
}
