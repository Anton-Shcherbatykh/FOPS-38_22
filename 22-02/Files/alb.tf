# Application Load Balancer (ALB) с проверкой состояния

resource "yandex_alb_load_balancer" "lamp_alb" {
  name        = "lamp-alb"
  network_id  = yandex_vpc_network.task1_network.id
  security_group_ids = [yandex_vpc_security_group.lamp_sg.id]

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.lamp_router.id
      }
    }
  }
}

resource "yandex_alb_http_router" "lamp_router" {
  name = "lamp-router"
}

resource "yandex_alb_virtual_host" "lamp_vhost" {
  name           = "lamp-vhost"
  http_router_id = yandex_alb_http_router.lamp_router.id
  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.lamp_bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_backend_group" "lamp_bg" {
  name = "lamp-backend-group"

  http_backend {
    name             = "lamp-backend"
    port             = 80
    weight           = 1
    target_group_ids = [data.yandex_compute_instance_group.ig_info.load_balancer[0].target_group_id]

    healthcheck {
      timeout  = "10s"
      interval = "2s"
      http_healthcheck {
        path = "/index.html"
      }
    }
  }
}