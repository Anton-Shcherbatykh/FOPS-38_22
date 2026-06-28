locals {
  # Публичный URL картинки из бакета
  image_url = "https://${var.bucket_name}.storage.yandexcloud.net/${yandex_storage_object.image.key}"

  # User-data скрипт для создания веб-страницы со ссылкой на картинку
  lamp_user_data = <<-EOF
    #!/bin/bash
    systemctl enable httpd
    systemctl start httpd
    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head><title>LAMP Cluster - ДЗ</title></head>
    <body>
    <h1>ВМ из Instance Group: $(hostname)</h1>
    <img src="${local.image_url}" alt="Картинка из Object Storage" width="600">
    <p>Ссылка: <a href="${local.image_url}">${local.image_url}</a></p>
    </body>
    </html>
    HTML
    chmod 644 /var/www/html/index.html
  EOF
}

# Instance Group из 3 ВМ
resource "yandex_compute_instance_group" "lamp_ig" {
  name               = "lamp-instance-group"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.storage_sa.id
  depends_on         = [yandex_storage_object.image]

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

    # Health check ВНУТРИ instance_template
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
  }

  # Scale policy на уровне ресурса, после instance_template
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
}

# Получаем ID целевой группы для балансировщиков
data "yandex_compute_instance_group" "ig_info" {
  instance_group_id = yandex_compute_instance_group.lamp_ig.id
}
