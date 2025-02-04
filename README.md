# Ubuntu Server Automated Installation with Packer and VMware

## Overview
This project automates the installation of Ubuntu Server using **Packer** with the **VMware** provider. It leverages **cloud-init** for configuration and installs essential packages.

## Prerequisites
Ensure you have the following installed before running the build:
- [Packer](https://developer.hashicorp.com/packer) (>=1.7)
- VMware Workstation or VMware Fusion
- Internet access to download the Ubuntu ISO

## Project Structure
```
/
├── vmware.pkr.hcl      # Packer configuration file
├── http/
│   ├── user-data       # Cloud-init configuration for automated install
│   ├── meta-data       # Empty meta-data file required for cloud-init
└── output-vmware/      # Output directory for the built VM image
```

## Configuration Files
### `vmware.pkr.hcl`
This is the main **Packer** configuration file. It defines:
- **ISO source**: Ubuntu 20.04 server installation image.
- **VM settings**: Disk size, memory, CPU, and guest OS type.
- **Boot commands**: Used to trigger the automated install.
- **Cloud-init setup**: The VM fetches its configuration from the `http/` directory.

### `http/user-data`
Cloud-init file for **Ubuntu Server** installation. It configures:
- Hostname: `ubuntu-server`
- User: `ubuntu` (password: `ubuntu` encrypted with SHA-512)
- LVM partitioning
- SSH server installation and activation
- Additional package installation (`nano`)
- Auto-updates and SSH service enablement

### `http/meta-data`
Required by cloud-init but remains empty.

## How to Use
1. Run Packer to build the VM:
   ```sh
   packer init .
   packer build .
   ```
2. After completion, the VM image will be available in the `output-vmware/` directory.

## Comments on `vmware.pkr.hcl`
```hcl
packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}
```
This section defines that **Packer** requires the `vmware` plugin from HashiCorp.

```hcl
variable "iso_url" {
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
}
```
Defines the URL of the Ubuntu 20.04 ISO.

```hcl
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
```
Defines the VM parameters like disk size, memory, CPU, SSH settings, and output format (`OVA`).

```hcl
boot_command = [
  "<esc><wait><esc><wait>",
  "<f6><wait><esc><wait>",
  "<bs><bs><bs><bs><bs>",
  "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
  "--- <enter>"
]
```
Defines the boot sequence, which automatically starts the Ubuntu installer with cloud-init.

```hcl
shutdown_command   = "echo 'ubuntu' | sudo -S shutdown -P now"
```
Gracefully shuts down the VM after installation.

```hcl
build {
  name = "ubuntu-server-focal"
  sources = ["source.vmware-iso.ubuntu"]
}
```
Defines the **Packer** build name and source.

## Notes
- Ensure **VMware Workstation** or **Fusion** is running before executing the build.
- Modify `http/user-data` if you need custom configurations.
- The output VM can be deployed in VMware environments.

## License
MIT License

