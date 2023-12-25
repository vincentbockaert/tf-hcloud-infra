terraform {

  required_version = "~> 1.6.4"

  backend "gcs" {
    bucket = "terraform-state-2b8908ba"
    prefix = "tf-hcloud-networking"
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "hcloud" {
  # Configuration options
}

provider "tls" {}
provider "template" {}
