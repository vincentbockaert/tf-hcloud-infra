resource "hcloud_network" "main" {
  ip_range = "10.0.0.0/16"
  name     = "main-${terraform.workspace}"
  labels = {
    "Environment" = "${terraform.workspace}"
  }
}

resource "hcloud_network_subnet" "app" {
  ip_range     = "10.0.0.0/24"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_network_subnet" "k3s" {
  ip_range     = "10.0.1.0/24"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_server_network" "k3s_agent_subnet_attachment" {
  count     = local.k3s_agent_count
  server_id = hcloud_server.k3s_agent[count.index].id
  subnet_id = hcloud_network_subnet.k3s.id
}

resource "hcloud_server_network" "k3s_server_subnet_attachment" {
  count     = local.k3s_server_count
  server_id = hcloud_server.k3s_server[count.index].id
  subnet_id = hcloud_network_subnet.k3s.id
}
