resource "yandex_vpc_network" "task1_network" {
  name        = "vpc-task1"
  description = "VPC for LAMP task"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
