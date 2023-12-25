locals {
  nr_nodes = 1
}

resource "hcloud_server" "nodes" {
  count = local.nr_nodes
  name        = "${count.index}.node.${terraform.workspace}"
  server_type = "cax11"
  image = "debian-12"
  datacenter = "nbg1-dc3"
  # ssh keys are defined in cloud-init.yml
  user_data = data.template_cloudinit_config.node_init[count.index].rendered
  labels = {
    "Environment" = "${terraform.workspace}"
    "Arch"        = "ARM64"
    "NodeNumber" = count.index
  }
  ssh_keys = [
    hcloud_ssh_key.this.id
  ]
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }
}

resource "hcloud_server_network" "node_to_app_subnet" {
  count = local.nr_nodes
  server_id = hcloud_server.nodes[count.index].id
  subnet_id = hcloud_network_subnet.app.id
}


# Note: only one hcloud_firewall_attachment per Firewall is allowed.
# Any resources that should be attached to that Firewall need to be specified in that hcloud_firewall_attachment.
resource "hcloud_firewall_attachment" "default" {
  firewall_id = hcloud_firewall.default.id
  server_ids = [for node in hcloud_server.nodes : node.id ]
}

resource "hcloud_ssh_key" "this" {
  name       = "default"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyHJ7HgSuYlsEiH2wgdnphn5vafhlPUKR8P7YKaJ+28"
}

