variable image { default =  "ubuntu-2004-lts" }
variable name { default = "netology-vm-count"}

variable instance_count { default = 1 }
variable count_format { default = "%01d" } #server number format (-1, -2, etc.)
variable count_offset { default = 0 } #start numbering from X+1 (e.g. name-1 if '0', name-3 if '2', etc.)
variable platform_id { default = "standard-v1"}
variable description { default =  "instance from terraform" }
variable zone { default =  "" }
variable folder_id { default =  "" }

variable cores { default = "2" }
variable memory { default = "4" }
variable core_fraction { default = "20" }

variable boot_disk { default =  "network-hdd" }
variable disk_size { default =  "20" }

variable subnet_id { default = "" }
variable nat { default = "true" }
variable ipv6 { default = "false" }

variable users { default = "ubuntu" }

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.75.0"
    }
  }
}

data "yandex_compute_image" "image" {
  family = var.image
}

resource "yandex_compute_instance" "instance" {
  count = var.instance_count
  name = "${terraform.workspace}-${format(var.count_format, var.count_offset+count.index+1)}-${var.name}"
  platform_id = var.platform_id
  hostname = "${var.name}-${format(var.count_format, var.count_offset+count.index+1)}"
  description = var.description
  zone = var.zone
  folder_id = var.folder_id

  resources {
    cores  = var.cores
    memory = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type = var.boot_disk
      size = var.disk_size
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
    ipv6      = var.ipv6
  }

  metadata = {
    ssh-keys = "${var.users}:${file("~/.ssh/id_rsa.pub")}"
  }
}
