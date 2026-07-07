# Группа для LAMP ВМ
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

# --- Группа для служебного трафика кластера и узлов ---
resource "yandex_vpc_security_group" "k8s_cluster_nodegroup_traffic" {
  name        = "k8s-cluster-nodegroup-traffic"
  description = "Правила для служебного трафика между мастером и узлами, проверки балансировщика, ICMP"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    description       = "Проверки состояния сетевого балансировщика"
    from_port         = 0
    to_port           = 65535
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "Входящий служебный трафик между мастером и узлами"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "ICMP-запросы из внутренних подсетей Yandex Cloud"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    description       = "Исходящий служебный трафик между мастером и узлами"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}

# --- Группа для трафика между подами и сервисами (применяется к узлам) ---
resource "yandex_vpc_security_group" "k8s_nodegroup_traffic" {
  name        = "k8s-nodegroup-traffic"
  description = "Правила для трафика между подами и сервисами, доступ к внешним ресурсам"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    description    = "Трафик между подами и сервисами (CIDR кластера и сервисов)"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["10.96.0.0/16", "10.112.0.0/16"]  # укажите реальные CIDR, которые будут использоваться
  }

  egress {
    description    = "Доступ узлов к внешним ресурсам (реестры, интернет)"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Группа для доступа к сервисам через NodePort (применяется к узлам) ---
resource "yandex_vpc_security_group" "k8s_services_access" {
  name        = "k8s-services-access"
  description = "Правила для доступа к сервисам через NodePort из интернета"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    description    = "NodePort-диапазон"
    from_port      = 30000
    to_port        = 32767
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Группа для SSH-доступа к узлам (применяется к узлам) ---
resource "yandex_vpc_security_group" "k8s_ssh_access" {
  name        = "k8s-ssh-access"
  description = "Правила для SSH-доступа к узлам"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    description    = "SSH из внутренней сети (можно указать IP VM5 или CIDR VPC)"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["192.168.0.0/16", "10.0.0.0/8"]  # разрешаем из всей VPC
  }
}

# --- Группа для доступа к API Kubernetes (применяется к кластеру) ---
resource "yandex_vpc_security_group" "k8s_cluster_traffic" {
  name        = "k8s-cluster-traffic"
  description = "Правила для доступа к API Kubernetes"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    description    = "Доступ к API (порт 443)"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["192.168.0.0/16", "10.0.0.0/8"]  # доступ из VPC
  }

  ingress {
    description    = "Доступ к API (порт 6443)"
    port           = 6443
    protocol       = "TCP"
    v4_cidr_blocks = ["192.168.0.0/16", "10.0.0.0/8"]
  }

  egress {
    description    = "Трафик к metric-server (CIDR кластера)"
    port           = 4443
    protocol       = "TCP"
    v4_cidr_blocks = ["10.96.0.0/16"]
  }
}
