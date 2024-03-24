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

Using the excellent k3s-ansible repo we can install k3s in HA method.
We can clone the repo: `git clone https://github.com/k3s-io/k3s-ansible.git`

Once cloned, making a copy of inventory-samply.yml and naming it inventory.yml.
Replacing the servers.hosts IP's with ours.

With hetzner I'd like to use the Hetzner Cloud Controller, so I'll the disable the provided one as well as disable traefik since I'll Nginx Ingress instead.
To do so, we need to add some server_args. 

TLDR the inventory.yml should like the below:

```yaml
---
k3s_cluster:
  children:
    server:
      hosts:
        '2a01:4f8:1c1e:93d1::1'
        '2a01:4f8:c2c:9877::1'
        '2a01:4f8:c2c:c272::1'
    agent:
      hosts:
        # 192.16.35.12:
        # 192.16.35.13:

  # Required Vars
  vars:
    ansible_port: 22
    ansible_user: poweruser
    k3s_version: v1.28.7+k3s1
    token: 'someSuperSecretTokenHere'
    api_endpoint: 10.0.1.1 # internal IP of first server host
    extra_server_args: '--disable-cloud-controller --flannel-iface=ens10 --kubelet-arg="cloud-provider=external" --secrets-encryption --disable=traefik --tls-san="server0.k3s.prod.techheresy.com" --tls-san="server1.k3s.prod.techheresy.com" --tls-san="server2.k3s.prod.techheresy.com" --tls-san="master.k3s.prod.techheresy.com"'
    extra_agent_args: ""
```

Then we run the playbook:

```shell
# using k3s-ansible
ansible-playbook -u poweruser -i inventory.yml --private-key ~/.ssh/hcloud.key playbook/site.yml
```

Lastly, you can verify the nodes on the server machine:

```bash
sudo kubectl get nodes
# can fetch a starting kubeconfig:
sudo cat /etc/rancher/k3s/k3s.yaml
```

Which should return something similar to the below:

![](img/k3s-nodes.png)