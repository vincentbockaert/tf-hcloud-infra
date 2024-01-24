# tf-hcloud-infra

This repository houses the infrastructure provisioning on hetzner cloud through Hashicorp Terraform,
with a GCS bucket being used to store the terraform state.

Currently, using it for a self-managed Kubernetes cluster (k3s) with Hetzner Cloud Load Balancer.

There's not a lot to see, as Hetzner is pretty barebones, but in return you get very good price-to-performance and a lot of freedom to do what you want.

![](img/itaintmuch.webp)

Out of the gate I have the following provisioned:
- vpc
    - kind of ... there's no NAT Gateway like in aws but I'm okay with that because of IPv6 public connectivity
- subnet splitting
- couple o' servers 
- cloud-init
    - pre-config the servers with dedicated sudo user
    - configure ***ssh ca certificates*** for Trusted Host Keys (so cool bro, no more fingerprint prompting)

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

## k3s

First time setup on first k3s **server**:

```bash
curl -sfL https://get.k3s.io | sh -s - server \
--cluster-init \
--disable-cloud-controller \
--node-name="$(hostname -f)" \
--flannel-iface=enp7s0 \
--kubelet-arg="cloud-provider=external" \
--secrets-encryption \
--disable=traefik \
--tls-san='server0.k3s.prod.hc.vincentbockaert.xyz' \
--tls-san='server1.k3s.prod.hc.vincentbockaert.xyz' \
--tls-san='server2.k3s.prod.hc.vincentbockaert.xyz' \
--tls-san='master.k3s.prod.hc.vincentbockaert.xyz' \
--token='SECRET_HERE'
```

then to add other server nodes:

```bash
curl -sfL https://get.k3s.io | sh -s - server \
	--server https://PRIVATE_IP_OF_FIRST_SERVER_NODE:6443 \
    --disable-cloud-controller \
    --node-name="$(hostname -f)" \
    --flannel-iface=enp7s0 \
    --kubelet-arg="cloud-provider=external" \
    --secrets-encryption \
    --disable=traefik \
    --tls-san='server0.k3s.prod.hc.vincentbockaert.xyz' \
    --tls-san='server1.k3s.prod.hc.vincentbockaert.xyz' \
    --tls-san='server2.k3s.prod.hc.vincentbockaert.xyz' \
    --tls-san='master.k3s.prod.hc.vincentbockaert.xyz' \
    --token='SERVER_HERE'
```

Lastly, you can verify the nodes on the server machine:

```bash
sudo kubectl get nodes
# can fetch a starting kubeconfig:
sudo cat /etc/rancher/k3s/k3s.yaml
```

Which should return something similar to the below:

![](img/k3s-nodes.png)