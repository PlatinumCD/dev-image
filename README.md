# C++ Development Docker Image

## Overview

This is a personal Docker image set up for C++ development with Neovim and various other tools. The image is based on Ubuntu 22.04 and includes the LLVM toolchain, along with essential utilities to streamline the development process. It’s designed to suit your specific workflow.

## Specifications

- **Base Image**: Ubuntu 22.04 LTS
- **Tools Installed**:
  - **Build Tools**: `automake`, `build-essential`, `cmake`, `ninja-build`, `make`
  - **Version Control**: `git`
  - **Debugger**: `gdb`, `lldb`, `valgrind`
  - **Neovim**: Installed from unstable PPA, with custom configuration and plugins
  - **LLVM Toolchain**: Includes clang, clangd, clang-format, clang-tidy, LLVM libraries (version 18)
  - **Utilities**: `fzf`, `htop`, `jq`, `ripgrep`, `shellcheck`, `tmux`, `tree`, `wget`, `zlib1g-dev`
  - **Node.js**: Installed via NodeSource for Neovim’s CoC plugin

## Setup

### Build the Docker Image

To build the Docker image:

\```bash
make build
\```

### Run the Docker Container

To start a container with the image:

\```bash
make run
\```

### Push the Image to Docker Registry

If you need to push the image:

\```bash
make push
\```

### Clean Up Local Images

To remove the Docker image locally:

\```bash
make clean
\```

## Neovim Configuration

Neovim is pre-configured with:
- **Vim-Plug**: Manages plugins.
- **coc-clangd**: Provides C++ autocomplete.
- **Custom Settings**: Defined in `init.lua` with a specific colorscheme.

To further customize Neovim, edit the files in `/root/.config/nvim/` within the container.

## Aliases and Shell Configuration

The shell is set up with a custom prompt and the following aliases:
- `vim` and `vimdiff` are aliased to `nvim`.
- `cat` is aliased to `batcat` with specific styles.

## Work Directory

The working directory inside the container is set to `/root`.
