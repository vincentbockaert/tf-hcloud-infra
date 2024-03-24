resource "hcloud_server" "k3s_server" {
  count       = local.k3s_server_count
  name        = "server${count.index}.k3s.${terraform.workspace}.${var.base_domain}"
  server_type = "cx21"
  image       = "debian-12"
  datacenter  = "nbg1-dc3"
  user_data   = data.template_cloudinit_config.k3s_server[count.index].rendered
  labels = {
    "Environment" = terraform.workspace
    "k3s"         = "server"
  }
  ssh_keys = [
    hcloud_ssh_key.this.id
  ]
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }
  placement_group_id = hcloud_placement_group.placement_group.id
}

resource "hcloud_server" "k3s_agent" {
  count       = local.k3s_agent_count
  name        = "agent${count.index}.k3s.${terraform.workspace}.${var.base_domain}"
  server_type = "cx21"
  image       = "debian-12"
  datacenter  = "nbg1-dc3"
  user_data   = data.template_cloudinit_config.k3s_agent[count.index].rendered
  labels = {
    "Environment" = terraform.workspace
    "k3s"         = "agent"
  }
  ssh_keys = [
    hcloud_ssh_key.this.id
  ]
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }
  placement_group_id = hcloud_placement_group.placement_group.id
}

resource "hcloud_ssh_key" "this" {
  name       = "default"
  public_key = var.defaultSSHPublicKey
}

resource "hcloud_placement_group" "placement_group" {
  name = "server-placement-group"
  type = "spread"
}
