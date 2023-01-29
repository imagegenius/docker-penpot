<!-- DO NOT EDIT THIS FILE MANUALLY  -->

# [imagegenius/immich](https://github.com/imagegenius/docker-immich)

[![GitHub Release](https://img.shields.io/github/release/imagegenius/docker-immich.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/imagegenius/docker-immich/releases)
[![GitHub Package Repository](https://img.shields.io/static/v1.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=imagegenius.io&message=GitHub%20Package&logo=github)](https://github.com/imagegenius/docker-immich/packages)
![Image Size](https://img.shields.io/docker/image-size/imagegenius/immich/latest.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=docker)
[![Jenkins Build](https://img.shields.io/jenkins/build?labelColor=555555&logoColor=ffffff&style=for-the-badge&jobUrl=https%3A%2F%2Fci.imagegenius.io%2Fjob%2FDocker-Pipeline-Builders%2Fjob%2Fdocker-immich%2Fjob%2Fmain%2F&logo=jenkins)](https://ci.imagegenius.io/job/Docker-Pipeline-Builders/job/docker-immich/job/main/)
[![IG CI](https://img.shields.io/badge/dynamic/yaml?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=CI&query=CI&url=https%3A%2F%2Fci-tests.imagegenius.io%2Fimagegenius%2Fimmich%2Flatest%2Fci-status.yml)](https://ci-tests.imagegenius.io/imagegenius/immich/latest/index.html)

[Immich](https://immich.app/) - High performance self-hosted photo and video backup solution.

[![immich](https://user-images.githubusercontent.com/27055614/182044984-2ee6d1ed-c4a7-4331-8a4b-64fcde77fe1f.png)](https://immich.app/)

## Supported Architectures

We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

Simply pulling `ghcr.io/imagegenius/immich:latest` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | amd64-\<version tag\> |
| arm64 | ✅ | arm64v8-\<version tag\> |

## Version Tags

This image provides various versions that are available via tags. Please read the descriptions carefully and exercise caution when using unstable or development tags.

| Tag | Available | Description |
| :----: | :----: |--- |
| latest | ✅ | Latest Immich release with an Ubuntu base. |
| noml | ✅ | Latest Immich release with an Alpine base. Machine-learning is completly removed. (tinnny image), use this if your CPU does not support AVX |

## Application Setup

The WebUI can be found at `http://your-ip:8080`. Follow the wizard to set up Immich.

Immich requires that you have PostgreSQL 14 and Redis setup externally.

Follow these steps if you need help setting up Redis or PostgreSQL.

#### Redis:

Redis can be ran within the container using a docker-mod or you can use an external Redis server/container.

If you don't need to use Redis elsewhere add this environment variable: `DOCKER_MODS=imagegenius/mods:universal-redis`, and set `REDIS_HOSTNAME` to `localhost`.

Or within a seperate container:

```bash
docker run -d \
  --name=redis \
  -p 6379:6379 \
  redis
```

#### PostgreSQL 14:

(A docker-mod for postgres is in the making)

```bash
docker run -d \
  --name=postgres14 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=immich \
  -v path_to_postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:14
```

### Unraid: Migrate from docker-compose

**⚠️ Pre-read all these steps before doing anying, if you are confused open an issue.**

When using the official Immich docker-compose, the PostgreSQL data is stored in a docker volume which _should_ be located at `/var/lib/docker/volumes/pgdata/_data`. Before preceeding you **must** stop the docker-compose stack.

#### 1. Move the database

To move the PostgreSQL data to the unraid array run:

```bash
mv /var/lib/docker/volumes/pgdata/_data /mnt/user/appdata/postgres14
```

Install `postgresql14` from the Unraid CA and remove these variables from the template: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
The database is already initialised and these variables don't do anything.
Also set `Database Storage Path` to `/mnt/user/appdata/postgres14`.

#### 2. Move the uploads

In the docker-compose .env you would have set the `UPLOAD_LOCATION`, copy that down and use it below:

**⚠️ Note that Immich created the `uploads` folder within the `UPLOAD_LOCATION`.**

```bash
mv <upload_location>/uploads /mnt/user/<elsewhere>
```

#### 3. Setup the `imagegenius/immich` container

Search the unraid CA for `immich`, choose either `CorneliousJD`'s or `vcxpz`'s templates (`vcxpz` is the official imagegenius template).

**⚠️ You must configure the template to the values listed in the docker-compose .env**

Ensure that the template matches the `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE_NAME` and `JWT_SECRET` from the .env. Set `Path: /photos` to `/mnt/user/<elsewhere>`.

Click Apply, Open the WebUI and login. Everything _Should_ be as it was.

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose

```yaml
---
version: "2.1"
services:
  immich:
    image: ghcr.io/imagegenius/immich:latest
    container_name: immich
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Melbourne
      - DB_HOSTNAME=192.168.1.x
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_DATABASE_NAME=immich
      - REDIS_HOSTNAME=redis
      - JWT_SECRET=somelongrandomstring
      - DB_PORT=5432 #optional
      - REDIS_PORT=6379 #optional
      - REDIS_PASSWORD= #optional
    volumes:
      - path_to_appdata:/config
      - path_to_photos:/photos
    ports:
      - 8080:8080
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=immich \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Australia/Melbourne \
  -e DB_HOSTNAME=192.168.1.x \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_DATABASE_NAME=immich \
  -e REDIS_HOSTNAME=redis \
  -e JWT_SECRET=somelongrandomstring \
  -e DB_PORT=5432 `#optional` \
  -e REDIS_PORT=6379 `#optional` \
  -e REDIS_PASSWORD= `#optional` \
  -p 8080:8080 \
  -v path_to_appdata:/config \
  -v path_to_photos:/photos \
  --restart unless-stopped \
  ghcr.io/imagegenius/immich:latest
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | WebUI Port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Australia/Melbourne` | Specify a timezone to use eg. Australia/Melbourne. |
| `-e DB_HOSTNAME=192.168.1.x` | PostgreSQL Host |
| `-e DB_USERNAME=postgres` | PostgreSQL Username |
| `-e DB_PASSWORD=postgres` | PostgreSQL Password |
| `-e DB_DATABASE_NAME=immich` | PostgreSQL Database Name |
| `-e REDIS_HOSTNAME=redis` | Redis Hostname |
| `-e JWT_SECRET=somelongrandomstring` | Run `openssl rand -base64 128` |
| `-e DB_PORT=5432` | PostgreSQL Port |
| `-e REDIS_PORT=6379` | Redis Port |
| `-e REDIS_PASSWORD=` | Redis password |
| `-v /config` | Contains the logs |
| `-v /photos` | Contains all the photos uploaded to Immich |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Support Info

* Shell access whilst the container is running: `docker exec -it immich /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f immich`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' immich`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' ghcr.io/imagegenius/immich:latest`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull immich`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d immich`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull ghcr.io/imagegenius/immich:latest`
* Stop the running container: `docker stop immich`
* Delete the container: `docker rm immich`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/imagegenius/docker-immich.git
cd docker-immich
docker build \
  --no-cache \
  --pull \
  -t ghcr.io/imagegenius/immich:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`

```bash
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **26.01.23:** - add unraid migration to readme
* **26.01.23:** - use find to apply chown to /app, excluding node_modules
* **26.01.23:** - enable ci testing
* **24.01.23:** - fix services starting prematurely, causing permission errors.
* **23.01.23:** - add noml image to readme and add aarch64 image to readme, make github release stable
* **21.01.23:** - BREAKING: Redis is removed. Update missing param_env_vars & opt_param_env_vars for redis & postgres
* **02.01.23:** - Initial Release.