output "ca_host_key" {
  value = "Host Key CA Public key: ${tls_private_key.ca_host_key.public_key_openssh}"
}

output "ca_host_key_command_to_use_in_client" {
  value = "To make use of the Host Key CA in your ssh client, use the command: echo '@cert-authority * ${tls_private_key.ca_host_key.public_key_openssh}' >> ~/.ssh/known_hosts"
}