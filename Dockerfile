# Base Image
FROM ubuntu:22.04

# Set environment variables upfront
ENV DEBIAN_FRONTEND=noninteractive \
    CSCOPE_EDITOR=nvim

ENV TASKRC=~/Develop/dev-image/data_dir/taskwarrior/taskrc
ENV TASKDATA=~/Develop/dev-image/data_dir/taskwarrior/

# Install general packages, clean up APT cache afterward
RUN apt update -y && \
    apt install --no-install-recommends -y \
        automake bat build-essential cmake curl fzf gdb git gpg gpg-agent htop jq libssl-dev \
        make neofetch ninja-build pkg-config pip python3-pip ripgrep shellcheck gettext tmux \
        tree valgrind wget zlib1g-dev sudo software-properties-common file libzstd-dev \
        cscope fonts-firacode graphviz cloc unzip ffmpeg zip cargo taskwarrior

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
        llvm-18 python3-clang-18 libpolly-18-dev

# Set LLVM alternatives
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-18 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100

# Install Quarto
RUN wget -qO /tmp/quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.31/quarto-1.7.31-linux-arm64.deb && \
    dpkg -i /tmp/quarto.deb && \
    rm /tmp/quarto.deb

# Install Python packages
RUN pip3 install --no-cache-dir ipython pandas numpy matplotlib seaborn torch pylint plotly jupyterlab notebook docling
RUN jupyter labextension enable widgetsnbextension

# Install Neovim from GitHub
RUN git clone --branch v0.10.1 https://github.com/neovim/neovim.git && \
    cd neovim && \
    make -j 4 && \
    make install && \
    cd .. && rm -rf neovim

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt install --no-install-recommends -y nodejs

# Neovim configuration
RUN mkdir -p /root/.config/nvim && \
    curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy Neovim config files
COPY resources/coc-settings.json /root/.config/nvim/coc-settings.json
COPY resources/init.lua /root/.config/nvim/init.lua

# Clone and build avante.nvim with Rust
RUN git clone --branch v0.0.24 https://github.com/yetone/avante.nvim.git /root/.config/nvim/avante.nvim && \
    cd /root/.config/nvim/avante.nvim && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup update && \
    make

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

# Set up github email

# Set working directory
WORKDIR /root
