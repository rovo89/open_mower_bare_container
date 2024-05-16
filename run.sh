#!/bin/bash
set -euo pipefail
cd -P -- "$(dirname -- $(readlink -f -- "${BASH_SOURCE[0]}"))"
source .env
docker run -it -v $OM_SRC_DIR:/opt/open_mower_ros $OM_DEV_IMAGE_TAG $@
