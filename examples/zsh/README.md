# ZSH enabled environment

This extends the default dev toolkit to add zsh support inside the environment.

It comes with the default powerlevel10k theme enabled.

Note: make sure to install recommended fonts on your system if you want to use the default theme (powerlevel10k)
See: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

You'll also need to update VSCode settings (terminal.integrated.fontFamily) to match "MesloLGS NF" (more details in the link above).

This is how I used this environment:

```
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-dev-toolkit \
    dev-toolkit
```