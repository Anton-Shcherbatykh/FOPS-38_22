resource "yandex_vpc_address" "static_ip" {
  name        = "lamp-static-ip"
  description = "Static public IP for LAMP load balancer"

  external_ipv4_address {
    zone_id = var.zone
  }

  deletion_protection = true
}
