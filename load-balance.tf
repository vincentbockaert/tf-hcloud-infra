resource "hcloud_load_balancer" "lb" {
  load_balancer_type = "lb11"
  location           = "nbg1"
  name               = "lb"
}

resource "hcloud_load_balancer_service" "kube_api" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp" // http, https or tcp

  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_target" "kube_api" {
  load_balancer_id = hcloud_load_balancer.lb.id
  type             = "label_selector"
  label_selector   = "k3s=server"
  use_private_ip   = true // kinda surprised this is not required ... it's false by default (undocumented though)
}

# attach the load balancer to the same subnet as the VMs mean for kubernetes
resource "hcloud_load_balancer_network" "lb_kube" {
  load_balancer_id = hcloud_load_balancer.lb.id
  subnet_id        = hcloud_network_subnet.k3s.id
}