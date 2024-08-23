The entire Portainer development stack inside a container (including the IDE!).

Works on Linux and MacOS!

Inspired/made after reading https://www.gitpod.io/blog/openvscode-server-launch

# TLDR

Run the toolkit:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-devkit \
    portainer/dev-toolkit:2024.08
```

Now you can access VScode directly at http://localhost:3000 and start coding (almost)!

Have a look at the rest of the documentation below for more configuration/customization options.

# About

This toolkit comes with the following tools pre-installed:

* Golang
* Docker CLI
* NodeJS
* Yarn
* VSCode (+extensions: Go, Docker)

See `Dockerfile` for more details.

The Docker image is based on the OpenVSCode image provided by Gitpod: https://github.com/gitpod-io/openvscode-server

# Automatic builds

The `portainer/dev-toolkit` image is using DockerHub automatic builds to build multi-arch (amd64, arm64) images based on this git repository tags.

E.g. creating a new `2024.08` tag in this repository will automatically build `portainer/dev-toolkit:2024.08`.

# Manual build

Follow the instructions below if you wish to build the image manually.

> **Warning**  
> Currently, the multi-arch image for Linux ARM64 and Linux AMD64 **must be built on a Linux AMD64** host.
> See https://github.com/docker/buildx/issues/495#issuecomment-761562905 for more details about the issue.

Use the following command to build and push the base image (make sure you are authenticated to DockerHub first):

```
make base
```

# Requirements

All you need to have installed is Docker.

The container image is distributed by Portainer via `portainer/dev-toolkit`, checkout DockerHub for more details on the tags/versions: https://hub.docker.com/repository/docker/portainer/dev-toolkit/tags?page=1&ordering=last_updated 

# How to use it

## Using the base without customizations

Follow the instructions below to start a vanilla Portainer dev toolkit container:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 -p 8999:8999 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-devkit \
    portainer/dev-toolkit:2024.08
```

Now you can access VScode directly at http://localhost:3000 and start coding (almost)!

## Customize it!

Developers should be able to customize the environment to their liking (I prefer work with zsh as a shell for example), this dev toolkit was designed to be extended.

See the `examples/` and `user-toolkits` folders for a list of examples on how you can customize your dev toolkit.

All you will need is to build it first:

```
docker buildx build -t my-devkit -f examples/zsh/Dockerfile .
```

Then you can use the instructions above to run it, just replace the official `portainer/dev-toolkit:2024.08` with your image:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 -p 8999:8999 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name my-devkit \
    my-devkit
```

## User toolkits

If you wish to use somebody's toolkit or share yours, have a look at the `user-toolkits/` folder!

## Passing the Docker socket

The toolkit default instructions bind mount the docker socket from your host into the dev-toolkit container, this can be useful if you need to manage containers on your host, build images,etc...

However, it's entirely optional.

# Building Portainer inside the toolkit

Clone the portainer project directly in the container and execute the following commands to start a development build.

Install the dependencies and build the client+server first:

```
make build-all
```

Run the backend as a process directly:

```
./dist/portainer --data /tmp/portainer --log-level=DEBUG
```

Run the client in dev mode if you wish to do changes on the client:

```
make dev-client
```

# References & useful links

* https://github.com/gitpod-io/openvscode-server
