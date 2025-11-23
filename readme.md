# Weebify infra (virtualization)

[App repo](https://github.com/Serial-Experiments-Weebify/weebify/tree/devops) | 
[Encodeher repo](https://github.com/Serial-Experiments-Weebify/encodeher) 

## Intoduction

This repo contains IaC for deploying weebify in two different local VM setups.
It requires a Host running Ubuntu (ideally 24.04).

## Setup

Before we get depoying we need to set up our host.

Install dependencies...

```bash
sudo apt install -y snapd git make caddy gcc qemu-kvm ebtables virtiofsd libvirt-dev libvirt-clients libvirt-daemon-system ruby-fog-libvirt libguestfs-tools libxslt-dev libxml2-dev zlib1g-dev ruby-dev
sudo systemctl enable --now snapd
sudo snap install multipass
```

Clone this repo...

```bash
git clone https://github.com/Serial-Experiments-Weebify/infra-vm.git
cd infra-vm
```

Add yourself to the `libvirt` group...

```bash
sudo usrmod -aG libvirt $USER
```

Install Vagrant...

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

Install the libvirt plugin for Vagrant...

```bash
vagrant plugin install vagrant-libvirt
```

Now decide on domains you want to use for the deployment I suggest you pick something like:

```plain
multipass.<domain>
s3.multipass.<domain>
vagrant.<domain>
s3.vagrant.<domain>
```

Make sure all point to the host's public IP.
Then copy the `Caddyfile` to `/etc/caddy/Caddyfile` and fix the domain names.

Start caddy with

```bash
sudo systemctl enable --now caddy
```

## Multipass / Cloud-init

For cloud-init we use `multipass` because it is the most trivial to set up.

We use a bash script to add includes (`##include <file>`) to `cloud-config.yml`.

### Deploy

1. Apply the weebnet.yaml with `netplan` (copy to `/etc/netplan/` first).
   This sets up a bridge network interface for multipass to use.

2. Copy `.env.example` file in `./multipass/files/` to `.env` and modify it. For domain use the full domain name without the `s3.` prefix (e.g. multipass.weebify.tv).

3. From `./multipass/` run `make up`.

4. Run `make shell` and verify all 7 containers are running with `docker ps`.

5. Proceed to test scenario below.

## Vagrant

We use libvirt so it can live alogside multipass.

### Deploy

1. Copy `.env.example` file in `./vagrant/weebify/` to `.env` and modify it. For domain use the full domain name without the `s3.` prefix (e.g. vagrant.weebify.tv).

2. Run `vagrant up` from `./vagrant/`.

3. Run `vagrant ssh weebify` and verify all 7 containers are running with `docker ps`.

4. Proceed to test scenario below.

## Test scenario

- Open configured domain in browser
- Login with configured admin user
- Rebuild search indices and generate an API key
- Create a show/movie
- Upload a cover image (and set your PFP)
- Try uploading a video using [encodeher](https://github.com/Serial-experiments-weebify/encodeher).
- Try searching for the show/movie.
- Link the video to an episode & try playing it back

## Docker stack

Both setups just spin up two docker stacks. One for Traefik and one for Weebify.

### `mongo`

The MongoDB instance for weebify. Has a relatively simple init script to create the admin user.

### `meili`

Meilisearch (search engine/db) for weebify. Exposed on `/api/search`.

### `minio`

S3 compatible object storage. Should probably used garage/seaweedfs instead. Exposed on `s3.` subdomain.

### `minioinit`

Runs initialization script for minio to create the required buckets.

### `backend`

Main API, exposes `/graphql` endpoint.

### `media`

REST api for manipulating images/videos/... . Exposed on `/api/media`.

### `frontend`

Vue SPA served with `nginx`. Exposed as default route.
