# alapenna's toolkit

This extends the default dev toolkit to add zsh support and custom VSCode UI theme components:
* https://marketplace.visualstudio.com/items?itemName=sdras.night-owl
* https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme

It also enables the following VSCode extensions:
* https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
* https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens

It includes the following tools:
* httpie (http://httpie.io/)

I store my repositories in `/root/workspace` (which is a symlink to `/workspace`).

# Build it

Simple as running the following command on your local machine:

```
make alapenna
```

# Run it

This is how I run this environment:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/workspaces/toolkit-workspace:/workspace \
    -v ~/tmp/dev-toolkit:/share-tmp \
    --name portainer-dev-toolkit \
    portainer-dev-toolkit  
```

## With Finch!

https://github.com/runfinch/finch

```
finch build -t portainer-dev-toolkit -f user-toolkits/alapenna/Dockerfile .

finch run -d --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v ~/workspaces/toolkit-workspace:/workspace \
    -v ~/tmp/dev-toolkit:/share-tmp \
    --name portainer-dev-toolkit \
    portainer-dev-toolkit 

finch container cp ~/.ssh/id_rsa portainer-dev-toolkit:/root/.ssh/id_rsa
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
