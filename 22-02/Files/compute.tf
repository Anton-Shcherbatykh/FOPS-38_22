# Данные последнего стабильного образа Ubuntu 20.04 LTS
data "yandex_compute_image" "ubuntu_2004" {
  family = "ubuntu-2004-lts"
}

# Данные образа NAT-инстанса (заданный image_id)
data "yandex_compute_image" "nat_image" {
  image_id = var.nat_image_id
}

# NAT-инстанс с внутренним IP 192.168.10.254 и внешним IP
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = var.vm_platform_id
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_image.id
      size     = 30
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.ssh_public_key_path)}"
    # Скрипт для включения IP forwarding (если образ не делает это сам)
    user-data = <<-EOF
      #!/bin/bash
      sysctl -w net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      EOF
  }
}

# Публичная ВМ (выход в интернет через собственный nat)
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  platform_id = var.vm_platform_id
  zone        = var.zone

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id  # используем тот же образ Ubuntu 20.04
      size     = var.disk_size_gb
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.ssh_public_key_path)}"
  }
}

# Приватная ВМ (без публичного IP, трафик через NAT)
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = var.vm_platform_id
  zone        = var.zone

  resources {
    cores         = var.vm_resources.cores
    memory        = var.vm_resources.memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id
      size     = var.disk_size_gb
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.ssh_public_key_path)}"
  }
}
