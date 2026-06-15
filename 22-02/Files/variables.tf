# --- Обязательные переменные ---
variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

# --- Переменные с значениями по умолчанию ---
variable "zone" {
  description = "Default availability zone for resources"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key file (e.g., ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/homework3818.pub"
}

variable "vm_username" {
  description = "Username for VM access"
  type        = string
  default     = "ubuntu"
}

variable "vm_platform_id" {
  description = "Platform ID for the VM"
  type        = string
  default     = "standard-v2"
}

variable "vm_resources" {
  description = "VM resource configuration"
  type = object({
    cores  = number
    memory = number
  })
  default = {
    cores  = 2
    memory = 4
  }
}

variable "disk_size_gb" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 50
}

# --- Переменные для Object Storage и Instance Group ---
variable "nat_image_id" {
  description = "Image ID for NAT instance"
  type        = string
  default     = "fd80d6qre4g7vq3b0bnp"   # актуальный ID образа NAT-instance
}

variable "disk_type" {
  description = "Disk type for VMs"
  type        = string
  default     = "network-hdd"
}

variable "lamp_image_id" {
  description = "LAMP image ID from Yandex Cloud Marketplace"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}

variable "bucket_name" {
  description = "Object Storage bucket name (должен быть глобально уникальным)"
  type        = string
  default     = "shcherbatykh-netology"   # замените на своё уникальное имя
}

variable "image_local_path" {
  description = "Local path to image file (например, ./image.jpg)"
  type        = string
  default     = "./image.jpg"
}
