FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles \
    SHELL=/usr/bin/zsh \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    autoconf \
    autotools-dev \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gdb \
    gcc-13 \
    g++-13 \
    gettext \
    git \
    htop \
    iputils-ping \
    less \
    libbz2-dev \
    libcurl4-openssl-dev \
    libexpat-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses-dev \
    libopenmpi-dev \
    libreadline-dev \
    libssl-dev \
    libtool \
    locales \
    ltrace \
    man-db \
    ninja-build \
    openmpi-bin \
    openssh-client \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    software-properties-common \
    sqlite3 \
    strace \
    sudo \
    tk-dev \
    tree \
    unzip \
    uuid \
    valgrind \
    vim \
    wget \
    zsh \
    && locale-gen en_US.UTF-8 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu 2>/dev/null || true && \
    groupdel ubuntu 2>/dev/null || true && \
    groupadd -g 54987 martymcf && \
    useradd -m -s /usr/bin/zsh -u 54987 -g 54987 martymcf && \
    echo "martymcf ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER martymcf
WORKDIR /home/martymcf

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ${HOME}/.zshrc

RUN echo '\nexport PATH="${HOME}/.local/bin:${PATH}"' >> ${HOME}/.zshrc && \
    echo 'setopt SHARE_HISTORY' >> ${HOME}/.zshrc && \
    echo 'setopt INC_APPEND_HISTORY' >> ${HOME}/.zshrc && \
    echo 'setopt HIST_IGNORE_DUPS' >> ${HOME}/.zshrc && \
    echo 'setopt HIST_FIND_NO_DUPS' >> ${HOME}/.zshrc && \
    echo 'HISTSIZE=10000' >> ${HOME}/.zshrc && \
    echo 'SAVEHIST=10000' >> ${HOME}/.zshrc

WORKDIR /workspaces/spheral

CMD ["/usr/bin/zsh"]
