resource "yandex_iam_service_account" "storage_sa" {
  name        = "storage-sa"
  folder_id   = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  depends_on         = [yandex_resourcemanager_folder_iam_member.storage_editor]
}

resource "yandex_storage_bucket" "bucket" {
  bucket      = var.bucket_name
  access_key  = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key  = yandex_iam_service_account_static_access_key.storage_key.secret_key
  folder_id   = var.yc_folder_id
  anonymous_access_flags {
    read = true
  }
  depends_on = [yandex_resourcemanager_folder_iam_member.storage_editor]
}

resource "yandex_storage_object" "image" {
  bucket       = yandex_storage_bucket.bucket.bucket
  key          = "mi24.jpg"
  source       = var.image_local_path
  content_type = "image/jpeg"
  access_key   = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.storage_key.secret_key
  depends_on   = [yandex_storage_bucket.bucket]
}
