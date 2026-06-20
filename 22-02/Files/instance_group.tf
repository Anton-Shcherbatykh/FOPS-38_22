resource "yandex_iam_service_account" "ig_sa" {
  name        = "ig-service-account"
  folder_id   = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "ig_sa_editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

locals {
  image_url = "https://${var.bucket_name}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
  lamp_user_data = <<-EOF
    #!/bin/bash
    systemctl enable httpd
    systemctl start httpd
    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head><meta charset="UTF-8"><title>LAMP Cluster</title></head>
    <body>
    <h1>ВМ из Instance Group: $(hostname)</h1>
    <img src="${local.image_url}" alt="Картинка из Object Storage" width="600">
    <p><a href="${local.image_url}">${local.image_url}</a></p>
    </body>
    </html>
    HTML
    chmod 644 /var/www/html/index.html
  EOF
}

resource "yandex_compute_instance_group" "lamp_ig" {
  name               = "lamp-instance-group"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.ig_sa.id
  depends_on = [
    yandex_storage_object.image,
    yandex_resourcemanager_folder_iam_member.ig_sa_editor
  ]

  timeouts {
    update = "15m"
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        size     = 20
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.task1_network.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
      security_group_ids = [yandex_vpc_security_group.lamp_sg.id]
      nat                = true
    }

    metadata = {
      user-data = local.lamp_user_data
      ssh-keys  = "${var.vm_username}:${file(var.ssh_public_key_path)}"
    }
  }

  health_check {
    interval = 30
    timeout  = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
    http_options {
      port = 80
      path = "/index.html"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }
}
