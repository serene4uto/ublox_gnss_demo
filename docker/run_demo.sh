#!/bin/bash

DOCKER_IMAGE="ghcr.io/serene4uto/ublox_gnss_demo:latest"

set -x

# Always pull the latest image before running
echo "Pulling the latest Docker image..."
docker pull "$DOCKER_IMAGE"

docker run \
    --rm \
    -it \
    --net host \
    --ipc host \
    --privileged \
    -v /dev/shm:/dev/shm \
    -v /etc/localtime:/etc/localtime:ro \
    -v /dev:/dev \
    ${DOCKER_IMAGE} \
    /bin/bash -c " \
        source /opt/ros/humble/setup.bash \
        && source /opt/ublox_gnss_demo/setup.bash \
        && ros2 launch ublox_gnss_demo_launch demo.launch.py \
            ntrip:=true \
        "
