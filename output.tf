output "ca_host_key" {
  value = "Host Key CA Public key: ${tls_private_key.ca_host_key.public_key_openssh}"
}

output "ca_host_key_command_to_use_in_client" {
  value = "To make use of the Host Key CA in your ssh client, use the command: echo '@cert-authority * ${tls_private_key.ca_host_key.public_key_openssh}' >> ~/.ssh/known_hosts"
}

output "server_names" {
  value = concat(
    [for node in hcloud_server.k3s_server : "${node.name} ==> AAA ==> ${node.ipv6_address}"],
    [for node in hcloud_server.k3s_server : "${node.name} ==> A ==> ${node.ipv4_address}"],
    [for node in hcloud_server.k3s_agent : "${node.name} ==> AAA ==> ${node.ipv6_address}"],
    [for node in hcloud_server.k3s_agent : "${node.name} ==> A ==> ${node.ipv4_address}"]
  )
}

output "load_balancer_addresses" {
  value = [hcloud_load_balancer.lb.ipv4, hcloud_load_balancer.lb.ipv6]
}