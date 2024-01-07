data "template_cloudinit_config" "k3s_agent" {

  count = local.k3s_agent_count

  part {
    filename     = "node-init.yml"
    content_type = "text/cloud-config"
    content      = data.template_file.k3s_agent[count.index].rendered
  }

  gzip          = true
  base64_encode = true
}

data "template_file" "k3s_agent" {

  count = local.k3s_agent_count

  template = file("cloud-init.yml")

  vars = {
    username            = var.node_ssh_username
    defaultSSHPublicKey = hcloud_ssh_key.this.public_key
    HostCAPrivateKey    = base64encode(tls_private_key.ca_host_key.private_key_openssh)
    HostCAPublicKey     = tls_private_key.ca_host_key.public_key_openssh
    fqdn                = "agent${count.index}.k3s.${terraform.workspace}.hc.vincentbockaert.xyz"
  }
}

data "template_cloudinit_config" "k3s_server" {

  count = local.k3s_server_count

  part {
    filename     = "node-init.yml"
    content_type = "text/cloud-config"
    content      = data.template_file.k3s_server[count.index].rendered
  }

  gzip          = true
  base64_encode = true
}

data "template_file" "k3s_server" {

  count = local.k3s_server_count

  template = file("cloud-init.yml")

  vars = {
    username            = var.node_ssh_username
    defaultSSHPublicKey = hcloud_ssh_key.this.public_key
    HostCAPrivateKey    = base64encode(tls_private_key.ca_host_key.private_key_openssh)
    HostCAPublicKey     = tls_private_key.ca_host_key.public_key_openssh
    fqdn                = "server${count.index}.k3s.${terraform.workspace}.hc.vincentbockaert.xyz"
  }
}