# VPC для тестового задания
resource "yandex_vpc_network" "task1_network" {
  name        = "vpc-task1"
  description = "VPC for NAT task"
}

# Публичная подсеть 192.168.10.0/24
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Таблица маршрутов: весь трафик из приватной сети через NAT-инстанс
resource "yandex_vpc_route_table" "private_route" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.task1_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# Приватная подсеть 192.168.20.0/24 с привязанной таблицей маршрутов
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_route.id
}
