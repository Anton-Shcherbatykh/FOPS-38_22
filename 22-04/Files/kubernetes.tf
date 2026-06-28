# Сервис-аккаунт для Kubernetes
resource "yandex_iam_service_account" "k8s_sa" {
  name        = "k8s-service-account"
  folder_id   = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_k8s_agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_compute_admin" {
  folder_id = var.yc_folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

# Региональный кластер Kubernetes
resource "yandex_kubernetes_cluster" "regional" {
  name        = "netology-k8s-regional"
  description = "Regional Kubernetes cluster"
  network_id  = yandex_vpc_network.task1_network.id

  master {
    regional {
      region = "ru-central1"
      location {
        zone      = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.public.id
      }
      location {
        zone      = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.public_b.id
      }
      location {
        zone      = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.public_d.id
      }
    }
    public_ip = true
    security_group_ids = [yandex_vpc_security_group.k8s_api_sg.id]
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  kms_provider {
    key_id = yandex_kms_symmetric_key.bucket_key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_sa_editor,
    yandex_resourcemanager_folder_iam_member.k8s_sa_k8s_agent,
    yandex_resourcemanager_folder_iam_member.k8s_sa_compute_admin,
  ]
}

# Группа узлов с автомасштабированием 3–6
resource "yandex_kubernetes_node_group" "main" {
  cluster_id = yandex_kubernetes_cluster.regional.id
  name       = "main-node-group"
  description = "Main node group with autoscaling (3–6 nodes)"

  allocation_policy {
    location {
      zone      = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
    location {
      zone      = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public_b.id
    }
    location {
      zone      = "ru-central1-d"
      subnet_id = yandex_vpc_subnet.public_d.id
    }
  }

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 4
    }
    boot_disk {
      size = 50
      type = "network-ssd"
    }
    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.public.id,
        yandex_vpc_subnet.public_b.id,
        yandex_vpc_subnet.public_d.id
      ]
      nat = true
      security_group_ids = [yandex_vpc_security_group.k8s_api_sg.id]
    }
    metadata = {
      ssh-keys = "${var.vm_username}:${file(var.ssh_public_key_path)}"
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }
}