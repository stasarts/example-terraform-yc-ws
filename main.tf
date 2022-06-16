# Provider
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

resource "yandex_vpc_network" "net" {
  name = local.network_names[terraform.workspace]
}

resource "yandex_vpc_subnet" "subnet" {
  name           = local.subnet_names[terraform.workspace]
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.3.0.0/16"]
  zone           = var.yc_region
}

module "yc_instance_count" {
  source = "./modules/instance/"
  instance_count = local.yc_instance_count[terraform.workspace]
  cores         = local.yc_cores[terraform.workspace]
  memory        = local.yc_memory[terraform.workspace]
  core_fraction = local.yc_core_fraction[terraform.workspace]
  disk_size     = local.yc_disk_size[terraform.workspace]
  subnet_id     = resource.yandex_vpc_subnet.subnet.id
  description   = "instance depends on workspace by count"
}

module "yc_instance_for_each" {
  source        = "./modules/instance/"
  for_each      = local.for_each_map[terraform.workspace]
  name          = "${each.key}-netology-vm-foreach"
  cores         = local.yc_cores[terraform.workspace]
  memory        = local.yc_memory[terraform.workspace]
  core_fraction = local.yc_core_fraction[terraform.workspace]
  disk_size     = local.yc_disk_size[terraform.workspace]
  subnet_id     = resource.yandex_vpc_subnet.subnet.id
  description   = "instance depends on workspace by for_each"
}

locals {
  yc_instance_count = {
    stage = 1
    prod  = 2
  }
  yc_cores = {
    stage = 2
    prod  = 4
  }
  yc_memory = {
    stage = 4
    prod  = 8
  }
  yc_core_fraction = {
    stage = 20
    prod  = 100
  }
  yc_disk_size = {
    stage = 20
    prod  = 40
  }
  for_each_map = {
    stage = toset(["s1"])
    prod  = toset(["p1", "p2"])
  }
  network_names = {
    stage = "stage-netology-network"
    prod  = "prod-netology-network"
  }
  subnet_names = {
    stage = "stage-netology-subnet"
    prod  = "prod-netology"
  }
}
