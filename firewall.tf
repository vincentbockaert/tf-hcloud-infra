resource "hcloud_firewall" "k3s_server" {
  name = "k3s server inbound"
  // ssh from anywhere
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  // ha embedded etcd, source from k3s servers
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "2379-2380"
    source_ips = [for network_attachment in hcloud_server_network.k3s_server_subnet_attachment : "${network_attachment.ip}/32"]
  }
  // k3s supervisor and api server, source from k3s agent
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = [for network_attachment in hcloud_server_network.k3s_agent_subnet_attachment : "${network_attachment.ip}/32"]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "${hcloud_load_balancer_network.lb_kube.ip}/32"
    ]
  }
  // kubelet metrics. source from all k3s nodes
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = concat(
      [for network_attachment in hcloud_server_network.k3s_agent_subnet_attachment : "${network_attachment.ip}/32"],
      [for network_attachment in hcloud_server_network.k3s_server_subnet_attachment : "${network_attachment.ip}/32"]
    )
  }
  // flannel wireguard with ipv4-ipv6, source from all k3s nodes
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "51820-51821"
    source_ips = concat(
      [for network_attachment in hcloud_server_network.k3s_agent_subnet_attachment : "${network_attachment.ip}/32"],
      [for network_attachment in hcloud_server_network.k3s_server_subnet_attachment : "${network_attachment.ip}/32"]
    )
  }
}

resource "hcloud_firewall" "k3s_agent" {
  name = "k3s agent inbound"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  // kubelet metrics. source from all k3s nodes
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = concat(
      [for network_attachment in hcloud_server_network.k3s_agent_subnet_attachment : "${network_attachment.ip}/32"],
      [for network_attachment in hcloud_server_network.k3s_server_subnet_attachment : "${network_attachment.ip}/32"]
    )
  }
  // flannel wireguard with ipv4-ipv6, source from all k3s nodes
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "51820-51821"
    source_ips = concat(
      [for network_attachment in hcloud_server_network.k3s_agent_subnet_attachment : "${network_attachment.ip}/32"],
      [for network_attachment in hcloud_server_network.k3s_server_subnet_attachment : "${network_attachment.ip}/32"]
    )
  }
}

# Note: only one hcloud_firewall_attachment per Firewall is allowed.
# Any resources that should be attached to that Firewall need to be specified in that hcloud_firewall_attachment.
resource "hcloud_firewall_attachment" "k3s_server" {
  firewall_id = hcloud_firewall.k3s_server.id
  server_ids  = [for node in hcloud_server.k3s_server : node.id]
}

resource "hcloud_firewall_attachment" "k3s_agent" {
  firewall_id = hcloud_firewall.k3s_agent.id
  server_ids  = [for node in hcloud_server.k3s_agent : node.id]
}