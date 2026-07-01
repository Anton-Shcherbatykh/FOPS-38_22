# Генерация случайного пароля
resource "random_password" "mysql" {
  length  = 16
  special = false
}

# Кластер MySQL
resource "yandex_mdb_mysql_cluster" "netology" {
  name        = "netology-mysql-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.task1_network.id
  version     = "8.0"

  resources {
    resource_preset_id = "b2.medium"   # Intel Broadwell, 50% vCPU
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private_a.id
  }
  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private_b.id
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  deletion_protection = true
  maintenance_window {
    type = "ANYTIME"
  }

  security_group_ids = [yandex_vpc_security_group.mysql_sg.id]

  mysql_config = {
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }
}

# База данных
resource "yandex_mdb_mysql_database" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology.id
  name       = "netology_db"
}

# Пользователь
resource "yandex_mdb_mysql_user" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology.id
  name       = "netology_user"
  password   = random_password.mysql.result

  permission {
    database_name = yandex_mdb_mysql_database.netology.name
    roles         = ["ALL"]
  }
}
