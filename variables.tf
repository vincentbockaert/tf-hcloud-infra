variable "node_ssh_username" {
  type    = string
  default = "poweruser"
}

variable "defaultSSHPublicKey" {
  type = string
  # export TF_VAR_defaultSSHPublicKey=$(cat ~/.ssh/id_ed25519.pub)
}