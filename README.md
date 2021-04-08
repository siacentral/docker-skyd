# Docker - skyd

[![Docker Pulls](https://img.shields.io/docker/pulls/siacentral/skyd?color=19cf86&style=for-the-badge)](https://hub.docker.com/r/siacentral/skyd)

An unofficial docker image for skyd. Automatically builds skyd using the source code from the official repository: https://gitlab.com/SkynetHQ/skyd

# Release Tags

+ latest - the latest stable Skynet release
+ beta - the latest release candidate for the next version of Skynet
+ versions - builds of exact Skynet releases such as: `1.5.4` or `1.5.5`
+ unstable - an unstable build of Skynet's current master branch.

**Get latest official release:**
```
docker pull siacentral/skyd:latest
```

**Get latest release candidate:**
```
docker pull siacentral/skyd:beta
```

**Get Sia v1.5.4**
```
docker pull siacentral/skyd:1.5.4
```

**Get unstable dev branch**
```
docker pull siacentral/skyd:unstable
```

# Usage

It is important to never publish port `9980` to anything but 
`127.0.0.1:9980` doing so could give anyone full access to the Sia API and your
wallet.

Containers should never share volumes. If multiple sia containers are 
needed one unique volume should be created per container.

## Basic Container
```
docker volume create skyd-data
docker run \
	--detach \
	--restart unless-stopped \
	--mount type=volume,src=skyd-data,target=/skyd-data \
	--publish 127.0.0.1:9980:9980 \
	--publish 9981:9981 \
	--publish 9982:9982 \
	--publish 9983:9983 \
	--name skynet \
	siacentral/skyd
```

### Command Line Flags

Additional siad command line flags can be passed in by appending them to docker
run.

#### Change API port from 9980 to 8880
```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:8880:8880 \
	--publish 9981:9981 \
	--publish 9982:9982 \
	--publish 9983:9983 \
	siacentral/skyd --api-addr ":8880"
 ```


#### Change SiaMux port from 9983 to 8883
```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:9980:9980 \
	--publish 9981:9981 \
	--publish 9982:9982 \
	--publish 8883:8883 \
	siacentral/skyd --siamux-addr ":8883"
 ```

#### Only run the minimum required modules
 ```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:9980:9980 \
	--publish 9981:9981 \
	--publish 9982:9982 \
	siacentral/skyd -M gct
 ```

## Docker Compose

```yml
services:
  sia:
    container_name: skyd
    image: siacentral/skyd:latest
    ports:
      - 127.0.0.1:9980:9980
      - 9981:9981
      - 9982:9982
      - 9983:9983
      - 9984:9984
    volumes:
      - skyd-data:/skyd-data
    restart: unless-stopped

volumes:
  skyd-data:
```

#### Change API port from 9980 to 8880
```yml
services:
  sia:
    container_name: skyd
    command: --api-addr :8880
    image: siacentral/skyd:latest
    ports:
      - 127.0.0.1:8880:8880
      - 9981:9981
      - 9982:9982
      - 9983:9983
      - 9984:9984
    volumes:
      - skyd-data:/skyd-data
    restart: unless-stopped

volumes:
  skyd-data:
```


#### Change SiaMux port from 9983 to 8883
```yml
services:
  sia:
    container_name: skyd
    command: --siamux-addr :8883
    image: siacentral/skyd:latest
    ports:
      - 127.0.0.1:9980:9980
      - 9981:9981
      - 9982:9982
      - 8883:8883
      - 9984:9984
    volumes:
      - skyd-data:/skyd-data
    restart: unless-stopped

volumes:
  skyd-data:
```

#### Only run the minimum required modules
```yml
services:
  sia:
    container_name: skyd
    command: -M gct
    image: siacentral/skyd:latest
    ports:
      - 127.0.0.1:9980:9980
      - 9981:9981
      - 9982:9982
      - 9983:9983
      - 9984:9984
    volumes:
      - skyd-data:/skyd-data
    restart: unless-stopped

volumes:
  skyd-data:
```

## Sia API Password

When you create or update the Sia container a random API password will be
generated. You may need to copy the new API password when connecting outside of
the container. To force the same API password to be used you can add
`-e SIA_API_PASSWORD=yourpasswordhere` to the `docker run` command. This will
ensure that the API password stays the same between updates and restarts.

## Using Specific Modules

You can pass in different combinations of Sia modules to run by modifying the 
command used to create the container. For example: `-M gct` tells Sia to only
run the gateway, consensus, and transactionpool modules. `-M gctwh` is the minimum
required modules to run a Sia host. `-m gctwr` is the minimum required modules to
run a Sia renter.

## Hosts

Hosting may require additional volumes passed into the container to map
local drives into the container. These can be added by specifying
docker's `-v` or `--mount` flag.

## Building

To build a specific commit or version of Sia specify the tag or branch of the 
repository using Docker's `--build-arg` flag. Any valid `git checkout` ref can
be used with the `SKYD_VERSION` build arg.

```
docker build --build-arg SKYD_VERSION=v1.5.6 -t siacentral/skyd:1.5.6 .
```
