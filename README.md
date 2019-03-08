# Refactoring-Bot: Docker Support

This repository contains everything for installing the Refactoring-Bot via Docker. We provide a single Docker image (see `Dockerfile`) that includes both application components of the bot, namely the Java part and the web UI.
- [Refactoring-Bot Java component](https://github.com/Refactoring-Bot/Refactoring-Bot) with business logic and API
  - API: <http://localhost:8808>
  - SwaggerUI: <http://localhost:8808/swagger-ui.html>
- [Web UI](https://github.com/Refactoring-Bot/Refactoring-Bot-UI) for end user access: <http://localhost:8000>

## Basic Docker Commands
One option is to build the image and container locally via standard Docker commands. The `Refactoring-Bot` also needs a MySQL instance for persistence.

```bash
# Build image from Dockerfile locally
docker build -t refactoringbot/bot .

# Start MySQL DB instance
docker run --name refactoring-bot-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql:8

# Create container from image, exposing port 8808 for the API and port 8000 for the web UI (change as needed)
# Provide the MySQL DB instance via env variable (e.g. use `docker inspect refactoring-bot-db` to get the IP)
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
A second and more comfortable option is to use `docker-compose` to spin up both a container for MySQL and the `Refactoring-Bot`. The configuration for this is provided in the `docker-compose.yml` file.

```bash
# Start and build with docker-compose (stop with CTRL+C, does not delete containers)
docker-compose up --build

# Start in background mode
docker-compose up --build -d

# Optional: list existing containers
docker ps -a

# Optional: open interactive shell to connect to a running container
docker exec -it refactoring-bot bash

# Stop docker-compose containers (does not delete them)
docker-compose stop

# Stop and delete docker-compose containers
docker-compose down
```

## TODOs
- [ ] Make image available on DockerHub
- [ ] Create CI pipeline to build and deploy image after one of the two component repos has changes in the `master` branch
- [ ] Fix rare bug when API starts faster than DB and therefore crashes (`depends_on` relation is not enough in some cases)