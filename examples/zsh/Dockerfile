FROM portainer/dev-toolkit:2023.03

ENV HOME /root

RUN mkdir -pv /workspace && ln -s /workspace /root/workspace

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"

ENV SHELL /bin/zsh
