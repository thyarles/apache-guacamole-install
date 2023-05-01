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
 
2. Start the docker stack in front end at the first time (to easily see the deployment)
    ```bash
    docker-compose up
    ```
 
3. If everything goes well, stop it (`control + c`) and start again in background
    ```bash
    docker-compose up -d
    ``` 
4. Access it from you localhost: https://localhost/guacamole
    
