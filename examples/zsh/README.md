# ZSH enabled environment

This extends the default dev toolkit to add zsh support inside the environment.

It comes with the default powerlevel10k theme enabled.

Note: make sure to install recommended fonts on your system if you want to use the default theme (powerlevel10k)
See: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

You'll also need to update VSCode settings (terminal.integrated.fontFamily) to match "MesloLGS NF" (more details in the link above).

You can use the `devcontainer.json` file in the root of this repository as a reference to configure your project to use this image.