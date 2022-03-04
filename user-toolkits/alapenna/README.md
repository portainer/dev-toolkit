# alapenna's toolkit

This extends the default dev toolkit to add zsh support and custom VSCode UI theme components:
* https://marketplace.visualstudio.com/items?itemName=sdras.night-owl
* https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme

It also enables the following VSCode extensions:
* https://marketplace.visualstudio.com/items?itemName=GitHub.copilot

I store my repositories in `/root/workspace` (which is a symlink to `/workspace`).

# Run it

This is how I run this environment:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/workspaces/toolkit-workspace:/workspace \
    -v /tmp/devkit:/devtmp \
    --name portainer-dev-toolkit \
    my-dev-toolkit    
```

# Post deployment

A few steps to configure the environment after deployment.

## Copying SSH keys

I usually copy my SSH credentials in the toolkit as well:

```
docker cp ~/.ssh/id_rsa portainer-dev-toolkit:/root/.ssh/id_rsa
```

## Configuring git

Inside the terminal of VSCode:

```
git config --global user.email <email>
git config --global user.name <name>
```

## Power10k zsh theme font

Requires the installation of the fonts associated to the power10k zsh theme: https://github.com/romkatv/powerlevel10k#fonts

Then, configure VSCode to use them.

![image](https://user-images.githubusercontent.com/5485061/156640884-0d2001ef-5f3c-4372-8d07-b4c87d2f6783.png)
