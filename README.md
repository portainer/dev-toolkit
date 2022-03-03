The entire Portainer development stack inside a container (including the IDE!).

Inspired/made after reading https://www.gitpod.io/blog/openvscode-server-launch

# TLDR

Run the toolkit:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-devkit \
    portainer/dev-toolkit:2022.03
```

Now you can access VScode directly at http://localhost:3000 and start coding (almost)!

Have a look at the rest of the documentation below for more configuration/customization options.

# About

This toolkit comes with the following pre-installed:

* Golang
* Docker CLI
* NodeJS
* Yarn
* VSCode (+extensions: Go, Docker)

See `Dockerfile` for more details.

# Automatic builds

The `portainer/dev-toolkit` image is using DockerHub automatic builds to build images based on this git repository tags.

E.g. creating a new `2022.03` tag in this repository would automatically build `portainer/dev-toolkit:2022.03`.

# Requirements

All you need to have installed is Docker.

The container image is distributed by Portainer via `portainer/dev-toolkit`, checkout DockerHub for more details on the tags/versions: https://hub.docker.com/repository/docker/portainer/dev-toolkit/tags?page=1&ordering=last_updated 


## (optional) Build the base toolkit image locally

Assuming the toolkit is not built/provided by Portainer or you want to tweak it, use the following instructions to build the toolkit locally:

```
docker build -t portainer-development-toolkit-base .
```

**NOTE**: the `portainer/dev-toolkit` is automatically built based on tags available in this git repository. E.g creating a new tag `2022.03` will automatically build and publish `portainer/dev-toolkit:2022.03`.

# How to use it

## Using the base without customizations

Follow the instructions below to start a vanilla Portainer dev toolkit container:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-devkit \
    portainer/dev-toolkit:2022.03
```

Now you can access VScode directly at http://localhost:3000 and start coding (almost)!

## Customize it!

Developers should be able to customize the environment to their liking (I prefer work with zsh as a shell for example), this dev toolkit was designed to be extended.

See the `examples/` folder for a list of examples on how you can customize your dev toolkit.

All you will need is to build it first:

```
docker build -t my-devkit -f examples/zsh/Dockerfile .
```

Then you can use the instructions above to run it, just replace the official `portainer/dev-toolkit:2022.03` with your image:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name my-devkit \
    my-devkit
```

## User toolkits

If you wish to use somebody's toolkit or share yours, have a look at the `user-toolkits/` folder!

## Passing the Docker socket

The toolkit default instructions bind mount the docker socket from your host into the dev-toolkit container, this can be useful if you need to manage containers on your host, build images,etc...

However, it's entirely optional.

## Legacy Portainer deployment (running as a container on the host)

You can still run Portainer through a base container (via `yarn start`) with the host but you will need to pass extra parameters when deploying the toolkit container:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e PORTAINER_PROJECT=/path/to/portainer/project/on/host \
    --name portainer-devkit \
    portainer/dev-toolkit:2022.03
```

### Why do I need PORTAINER_PROJECT?

This environment variable defines where the Portainer project root folder resides **on your machine** and will be used by Docker to bind mount the `/dist` folder when deploying the local development Portainer instance.

# References & useful links

* https://github.com/gitpod-io/openvscode-server
