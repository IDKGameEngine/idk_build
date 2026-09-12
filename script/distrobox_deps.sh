#!/bin/bash

sudo apt update && sudo apt upgrade

sudo apt install \
    libgl-dev \
    pkg-config \
    cmake \
    ninja-build \
    mesa-utils
