# alapenna's toolkit

This extends the default dev toolkit to add zsh support and a few more tools.

It includes the following tools:
* httpie for easy HTTP requesting (http://httpie.io/)
* air for golang app live reload (https://github.com/air-verse/air)

I store my repositories in `/root/workspace` (which is a symlink to `/workspace`).
It includes a few folders shared with the host:
* `/root/.ssh`: for SSH keys
* `/root/.gnupg`: for GPG keys
* `/workspace`: for all my git repositories that I have on my host
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
