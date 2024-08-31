#!/bin/sh

devbox install
mise install -yj "$(nproc)"
direnv allow .
