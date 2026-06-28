# Группа безопасности для Instance Group (HTTP + SSH)
resource "yandex_vpc_security_group" "lamp_sg" {
  name        = "lamp-instance-sg"
  description = "Allow HTTP from internet and SSH from anywhere"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Группа для MySQL (доступ только изнутри VPC)
resource "yandex_vpc_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Allow MySQL access from inside VPC"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    protocol       = "TCP"
    description    = "MySQL from VPC"
    v4_cidr_blocks = ["192.168.0.0/16", "10.0.0.0/8"]
    port           = 3306
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Группа для доступа к Kubernetes API из интернета
resource "yandex_vpc_security_group" "k8s_api_sg" {
  name        = "k8s-api-sg"
  description = "Allow Kubernetes API access from internet"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  egress {
    protocol       = "ANY"
    description    = "All outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
