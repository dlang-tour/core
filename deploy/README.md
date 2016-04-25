# Deployment of dlang-tour

The preferred way to deploy the dlang-tour on a production
server is to use the **Travis CI** built [docker image](https://hub.docker.com/r/stonemaster/dlang-tour/).
To simplify container deployment it's recommended
to use [docker-compose](https//docs.docker.com/compose).

## Deployment with Docker Compose

The [docker-compose.yml](docker-compose.yml) file contained
in this folder contains everything to orchestrate the
`dlang-tour` on a server that meets the requirements below.
The Docker compose file also configures
[watchtower](https://github.com/CenturyLinkLabs/watchtower)
that checks periodically for updates on the `latest` tag of the Docker image
and restarts the `dlang-tour` container when a newer version is available.

### Requirements

 * Linux with kernel **>= 3.10**.
 * Docker installed on host system: **>= 1.8.3**
 * **Docker compose**: 
   * Install [Docker Compose](https://docs.docker.com/compose/install/)

### Installation of dlang-tour

1. Download [docker-compose.yml](docker-compose.yml) file:

    wget https://raw.githubusercontent.com/stonemaster/dlang-tour/master/deploy/docker-compose.yml

1. Adapt the environment variable `GOOGLE_ANALYTICS_ID` if needed
   in `docker-compose.yml`.
1. Run `docker-compose up -d`.
1. Running `docker-compose logs tour` will show logfiles of the currently
   running `dlang-tour` container.
