locals {
  vault-map = zipmap(lxd_container.vault.*.id, lxd_container.vault.*.ipv4_address)
}

terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "1.5.0"
    }
  }
}

resource "lxd_container" "vault" {
  count     = var.vault-count
  name      = "${format("vault%02d", count.index + 1)}-${var.dc-role}"
  image     = "packer-vault"
  ephemeral = false
  profiles  = [var.lxd-profile]

  config = {
    "user.user-data" = templatefile("${path.module}/cloud-init.tpl", {
      dc            = var.dc-name,
      iface         = "eth0",
      consul_server = "consul01-${var.dc-role}",
      license = var.license
      }
    )
  }

}

output "hosts" {
  value = local.vault-map
}
