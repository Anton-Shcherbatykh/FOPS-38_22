# Существующие выводы --- задание 1 ---
output "public_vm_external_ip" {
  value = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
}

output "private_vm_internal_ip" {
  value = yandex_compute_instance.private_vm.network_interface[0].ip_address
}

output "nat_instance_external_ip" {
  value = yandex_compute_instance.nat.network_interface[0].nat_ip_address
}

# Добавленные выводы --- задание 2 ---
output "image_public_url" {
  value = "https://${var.bucket_name}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}

output "network_lb_external_ip" {
  value = one(yandex_lb_network_load_balancer.lamp_nlb.listener).external_address_spec[0].address
}

output "application_lb_external_ip" {
  value = one(yandex_alb_load_balancer.lamp_alb.listener).endpoint[0].address[0].external_ipv4_address[0].address
}

output "instance_group_external_ips" {
  value = [
    for instance in yandex_compute_instance_group.lamp_ig.instances :
    instance.network_interface[0].nat_ip_address
  ]
}

# MySQL --- задание 4 ---
output "mysql_cluster_id" {
  value = yandex_mdb_mysql_cluster.netology.id
}
output "mysql_database" {
  value = yandex_mdb_mysql_database.netology.name
}
output "mysql_user" {
  value = yandex_mdb_mysql_user.netology.name
}
output "mysql_password" {
  value     = random_password.mysql.result
  sensitive = true
}
output "mysql_hosts" {
  value = [for h in yandex_mdb_mysql_cluster.netology.host : h.fqdn]
}

# Kubernetes --- задание 4 --- 
output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.regional.id
}
output "k8s_external_endpoint" {
  value = yandex_kubernetes_cluster.regional.master[0].public_ip
}
output "k8s_kubeconfig_command" {
  value = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.regional.id} --external"
}