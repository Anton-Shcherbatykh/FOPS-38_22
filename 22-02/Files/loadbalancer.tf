# Сетевой балансировщик (Network Load Balancer) для Instance Group
resource "yandex_lb_network_load_balancer" "lamp_nlb" {
  name = "lamp-network-lb"

  listener {
    name        = "http-listener"
    port        = 80
    protocol    = "tcp"
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = data.yandex_compute_instance_group.ig_info.load_balancer[0].target_group_id

    health_check {
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
}