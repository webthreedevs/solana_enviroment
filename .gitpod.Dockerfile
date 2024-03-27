FROM ubuntu:20.04

ARG USERNAME=ubuntu
ARG REPO_NAME=solana-curriculum
ARG HOMEDIR=/workspace/$REPO_NAME

ENV TZ="America/New_York"
ENV HOME=/workspace

RUN apt-get update && apt-get install -y sudo

# Unminimize Ubuntu to restore man pages
RUN yes | unminimize

# Set up timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set up user, disable pw, and add to sudo group
RUN adduser --disabled-password \
  --gecos '' ${USERNAME}

RUN adduser ${USERNAME} sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
  /etc/sudoers

# Install packages for projects
RUN sudo apt-get update

RUN sudo apt-get install -y curl git bash-completion man-db htop nano

# Install Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Install build tools required for Rust
RUN sudo apt-get install -y build-essential

# Install Rust using rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/workspace/.cargo/bin:${PATH}"

# Install Solana
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.18.1/install)"

# Create a directory for global npm packages
RUN mkdir -p ~/.npm-global

# Set npm prefix to the created directory
RUN npm config set prefix '~/.npm-global'

# Install global npm packages: Yarn and Anchor CLI
RUN npm install -g yarn @coral-xyz/anchor-cli@0.28.0

# Install Yarn and TypeScript globally
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN npm install -g typescript

# Configure environment paths in .bashrc and .profile
RUN echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

RUN echo 'if [ -n "$BASH_VERSION" ]; then' >> ~/.profile
RUN echo '    # include .bashrc if it exists' >> ~/.profile
RUN echo '    if [ -f "$HOME/.bashrc" ]; then' >> ~/.profile
RUN echo '        . "$HOME/.bashrc"' >> ~/.profile
RUN echo '    fi' >> ~/.profile
RUN echo 'fi' >> ~/.profile

# Set up the working directory and copy the project files
WORKDIR ${HOMEDIR}
COPY . .

RUN cd ${HOMEDIR} && npm install
