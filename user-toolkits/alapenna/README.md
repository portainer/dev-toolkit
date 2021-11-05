# alapenna's toolkit

This extends the default dev toolkit to add zsh support and custom VSCode UI theme components:
* https://marketplace.visualstudio.com/items?itemName=sdras.night-owl
* https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme

I also store my repositories in `/root/workspace` (which is a symlink to `/workspace`).

This is how I run this environment:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-dev-toolkit \
    my-dev-toolkit    
```