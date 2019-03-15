#!/usr/bin/env sh

# Setup the style of color
RED='\033[0;31m'
NC='\033[0m'

# Make sure processes in the container can connect to the x server
# Necessary so gazebo can create a context for OpenGL rendering (even headless)
XAUTH=/tmp/.docker.xauth
XSOCK=/tmp/.X11-unix
sudo touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Find current directory and transfer it to container directory for Docker
current_dir="$(pwd)"
host_dir="/home/$USER/"
container_dir="/hosthome/"
goal_dir=${current_dir//$host_dir/$container_dir}
echo "goal_dir: \"${goal_dir}\""

# Check the command 'nvidia-docker' is existing or not
ret_code="$(command -v nvidia-docker)"
if [ -z "$ret_code" ]
then
    printf "${RED}\"nvidia-docker\" is not found, so substitute docker. $NC\n"
    docker run -it --rm --name hcc_lab3 \
                    -e DISPLAY \
                    -e QT_X11_NO_MITSHM=1 \
                    -e XAUTHORITY=$XAUTH \
                    --device /dev/dri \
                    -v "$XAUTH:$XAUTH" \
                    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
                    -v "/etc/localtime:/etc/localtime:ro" \
                    -v "/dev/input:/dev/input" \
                    -v "/home/$USER:/hosthome" \
                    --net host -w ${goal_dir} argnctu/base-image bash
else
    printf "Run \"nvidia-docker\"\n"
    nvidia-docker run -it --rm --name hcc_lab3 \
                    -e DISPLAY \
                    -e QT_X11_NO_MITSHM=1 \
                    -e XAUTHORITY=$XAUTH \
                    --device /dev/dri \
                    -v "$XAUTH:$XAUTH" \
                    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
                    -v "/etc/localtime:/etc/localtime:ro" \
                    -v "/dev/input:/dev/input" \
                    -v "/home/$USER:/hosthome" \
                    --net host -w ${goal_dir} argnctu/base-image bash
fi
