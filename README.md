# GIOC - Guacamole In One Command

An easy way to deploy *Guacamole* on your machine --- just for fun.

What you going to get:

* OR HAProxy (with SSL configured automatically)
* OR Nginx (with httppass configured automatically)
* Guacamole version 1.5.1 (database and first user configured automatically)
* GuaCD connecting on your host
* MySQL (latest stable version)

## Know issues
If you are using MacOS with Rancher Desktop, you need to run the `docker-compose up -d` command twice (some bug)

## Requirements

[Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/#scenario-two-install-the-compose-plugin) (I mean it, just it!)

## How to run

1. Copy the `.env-example` to `.env` and change it as you please
    ```bash
    cp .env-example .env
    ```
 
2. Start the docker compose with NGINX on port 80
    ```bash
    docker-compose --profile nginx up
    ```

2. Start the docker compose with HAPROXY on port 443
    ```bash
    docker-compose --profile haproxy up
    ```

3. Access it: http://localhost:8080 (nginx) or https://localhost:8443 (haproxy)
