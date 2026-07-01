# Bucket
output "bucket_name" {
  value = yandex_storage_bucket.bucket.bucket
}
output "image_public_url" {
  value = "https://${yandex_storage_bucket.bucket.bucket}.storage.yandexcloud.net/mi24.jpg"
}

# Instance Group
output "instance_group_id" {
  value = yandex_compute_instance_group.lamp_ig.id
}

# Load Balancer
output "load_balancer_static_ip" {
  value = yandex_vpc_address.static_ip.external_ipv4_address[0].address
}

# MySQL
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

# Kubernetes
output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.regional.id
}
output "k8s_external_endpoint" {
  value = yandex_kubernetes_cluster.regional.master[0].public_ip
}
output "k8s_kubeconfig_command" {
  value = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.regional.id} --external"
}
