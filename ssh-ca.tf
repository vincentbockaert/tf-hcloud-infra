resource "tls_private_key" "ca_host_key" {
  algorithm = "ED25519" # most modern, RSA and ECDSA can also be used
}

resource "tls_private_key" "ca_user_key" {
  algorithm = "ED25519" # most modern, RSA and ECDSA can also be used
}