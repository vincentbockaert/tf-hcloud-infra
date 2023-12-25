resource "hcloud_network" "main" {
  ip_range = "10.0.0.0/16"
  name     = "main-${terraform.workspace}"
  labels = {
    "Environment" = "${terraform.workspace}"
  }
}

resource "hcloud_network_subnet" "shared" {
  ip_range     = "10.0.0.0/24"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_network_subnet" "db" {
  ip_range     = "10.0.1.0/24"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_network_subnet" "app" {
  ip_range     = "10.0.2.0/24"
  network_id   = hcloud_network.main.id
  network_zone = "eu-central"
  type         = "cloud"
}