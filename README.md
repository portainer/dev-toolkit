The entire Portainer development stack inside a container (including the IDE!).

Inspired/made after reading https://www.gitpod.io/blog/openvscode-server-launch

## About

This toolkit comes with the following pre-installed:

* Golang
* Docker CLI
* NodeJS
* Yarn
* VSCode (+extensions: Go, Docker)

See `Dockerfile` for more details.

## Requirements

All you need to have installed is Docker.

The container image is distributed by Portainer via `cr.portainer.io/portainer/dev-toolkit`, checkout DockerHub for more details on the tags/versions: https://hub.docker.com/repository/docker/portainer/dev-toolkit/tags?page=1&ordering=last_updated 


## (optional) Build the base toolkit image locally

Assuming the toolkit is not built/provided by Portainer or you want to tweak it, use the following instructions to build the toolkit locally:

```
docker build -t portainer-development-toolkit-base .
```

## How to use it

### Using the base without customizations

Following the instructions below to start a vanilla Portainer dev toolkit container:

```
# First, let's create a space to persist our code, dependencies and VS extensions
$ mkdir -pv /home/alapenna/workspaces/portainer-toolkit

# Export the space as an env var
$ export TOOLKIT_ROOT=/home/alapenna/workspaces/portainer-toolkit

# Run the toolkit
$ docker run -it --init \
-p 3000:3000 \
-p 9000:9000 -p 9443:9443 -p 8000:8000 \
-v ${TOOLKIT_ROOT}:/home/workspace:cached \
--name portainer-dev-toolkit \
cr.portainer.io/portainer/dev-toolkit:2021.11
```

Now you can access VScode directly at http://localhost:3000 and start coding (almost)!

## Customize it!

Developers should be able to customize the environment to their liking (I prefer work with zsh as a shell for example), this dev toolkit was designed to be extended.

See the `examples/` folder for a list of examples on how you can customize your dev toolkit.

All you will need is to build it first:

```
docker build -t my-dev-toolkit -f examples/zsh/Dockerfile .
```

Then you can use the instructions above to run it, just replace the official `cr.portainer.io/portainer/dev-toolkit:2021.11` with your image:

```
# First, let's create a space to persist our code, dependencies and VS extensions
$ mkdir -pv /home/alapenna/workspaces/portainer-toolkit

# Export the space as an env var
$ export TOOLKIT_ROOT=/home/alapenna/workspaces/portainer-toolkit

# Run the toolkit
$ docker run -it --init \
-p 3000:3000 \
-p 9000:9000 -p 9443:9443 -p 8000:8000 \
-v ${TOOLKIT_ROOT}:/home/workspace:cached \
--name portainer-dev-toolkit \
my-dev-toolkit
```

### User toolkits

If you wish to use somebody's toolkit or share yours, have a look at the `user-toolkits/` folder!

## Passing the Docker socket

Passing the Docker socket to the dev-toolkit container can be useful if you need to manage containers on your host, build images,etc... from the dev-toolkit container:

```
$ docker run -it --init \
-p 3000:3000 \
-p 9000:9000 -p 9443:9443 -p 8000:8000 \
-v ${TOOLKIT_ROOT}:/home/workspace:cached \
-v /var/run/docker.sock:/var/run/docker.sock
--name portainer-dev-toolkit \
my-dev-toolkit
```

## Legacy Portainer deployment (running as a container on the host)

You can still run Portainer through a base container with the host but you will need to pass extra parameters when deploying the toolkit container:

```
$ docker run -it --init -p 3000:3000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ${TOOLKIT_ROOT}:/home/workspace:cached \
-e PORTAINER_PROJECT=${TOOLKIT_ROOT}/portainer \
--name portainer-dev-toolkit \
cr.portainer.io/portainer/dev-toolkit:2021.11
```

### Why do I need PORTAINER_PROJECT?

This environment variable defines where the Portainer project root folder resides on your machine and will be used by Docker to bind mount the `/dist` folder when deploying the local development Portainer instance.

# References & useful links

* https://github.com/gitpod-io/openvscode-server

# Automatic builds

The `cr.portainer.io/portainer/dev-toolkit` image is using DockerHub automatic builds to build images based on this git repository tags.

E.g. creating a new `2021.12` tag in this repository would automatically build `cr.portainer.io/portainer/dev-toolkit:2021.12`.