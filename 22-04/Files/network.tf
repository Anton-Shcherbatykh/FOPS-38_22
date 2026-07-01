# Сеть VPC
resource "yandex_vpc_network" "task1_network" {
  name        = "vpc-task1"
  description = "VPC for LAMP task"
}

# Публичные подсети для Kubernetes (зоны a, b, e)
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "public_e" {
  name           = "public-e"
  zone           = "ru-central1-e"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.50.0/24"]
}

# Приватные подсети для MySQL (зоны a, b)
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["10.20.0.0/24"]
}
