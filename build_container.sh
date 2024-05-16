#!/bin/bash
set -euo pipefail
cd -P -- "$(dirname -- $(readlink -f -- "${BASH_SOURCE[0]}"))"
source .env
docker build $OM_SRC_DIR -f Dockerfile -t $OM_DEV_IMAGE_TAG $@
