# alapenna's toolkit

This extends the default dev toolkit to add zsh support and custom VSCode UI theme components:
* https://marketplace.visualstudio.com/items?itemName=sdras.night-owl
* https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme

It also enables the following VSCode extensions:
* https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
* https://marketplace.visualstudio.com/items?itemName=ms-python.python

It includes the following tools:
* httpie for easy HTTP requesting (http://httpie.io/)
* air for golang app live reload (https://github.com/air-verse/air)
* a few Python tools (pip, pipenv, twine) for Python experiments

I store my repositories in `/root/workspace` (which is a symlink to `/workspace`).

# Build it

Simple as running the following command on your local machine:

```
make alapenna
```

# Run it

This is how I run this environment:

```
# This container:
# * Exposes a few different ports for development
# * Has access to the local socket to control Docker from within the VSCode terminal
# * Uses a mount to store the projects on the host
# * Uses a convenient mount to share files between the host and this container
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 -p 8999:8999 -p 6443:6443 -p 443:443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/workspaces/toolkit-workspace:/workspace \
    -v ~/tmp/dev-toolkit:/share-tmp \
    --name portainer-dev-toolkit \
    portainer-dev-toolkit
```

# Post deployment

A few steps to configure the environment after a new deployment or after an update.

## Copying SSH keys

I usually copy my SSH credentials in the toolkit as well:

```
docker cp ~/.ssh/id_rsa portainer-dev-toolkit:/root/.ssh/id_rsa
docker cp ~/.ssh/id_rsa.pub portainer-dev-toolkit:/root/.ssh/id_rsa.pub
```

## Configuring git

Inside the terminal of VSCode:

```
# Run a git pull first to validate github.com key fingerprint
git pull
git config --global user.email <email>
git config --global user.name <name>
```

## Power10k zsh theme font

*Note: this is usually only required on first deployment.*

Requires the installation of the fonts associated to the power10k zsh theme: https://github.com/romkatv/powerlevel10k#fonts

Then, configure VSCode to use them.

![image](https://user-images.githubusercontent.com/5485061/156640884-0d2001ef-5f3c-4372-8d07-b4c87d2f6783.png)
