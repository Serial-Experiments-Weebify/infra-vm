# Docker quick deploy

## Prerequisites
- Docker
- public IP or port forwarding for 80/443
- domain name you control

## DNS
- Point your app domain (can be anything) and it's `s3` subdomain to the server.
    - (e.g. `test.weebify.tv` and `s3.test.weebify.tv`)

## Environment files
- Copy each `.env.example` to `.env` in the same directory and edit values (domain, credentials, AWS/S3 settings, etc).
        - `cp ./traefik/.env.example ./traefik/.env`
        - `cp ./weebify/.env.example ./weebify/.env`
- Confirm the configured domain(s) in these files match your DNS records.

## Startup
1. cd into `traefik` and run:
     - `docker compose up -d`
2. cd into `weebify` and run:
     - `docker compose up`
     - wait untill things settle (make sure s3init and mongo don't fail)
     - stop the stack (CTRL+C) and run with `-d` to background

## Profit?

To check that everything is working:

- Open configured domain in browser
- Login with configured admin user
- Rebuild search indices and generate an API key
- Create a show/movie
- Upload a cover image (and set your PFP)
- Try uploading a video using [encodeher](https://github.com/Serial-experiments-weebify/encodeher).
- Link the video to an episode & try playing it back

# Troubleshooting

Good Luck!