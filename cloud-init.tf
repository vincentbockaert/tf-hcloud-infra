data "template_cloudinit_config" "node_init" {

  count = local.nr_nodes

  part {
    filename = "node-init.yml"
    content_type = "text/cloud-config"
    content = data.template_file.node_init[count.index].rendered
  }

  gzip = true
  base64_encode = true
}

data "template_file" "node_init" {

  count = local.nr_nodes

  template = "${file("cloud-init.yml")}"

  vars = {
    username = var.node_ssh_username
    ssh_authorized_key = hcloud_ssh_key.this.public_key
    HostCAPrivateKey = base64encode(tls_private_key.ca_host_key.private_key_openssh)
    HostCAPublicKey = tls_private_key.ca_host_key.public_key_openssh
    fqdn = "${count.index}.node.${terraform.workspace}.hc.vincentbockaert.xyz"
  }
}