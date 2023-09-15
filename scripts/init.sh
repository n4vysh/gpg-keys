#!/bin/sh

devbox install
rtx install -yj "$(nproc)"
direnv allow .
