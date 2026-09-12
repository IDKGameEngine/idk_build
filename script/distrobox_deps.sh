#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y \
    libgl-dev \
    pkg-config \
    cmake \
    ninja-build \
    mesa-utils
