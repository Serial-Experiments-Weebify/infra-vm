# Weebify infra (Docker)

Docker compose files for deploying Weebify using Docker Compose.

## Setup

Ensure your host has a recent version of Docker CE. OpenSSL is required for generating secrets (optional).

Clone this repo

```bash
git clone https://github.com/Serial-Experiments-Weebify/infra.git
cd infra/docker
```

You must configure DNS records for:
- `${APP_DOMAIN}`
- `s3.${APP_DOMAIN}`

Both should point to the host's public IP.

## Configuration

Before deploying with docker you must setup secrets for the stack. You can do this by running `secrets.sh` script in `./docker/weebify/` which will generate (if it doesn't exist yet) `./secret/` directory containing the following files:
- `searchKey.txt` - Meilisearch API key,
- `s3Secret.txt` - S3 secret key (password) for MinIO,
- `s3AccessKey.txt` - S3 access key (username) for MinIO,
- `mongoSecret.txt` - MongoDB app user password,
- `authJwtKey.txt` - JWT signing / verification key,
- `mongoRootSecret.txt` - MongoDB root password.

Alternatively you can provide you own secrets.

### Deploy

1. Copy both `.env.example` files in `./weebify/` and `./docker/traefik/` to `.env` and adjust as needed.

2. Run `docker compose up -d` from `./docker/traefik/`.

3. Run `docker compose up -d` from `./docker/weebify/`.

4. You can verify that all the containers are running with `docker ps`


### Deploy

1. Copy `.env.example` file in `./vm/vagrant/weebify/` to `.env` and modify it. For domain use the full domain name without the `s3.` prefix (e.g. vagrant.weebify.tv).

2. Run `vagrant up` from `./vm/vagrant/`.

3. Run `vagrant ssh weebify` and verify all 7 containers are running with `docker ps`.


## Test scenario

Next you can ensure everything is working.

- Open configured domain in browser
- Login with configured admin user
- Rebuild search indices and generate an API key
- Create a show/movie
- Upload a cover image (and set your PFP)
- Try uploading a video using [encodeher](https://github.com/Serial-experiments-weebify/encodeher).
- Try searching for the show/movie.
- Link the video to an episode & try playing it back

## Docker stack

The trafeik stack sets up the reverse proxy. The weebify stack contains the app and all it's dependencies.

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