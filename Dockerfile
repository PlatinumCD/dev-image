# Base Image
FROM ubuntu:22.04

# Set environment variables upfront
ENV DEBIAN_FRONTEND=noninteractive \
    CSCOPE_EDITOR=nvim

# Install general packages, clean up APT cache afterward
RUN apt update -y && \
    apt install --no-install-recommends -y \
        automake bat build-essential cmake curl fzf gdb git gpg gpg-agent htop jq libssl-dev \
        make neofetch ninja-build pkg-config pip python3-pip ripgrep shellcheck tmux \
        tree valgrind wget zlib1g-dev sudo software-properties-common file libzstd-dev \
        cscope fonts-firacode graphviz cloc unzip ffmpeg && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install Neovim from PPA
RUN add-apt-repository ppa:neovim-ppa/unstable && \
    apt update && \
    apt install --no-install-recommends -y neovim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt install --no-install-recommends -y nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir ipython pandas numpy matplotlib seaborn torch

# Add LLVM 18 APT repository, install, and clean up afterward
RUN echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee /etc/apt/sources.list.d/llvm-toolchain-jammy-18.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee -a /etc/apt/sources.list.d/llvm-toolchain-jammy-18.list && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update && \
    apt install --no-install-recommends -y \
        clang-format-18 clang-tidy-18 clang-tools-18 clang-18 clangd-18 \
        libc++-18-dev libc++1-18 libc++abi-18-dev libc++abi1-18 \
        libclang-18-dev libclang1-18 liblldb-18-dev libllvm-18-ocaml-dev \
        libomp-18-dev libomp5-18 lld-18 lldb-18 llvm-18-dev llvm-18-runtime \
        llvm-18 python3-clang-18 libpolly-18-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set LLVM alternatives
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-18 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100

# Neovim configuration
RUN mkdir -p /root/.config/nvim && \
    curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy Neovim config files
COPY resources/init.lua /root/.config/nvim/init.lua
COPY resources/coc-settings.json /root/.config/nvim/coc-settings.json

# Install Neovim plugins
RUN nvim --headless +PlugInstall +qall && \
    nvim --headless +"CocInstall -sync coc-clangd|q" && \
    nvim --headless +"CocInstall -sync coc-python|q" && \
    echo 'vim.cmd("colorscheme yitzchok-contrast")' >> /root/.config/nvim/init.lua

# Set up shell aliases and prompt in a single command to reduce layers
RUN echo 'export PS1="\[\e[33m\]cfd-dev\[\e[0m\] \W $ "\n' \
    'alias vim="nvim"\n' \
    'alias vimdiff="nvim -d"\n' \
    'alias cat="batcat --paging=never --style header,numbers"' >> /root/.bashrc

# Set working directory
WORKDIR /root
