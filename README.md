# tf-hcloud-infra

This repository houses the infrastructure provisioning on hetzner cloud through Hashicorp Terraform,
with a GCS bucket being used to store the terraform state.

There's not a lot to see, as Hetzner is pretty barebones, but in return you get very good price-to-performance and a lot of freedom to do what you want.

![](img/itaintmuch.webp)

Out of the gate I have the following provisioned:
- vpc
    - kind of ... there's no NAT Gateway like in aws but I'm okay with that because of IPv6 public connectivity
    - will allow ingress for https traffic only from cloudflare trusted ip ranges in the future
- subnet splitting
    - 3 subnets:
        - app
        - db
        - shared, i.e. a bastionhost
- couple o' servers 
- cloud-init
    - pre-config the servers with dedicated sudo user
    - configure ***ssh ca certificates*** for Trusted Host Keys

## Prerequisites

- hetzner cloud account and project
- gcs bucket (optional as you could use local state or other remote)
    - if using gcs bucket, gcloud cli
- .env file with your a API token for your hetzner cloud project
    - I use 1Password credential referencing in the file, other tools like [sops](https://github.com/getsops/sops) exists that offer something close/similar

## Getting started

```bash
op run --env-file .env -- terraform init
op run --env-file .env -- terraform plan -out plan.out
# if plan looks good, apply:
op run --env-file .env -- terraform apply plan.out
```