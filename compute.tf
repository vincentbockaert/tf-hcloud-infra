resource "hcloud_server" "k3s_server" {
  count       = local.k3s_server_count
  name        = "server${count.index}.k3s.${terraform.workspace}.hc.vincentbockaert.xyz"
  server_type = "cax11"
  image       = "debian-12"
  datacenter  = "nbg1-dc3"
  user_data   = data.template_cloudinit_config.k3s_server[count.index].rendered
  labels = {
    "Environment" = terraform.workspace
    "Arch"        = "ARM64"
    "NodeNumber"  = count.index
    "k3s"         = "server"
  }
  ssh_keys = [
    hcloud_ssh_key.this.id
  ]
  public_net {
    ipv4_enabled = true # really wish i didnt need this ... but holy f there are too many services IPv4 only and I dont want to a NAT64 service
    ipv6_enabled = true
  }
}

resource "hcloud_server" "k3s_agent" {
  count       = local.k3s_agent_count
  name        = "agent${count.index}.k3s.${terraform.workspace}.hc.vincentbockaert.xyz"
  server_type = "cax11"
  image       = "debian-12"
  datacenter  = "nbg1-dc3"
  user_data   = data.template_cloudinit_config.k3s_agent[count.index].rendered
  labels = {
    "Environment" = terraform.workspace
    "Arch"        = "ARM64"
    "NodeNumber"  = count.index
    "k3s"         = "agent"
  }
  ssh_keys = [
    hcloud_ssh_key.this.id
  ]
  public_net {
    ipv4_enabled = true # really wish i didnt need this ... but holy f there are too many services IPv4 only and I dont want to a NAT64 service
    ipv6_enabled = true
  }
}

resource "hcloud_ssh_key" "this" {
  name       = "default"
  public_key = var.defaultSSHPublicKey
}
