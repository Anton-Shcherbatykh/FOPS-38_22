# Сервисный аккаунт для Object Storage
resource "yandex_iam_service_account" "storage_sa" {
  name        = "storage-sa"
  folder_id   = var.yc_folder_id
}

# Назначение роли storage.editor
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  depends_on         = [yandex_resourcemanager_folder_iam_member.storage_editor]
}

# Бакет Object Storage
resource "yandex_storage_bucket" "bucket" {
  bucket      = var.bucket_name
  access_key  = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key  = yandex_iam_service_account_static_access_key.storage_key.secret_key
  folder_id   = var.yc_folder_id
  anonymous_access_flags {
    read = true
  }

# Блок для шифрования
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_editor
    yandex_kms_symmetric_key_iam_member.key_encrypter
  ]
}

# Добавляем ресурс для создания ключа KMS
resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "shcherbatykh-bucket-key"
  description       = "KMS key for bucket encryption (Homework: "Security in Cloud Providers")"
  default_algorithm = "AES_256"
  rotation_period   = "4383h" # 1/2 года
}

# Назначаем права сервисному аккаунту на использование ключа KMS
resource "yandex_kms_symmetric_key_iam_member" "key_encrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.bucket_key.id
  role             = "kms.keys.encrypterDecrypter"
  member           = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Загрузка картинки
resource "yandex_storage_object" "image" {
  bucket       = yandex_storage_bucket.bucket.bucket
  key          = "mi24.jpg"
  source       = var.image_local_path
  access_key   = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.storage_key.secret_key
  depends_on   = [yandex_storage_bucket.bucket]
}