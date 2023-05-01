# GIOC - Guacamole In One Command

An easy way to deploy *Guacamole* on your machine --- just for fun.

What you going to get:

* HAProxy 2.7 (with SSL configured automatically)
* Guacamole version 1.5.1 (database and first user configured automatically)
* MySQL (latest stable version)

## Requirements

[Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/#scenario-two-install-the-compose-plugin) (I mean it, just it!)

## How to run

1. Copy the `.env-example` to `.env` and change it as you please
    ```bash
    cp .env-example .env
    ```
 
2. Start the docker compose
    ```bash
    docker-compose up
    ```
 
3. Access it: https://localhost/guacamole    
