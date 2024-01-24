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
  
  apply_to {
    # https://docs.hetzner.cloud/#label-selector
    label_selector = "k3s=server"
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

  apply_to {
    # https://docs.hetzner.cloud/#label-selector
    label_selector = "k3s=agent"
  }
}

