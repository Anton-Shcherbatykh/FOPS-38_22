resource "yandex_lb_target_group" "lamp_tg" {
  name      = "lamp-target-group"
  folder_id = var.yc_folder_id

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp_ig.instances
    content {
      subnet_id = yandex_vpc_subnet.public.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "lamp_nlb" {
  name = "lamp-network-lb"
  type = "external"

  listener {
    name        = "http-listener"
    port        = 80
    protocol    = "tcp"
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.static_ip.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp_tg.id
    healthcheck {
      name                = "http-health-check"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      tcp_options {
        port = 80
      }
    }
  }

  depends_on = [yandex_lb_target_group.lamp_tg]
}
