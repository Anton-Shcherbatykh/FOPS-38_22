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

variable "zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/homework3818.pub"
}

variable "vm_username" {
  description = "Username for VM access"
  type        = string
  default     = "ubuntu"
}

variable "bucket_name" {
  description = "Unique bucket name (only letters, digits, hyphens, dots)"
  type        = string
  default     = "shcherbatykh-22062026"
}

variable "image_local_path" {
  description = "Local path to image file"
  type        = string
  default     = "./mi24.jpg"
}

variable "lamp_image_id" {
  description = "LAMP image ID"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}
