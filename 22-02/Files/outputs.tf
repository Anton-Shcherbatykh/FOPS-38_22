output "bucket_name" {
  value = yandex_storage_bucket.bucket.bucket
}

output "image_public_url" {
  value = "https://${yandex_storage_bucket.bucket.bucket}.storage.yandexcloud.net/mi24.jpg"
}

output "instance_group_id" {
  value = yandex_compute_instance_group.lamp_ig.id
}

output "network_lb_external_ip" {
  value = one(one(yandex_lb_network_load_balancer.lamp_nlb.listener).external_address_spec).address
}
