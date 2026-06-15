# Сервисный аккаунт для доступа к Object Storage
resource "yandex_iam_service_account" "storage_sa" {
  name        = "storage-sa"
  description = "Service account for Object Storage"
  folder_id   = var.yc_folder_id
}

# Статический ключ доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
}

# Бакет Object Storage (публичный)
resource "yandex_storage_bucket" "pictures" {
  bucket     = var.bucket_name
  acl        = "public-read"
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
}

# Загрузка картинки в бакет
resource "yandex_storage_object" "image" {
  bucket       = yandex_storage_bucket.pictures.bucket
  key          = "shared-image.jpg"   # имя файла в бакете
  source       = var.image_local_path
  access_key   = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.storage_key.secret_key
  acl          = "public-read"
  depends_on   = [yandex_storage_bucket.pictures]
}