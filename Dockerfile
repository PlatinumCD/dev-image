# Base Image
FROM ubuntu:22.04

# Set environment variables upfront
ENV DEBIAN_FRONTEND=noninteractive \
    CSCOPE_EDITOR=nvim

ENV TASKRC=~/Develop/dev-image/data_dir/taskwarrior/taskrc
ENV TASKDATA=~/Develop/dev-image/data_dir/taskwarrior/
ENV TRADEJOURNAL_ROOT=~/Develop/dev-image/data_dir/tradejournal

# Install general packages, clean up APT cache afterward
RUN apt update -y && \
    apt install --no-install-recommends -y \
        automake bat build-essential cmake curl fzf gdb git gpg gpg-agent htop jq libssl-dev \
        make neofetch ninja-build pkg-config pip python3-pip ripgrep shellcheck gettext tmux \
        tree valgrind wget zlib1g-dev sudo software-properties-common file libzstd-dev \
        cscope fonts-firacode graphviz cloc unzip ffmpeg zip cargo taskwarrior

# Install TeX Live with tlmgr
RUN apt-get install --no-install-recommends -y \
    texlive texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra \
    texlive-bibtex-extra texlive-lang-english

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

# Install TinyTeX manually (ARM-compatible)
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    mv ~/bin/* /usr/local/bin/. 2>/dev/null || true && \
    rmdir ~/bin 2>/dev/null || true

# Install Python packages
RUN pip3 install --no-cache-dir ipython pandas numpy matplotlib seaborn torch pylint plotly jupyterlab notebook docling tradejournal==0.1.0
RUN jupyter labextension enable widgetsnbextension

# Install Emscripten SDK
RUN git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk && \
    cd /opt/emsdk && \
    ./emsdk install latest && \
    ./emsdk activate latest

ENV EMSDK=/opt/emsdk
ENV EM_CONFIG=/opt/emsdk/.emscripten
ENV PATH="${EMSDK}:${EMSDK}/upstream/emscripten:${EMSDK}/node/$(ls ${EMSDK}/node)/bin:${PATH}"

# Install Neovim (prebuilt binary)
RUN curl -L https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-arm64.tar.gz \
    | tar -xz && \
    cp -r nvim-linux-arm64/* /usr/local/ && \
    rm -rf nvim-linux-arm64

# Install Node.js v24 (prebuilt)
RUN curl -fsSL https://nodejs.org/dist/v24.0.0/node-v24.0.0-linux-arm64.tar.xz \
    | tar -xJ && \
    cp -r node-v24.0.0-linux-arm64/* /usr/local/ && \
    rm -rf node-v24.0.0-linux-arm64

# Install lazy.nvim
RUN git clone https://github.com/folke/lazy.nvim.git \
    /root/.local/share/nvim/lazy/lazy.nvim

COPY resources/init.lua /root/.config/nvim/init.lua
COPY resources/yitzchok-contrast.vim /root/.config/nvim/colors/yitzchok-contrast.vim

RUN tlmgr install xstring microtype totpages libertine everyshi environ hyperxmp ifmtarg oberdiek ncctools cmap comment caption fancyhdr bibtools newtx preprint upquote doclicense xifthen ccicons csquotes

## Set up shell aliases and prompt in a single command to reduce layers
RUN echo 'export PS1="\[\e[33m\]cfd-dev\[\e[0m\] \W $ "\n' \
    'alias vim="nvim"\n' \
    'alias vimdiff="nvim -d"\n' \
    'alias cat="batcat --paging=never --style header,numbers"' >> /root/.bashrc

RUN nvim --headless "+Lazy! sync" +qa

## Set up github email
#RUN git config --global user.email "cameronfdurbin@gmail.com"

# Set working directory
WORKDIR /root
