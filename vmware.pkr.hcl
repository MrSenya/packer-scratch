packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso_url" {
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
}

variable "iso_checksum" {
  default = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
}

source "vmware-iso" "ubuntu" {
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  vm_name            = "ubuntu-autoinstall"
  guest_os_type      = "ubuntu-64"
  disk_size          = 10000
  memory             = 2048
  cpus               = 2
  headless           = false
  ssh_username       = "ubuntu"
  ssh_password       = "ubuntu"
  ssh_timeout        = "35m"
  version            = "17"
  format             = "ova"

  boot_command = [
    "<esc><wait><esc><wait>",
    "<f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]
  boot_wait = "5s"

  http_directory     = "http"
  shutdown_command   = "echo 'ubuntu' | sudo -S shutdown -P now"
  output_directory   = "output-vmware"
}

build {
  name = "ubuntu-server-focal"
  sources = ["source.vmware-iso.ubuntu"]
}
