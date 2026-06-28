# Public для зоны a
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Public для зоны b
resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

# Public для зоны d
resource "yandex_vpc_subnet" "public_d" {
  name           = "public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["192.168.40.0/24"]   # новый диапазон, не пересекается с другими
}

# Private для зоны a (MySQL)
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

# Private для зоны b (MySQL)
resource "yandex_vpc_subnet" "private_b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.task1_network.id
  v4_cidr_blocks = ["10.20.0.0/24"]
}