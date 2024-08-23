FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt install -y \
        automake bat build-essential cmake \
        curl fzf gdb git htop jq libssl-dev \
        make neofetch ninja-build pkg-config \
        pip python3-pip ripgrep shellcheck tmux \
        tree valgrind wget zlib1g-dev sudo \
        software-properties-common

RUN add-apt-repository ppa:neovim-ppa/unstable && \
    apt-get update && apt-get install -y neovim

# Add the LLVM APT repository
RUN echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee /etc/apt/sources.list.d/llvm-toolchain-jammy-18.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee -a /etc/apt/sources.list.d/llvm-toolchain-jammy-18.list && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update

RUN apt install -y \
        clang-format-18 clang-tidy-18 clang-tools-18 clang-18 clangd-18 \
        libc++-18-dev libc++1-18 libc++abi-18-dev libc++abi1-18 \
        libclang-18-dev libclang1-18 liblldb-18-dev \
        libllvm-18-ocaml-dev libomp-18-dev libomp5-18 \
        lld-18 lldb-18 llvm-18-dev llvm-18-runtime llvm-18 \
        python3-clang-18 libpolly-18-dev 

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-18 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100


RUN echo 'export PS1="\[\e[33m\]cfd-dev\[\e[0m\] \W $ "' >> /root/.bashrc
RUN echo 'alias vim="nvim"' >> /root/.bashrc
RUN echo 'alias vimdiff="nvim -d"' >> /root/.bashrc
RUN echo 'alias cat="batcat --paging=never --style header,numbers"' >> /root/.bashrc

RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash -
RUN apt install -y nodejs fonts-firacode

RUN mkdir -p /root/.config/nvim
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

COPY resources/init.lua /root/.config/nvim/init.lua
COPY resources/coc-settings.json /root/.config/nvim/coc-settings.json
RUN nvim --headless +PlugInstall +qall
RUN nvim --headless +"CocInstall -sync coc-clangd|q"
RUN echo 'vim.cmd("colorscheme yitzchok-contrast")' >> /root/.config/nvim/init.lua

WORKDIR /root
