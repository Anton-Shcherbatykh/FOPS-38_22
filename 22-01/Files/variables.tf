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

# --- Переменные со значениями по умолчанию ---
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
