terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-avt0m8-bucket"
    region     = "ru-central1"
    key        = "yc-avt0m8.tfstate"
    access_key = <yc-service-account-access-key>
    secret_key = <yc-service-account-secret-key>

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}