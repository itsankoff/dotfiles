#!/bin/bash
set -e

ROOT=$(git rev-parse --show-toplevel)

cp "${ROOT}"/mac/git-hooks/* "${ROOT}"/.git/hooks/
chmod +x "${ROOT}"/.git/hooks/*
