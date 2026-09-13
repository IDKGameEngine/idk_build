#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y \
    libgl-dev \
    pkg-config \
    cmake \
    ninja-build \
    mesa-utils \
    lsb-release gpg wget \
    python3-gi gir1.2-gtk-3.0
