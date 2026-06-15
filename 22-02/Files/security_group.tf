# Группа безопасности для Instance Group (HTTP + SSH)
resource "yandex_vpc_security_group" "lamp_sg" {
  name        = "lamp-instance-sg"
  description = "Allow HTTP and SSH for LAMP instances"
  network_id  = yandex_vpc_network.task1_network.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
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