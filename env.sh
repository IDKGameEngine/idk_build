#!/bin/bash

echo "> distrobox enter steamrt4"
distrobox enter steamrt4 -- env PS1='\[\e[1;35m\][📦 \h]\[\e[0m\] \w\$ ' bash --noprofile --norc -i
