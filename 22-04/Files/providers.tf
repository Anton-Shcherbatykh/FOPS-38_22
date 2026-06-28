terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

# Конфигурация провайдера Yandex Cloud
provider "yandex" {
  token     = var.yc_token     # OAuth-токен (из переменных)
  cloud_id  = var.yc_cloud_id  # ID облака
  folder_id = var.yc_folder_id # ID каталога
  zone      = var.zone         # Зона для ресурсов
}