Background - the official image
-------------------------------
The official OpenMower [docker image](https://github.com/ClemensElflein/open_mower_ros/pkgs/container/open_mower_ros) contains a lot of things:
- ROS base image
- Dependencies needed for the [OpenMower ROS workspace](https://github.com/ClemensElflein/open_mower_ros)
- Build results for the OpenMower ROS workspace
- Pre-built [official web app](https://github.com/ClemensElflein/OpenMowerApp) (committed to the [ROS workspace](https://github.com/ClemensElflein/open_mower_ros/tree/main/web))
- Nginx
- Mosquitto

Everything in one image, everything running in the same Podman container.

Concept for my approach
-----------------------
When I started tinkering with the project, I quickly noticed that I prefer to split this into multiple pieces. I use Docker Compose for all my self-hosted projects, think that it's easier to use than Podman and especially supports managing multiple containers at once. The result can be found in this repository.

The first step was to use separate containers for Nginx and Mosquitto using their official images, rather than installing the packages on the very old Ubuntu that comes with the ROS base image.

Since I wanted to develop new features, the build results for the ROS workspace were irrelevant for me. They also meant that needed to build a new image for every code change, compiling the project from scratch each time. Instead, I decided to build a container which contains only the dependencies (derived from the `package.xml` files), mount the ROS workspace from the host filesystem and therefore keep the `build` folder between compilations.

I still use the pre-build app. Theoretically, I could compile it myself, or even run it on a separate service, but I didn't feel the need for it yet.

Setup
-----
It's been a while since I set this up on my own mower, so let me know in case I missed to mention something:

1. Remove Podman and the `openmower` service - not sure what the exact steps were.
2. Install Docker: https://docs.docker.com/engine/install/debian/#install-using-the-repository.
3. `sudo usermod -aG docker openmower`
4. `git clone --recurse-submodules https://github.com/ClemensElflein/open_mower_ros.git`
5. `git clone https://github.com/rovo89/open_mower_bare_container.git docker`
6. `cd docker`
8. `cp .env.example .env`
9. `./build_container.sh`
9. `./init_workspace.sh`
10. `./compile.sh`
11. `docker compose up -d`

This checks out the source to the host fileystem and builds the Docker container, which contains only the ROS base image plus the OpenMower dependencies. Then it uses this image for an ad-hoc Docker container (`docker run --remove`) to run `catkin_make`. Again, the worktree checked out in step 4 is mounted into that container, so it can see the source code and will write back the build results. The same image and mount is used in the last step to actually run OpenMower and related services.

Development
-----------
I develop with VS Code in a DevContainer. It's the same pattern and allows me to have code completion (including intermediate build results). I can also quickly recompile a certain package using `make -C build mower_comms_v2/fast` in the integrated terminal. For this to work, you need to replace `.devcontainer/devcontainer.json` in the ROS workspace with [the one from this repository](https://github.com/rovo89/open_mower_bare_container/blob/main/devcontainer.json). With `git update-index --skip-worktree .devcontainer/devcontainer.json`, you won't see this as a pending change in Git.
