# Refactoring-Bot: Docker Support

This repository contains everything for installing the Refactoring-Bot via Docker. We provide a single Docker image (see `Dockerfile`) that includes both application components of the bot, namely the Java part and the web UI.
- [Refactoring-Bot Java component](https://github.com/Refactoring-Bot/Refactoring-Bot) with business logic and API
  - API: <http://localhost:8808>
  - SwaggerUI: <http://localhost:8808/swagger-ui.html>
- [Web UI](https://github.com/Refactoring-Bot/Refactoring-Bot-UI) for end user access: <http://localhost:8000>

This image is available on [DockerHub](https://hub.docker.com/r/refactoringbot/bot) and can be pulled for immediate usage. The `Refactoring-Bot` also needs a MySQL instance for persistence.

## Quick Start Guide
The following three commands are the easiest way to get a dockerized instance of the `Refactoring-Bot` up and running without manually downloading any repository. For more details and the usage of `docker-compose`, please refer to the sections below.

```bash
# Create common network for the containers
docker network create ref-bot-net

# Start MySQL DB container
docker run --name refactoring-bot-db \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=root \
    --network ref-bot-net \
    -d mysql:8

# Start Refactoring-Bot container, publishing port 8808 for the API and port 8000 for the web UI (change as needed)
docker run --name refactoring-bot \
    -p 8808:8808 \
    -p 8000:80 \
    -e DATABASE_HOST=refactoring-bot-db \
    --network ref-bot-net \
    -d refactoringbot/bot:latest
```
You should now be able to access the SwaggerUI via <http://localhost:8808/swagger-ui.html> and the web UI via <http://localhost:8000>.

## Basic Docker Commands
The following snippets illustrate standard Docker commands for the usage of the image.

```bash
# Optional: Build image from Dockerfile locally (`Dockerfile` needs to be downloaded for this); not necessary, because the image will be pulled from DockerHub if it is not available locally
docker build -t refactoringbot/bot:latest .

# Start MySQL DB instance
docker run --name refactoring-bot-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql:8

# Create container from image, publishing port 8808 for the API and port 8000 for the web UI (change as needed)
# Provide the MySQL DB instance via ENV variable (e.g. use `docker inspect refactoring-bot-db` to get the IP)
docker create --name refactoring-bot \
    -p 8808:8808 \
    -p 8000:80 \
    -e DATABASE_HOST=172.17.0.2 \
    refactoringbot/bot:latest

# Start container
docker start refactoring-bot

# Optional: list existing containers
docker ps -a

# Optional: open interactive shell to connect to a running container
docker exec -it refactoring-bot bash
```

## Docker Compose
A second and more comfortable option is to use `docker-compose` to spin up both a container for MySQL and the `Refactoring-Bot` with a single command. The configuration for this is provided in the `docker-compose.yml` file and needs to be downloaded to your local machine.

```bash
# Start with docker-compose (stop with CTRL+C, does not delete containers)
docker-compose up

# Start in background mode
docker-compose up -d

# Optional: list existing containers
docker ps -a

# Optional: open interactive shell to connect to a running container
docker exec -it refactoring-bot bash

# Stop docker-compose containers (does not delete them)
docker-compose stop

# Stop and delete docker-compose containers
docker-compose down
```

## Environment Variables
The following ENV variables can be passed to the Docker container (with the `-e` flag or in the `docker-compose.yml` file) to override the default configuration. In most cases, this is not necessary, since the default values work fine for a standard installation.

- `DATABASE_HOST`: the hostname of the MySQL database (default: `localhost`)
- `DATABASE_PORT`: the port of the MySQL database (default: `3306`)
- `DATABASE_NAME`: the name of the MySQL schema (default: `refactoringbot_db`)
- `DATABASE_USER`: the login username for MySQL (default: `root`)
- `DATABASE_PASSWORD`: the login password for MySQL (default: `root`)
- `SERVER_PORT`: the port the API will be running on (default: `8808`; if you change this, be sure to also publish this port at the container level)
- `LOCAL_DIR`: the local workspace directory of the bot (default: `/app/workspace`)

## TODOs
- [x] Make image available on DockerHub
- [ ] Create webhooks to build and deploy image after one of the two component repos has changes in the `master` branch
- [ ] Fix rare bug when API starts faster than DB and therefore crashes (`depends_on` relation is not enough in some cases)