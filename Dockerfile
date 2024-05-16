FROM docker.io/ros:noetic-ros-base-focal AS base
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/open_mower_ros
SHELL ["/bin/bash", "-c"]

####################################################################################################

FROM base AS dependencies
RUN --mount=type=bind,source=src,target=src \
    set -o pipefail && \
    rosdep install --from-paths src --ignore-src --simulate | sed -nr 's/.*apt-get install (\S+).*/\1/p' | sort > /rosdeps

####################################################################################################

FROM base AS assemble
RUN --mount=type=bind,from=dependencies,source=/rosdeps,target=/rosdeps \
    --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    rosdep update --rosdistro $ROS_DISTRO && \
    apt-get install --no-install-recommends --yes git $(cat /rosdeps)
COPY .github/assets/openmower_entrypoint.sh /openmower_entrypoint.sh
