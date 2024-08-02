output "ingress_load_balancer_dns" {
  description = "The dns name of the ingress controller's loadbalancer"
  value = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].hostname
}

output "ingress_load_balancer_zone_id" {
  value = data.aws_elb.ingress_nginx_lb.zone_id
}

# output "ingress_load_balancer_arn" {
#   value = data.aws_lb.ingress_nginx_lb.arn
# }