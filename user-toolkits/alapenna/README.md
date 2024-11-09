# alapenna's toolkit

This extends the default dev toolkit to add zsh support and a few more tools.

It includes the following tools:
* httpie for easy HTTP requesting (http://httpie.io/)
* air for golang app live reload (https://github.com/air-verse/air)

This dev container is a bit different from the base dev container. It creates a Docker volume and mounts it at `/workspace`. All the code for my projects are stored in this folder/volume.

This is supposed to provide better performances: https://code.visualstudio.com/remote/advancedcontainers/improve-performance#_use-a-named-volume-for-your-entire-source-tree


It includes a few folders shared with the host:
* `/root/.ssh`: for SSH keys
* `/root/.gnupg`: for GPG keys
* `/src`: this contains all the repositories that I have already cloned on my machine - handy if I need to copy across to `/workspace`.
* `/share-tmp`: for sharing temporary files between the host and the container

For more details, see the `devcontainer.json` and the `Dockerfile` files in this directory.

# Build it

Simple as running the following command on your local machine:

```
make alapenna
```

# Use it

Configure your project to use the `devcontainer.json` file in this directory.

# Post deployment

A few steps to configure the environment after a new deployment or after an update.

## Configuring git

Inside the terminal of your IDE:

```
# Configure the git user
git config --global user.email <email>
git config --global user.name <name>
git config --global commit.gpgsign true
git config --global user.signingkey <key_id>
```
