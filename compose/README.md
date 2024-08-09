# Policy Framework Docker Compose

The PF docker compose starts a small instance of docker containers for PF components.

## Features

- Starts all components, including Prometheus/Grafana dashboard and GUI (ACM and Apex)
- Can start specific components
- Expose fixed ports so all the REST endpoints can be called with localhost:component_port

## Tech

Things to be installed beforehand:

- Linux VM if using Windows
- Docker
- Docker compose
- Any editor

## Installation

Assuming the docker repository has been cloned and workdir is ../docker/compose

- Install all PF components (excluding GUI)
```sh
./start-compose.sh
```

- Install all PF components + GUI

```sh
./start-compose.sh --gui
```

- Install an specific PF component
(accepted options: api pap apex-pdp distribution drools-pdp drools-apps xacml-pdp
policy-clamp-runtime-acm)


```sh
./start-compose.sh component

# that will start apex-pdp and its dependencies (pap, api, db, simulator)
./start-compose.sh apex-pdp
```

- Install an specific PF component with Grafana dashboard
(accepted options: api pap apex-pdp distribution drools-pdp drools-apps xacml-pdp
policy-clamp-runtime-acm)


```sh
./start-compose.sh component --grafana

# that will start apex-pdp and its dependencies (pap, api, db, simulator) + grafana and prometheus server
./start-compose.sh apex-pdp --grafana
```

## Docker image localization

The docker images are always downloaded from nexus repository, but if needed to build a local
image, edit the ``export-ports.sh`` script and change the variable ``CONTAINER_LOCATION``
to be empty.


## Docker image versions

The start-compose script is always looking for the latest SNAPSHOT version available (will
look locally first, then download from nexus if not available).
Note: if latest Policy-API docker image is 2.8-SNAPSHOT-latest, but on nexus it was released
2 days ago and in local environment it's 3 months old - it will use the 3 months old image,
so it's recommended to keep an eye on it.

If needed, the version can be edited on docker-compose.postgres.yml

i.e: need to change db-migrator version
from docker-compose.postgres.yml:
``image: ${CONTAINER_LOCATION}onap/policy-db-migrator:${POLICY_DOCKER_VERSION}``

replace the ${POLICY_DOCKER_VERSION} for the specific version needed


## Logs

To collect the docker-compose logs, simply run the following:

```sh
./start-compose.sh logs
```
Note: these are logs for installation only, not actual application usage

It will generate a ``docker-compose.log`` file with the result.

## Uninstall

Simply run the ``stop-compose.sh`` script.

```sh
./stop-compose.sh
```
