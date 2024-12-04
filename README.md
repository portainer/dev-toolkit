The Portainer development toolkit is a containerized development environment for Portainer!

Works on Linux and MacOS!

For previous versions of the toolkit that also included the VSCode IDE, see the branch [2024.08](https://github.com/portainer/dev-toolkit/tree/2024.08).

# TLDR

Install the [devcontainer extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) in your IDE of choice. For more information on supported IDEs, see the [devcontainer documentation](https://containers.dev/supporting#editors).

Configure your workspace to use the `devcontainer.json` file in this repository.

Open your project in your IDE using the <u>Open Folder in Container</u> option and start coding!

Have a look at the rest of the documentation below for more configuration/customization options.

# About

This toolkit is based on the Ubuntu 24.04 LTS image and comes with the following tools pre-installed:

* Golang
* Docker CLI
* NodeJS
* Yarn

See `Dockerfile` for more details.

# Automatic builds

The `portainer/dev-toolkit` image is using DockerHub automatic builds to build multi-arch (amd64, arm64) images based on this git repository tags.

E.g. creating and pushing a new `2024.12` tag in this repository will automatically build `portainer/dev-toolkit:2024.12`.

> **Warning**  
> The automatic builds are currently disabled. Reach out to @deviantony for building newer versions of the base image using manual instructions below.

# Manual build

Follow the instructions below if you wish to build the image manually.
Use the following command to build and push the base image (make sure you are authenticated to DockerHub first):

```
make base
```

# Requirements

All you need to have installed is Docker.

The container image is distributed by Portainer via `portainer/dev-toolkit`, checkout DockerHub for more details on the tags/versions: https://hub.docker.com/repository/docker/portainer/dev-toolkit/tags?page=1&ordering=last_updated 

# How to use it

## Use the base image

Create a `.devcontainer` folder in your project and copy the `devcontainer.json` file that is provided in this repository inside.

Open your project in your IDE using the <u>Open Folder in Container</u> option and start coding! You'll be using the base image, see below for customization options.

## Customize it!

Developers should be able to customize the environment to their liking (I prefer to work with zsh as a shell for example), this dev toolkit was designed to be extended.

See the `examples/` and `user-toolkits` folders for a list of examples on how you can customize your dev toolkit.

All you will need is to build it first:

```
docker buildx build -t my-devkit -f examples/zsh/Dockerfile .
```

Then you can use the instructions above to run it, just replace the official `portainer/dev-toolkit:2024.12` with your image in the `devcontainer.json` file:

```json
{
	"name": "portainer-dev-toolkit",
	"image": "my-devkit",
	...
}
```

## User toolkits

If you wish to use somebody's toolkit or share yours, have a look at the `user-toolkits/` folder!

# Building Portainer inside the toolkit

After opening your project in the dev container, execute the following commands to start a development build.

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

* https://code.visualstudio.com/docs/devcontainers/devcontainer-cli#_development-containers
* https://containers.dev/
* https://code.visualstudio.com/docs/devcontainers/create-dev-container#_create-a-devcontainerjson-file
* https://code.visualstudio.com/docs/devcontainers/devcontainer-cli#_prebuilding
* https://containers.dev/implementors/json_reference/
