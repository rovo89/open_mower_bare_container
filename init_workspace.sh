#!/bin/bash
set -euo pipefail
cd -P -- "$(dirname -- $(readlink -f -- "${BASH_SOURCE[0]}"))"
./run.sh bash -c 'cd src && catkin_init_workspace'
