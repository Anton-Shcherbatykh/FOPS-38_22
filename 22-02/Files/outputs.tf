output "public_vm_external_ip" {
  value = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
}
output "private_vm_internal_ip" {
  value = yandex_compute_instance.private_vm.network_interface[0].ip_address
}
output "nat_instance_external_ip" {
  value = yandex_compute_instance.nat.network_interface[0].nat_ip_address
}

# Выводы для нового задания
output "image_public_url" {
  value = "https://${var.bucket_name}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}

output "network_lb_external_ip" {
  value = yandex_lb_network_load_balancer.lamp_nlb.listener[0].external_address_spec[0].address
}

output "application_lb_external_ip" {
  value = yandex_alb_load_balancer.lamp_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "instance_group_external_ips" {
  value = [
    for instance in yandex_compute_instance_group.lamp_ig.instances :
    instance.network_interface[0].nat_ip_address
  ]
}
