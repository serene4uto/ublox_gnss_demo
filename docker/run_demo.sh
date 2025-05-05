#!/bin/bash

set -x

docker run \
    --rm \
    -it \
    --net host \
    --ipc host \
    --privileged \
    -v /dev/shm:/dev/shm \
    -v /etc/localtime:/etc/localtime:ro \
    -v /dev:/dev \
    ghcr.io/serene4uto/ublox_gnss_demo:latest \
    /bin/bash -c " \
        source /opt/ros/humble/setup.bash \
        && source /opt/ublox_gnss_demo/setup.bash \
        && ros2 launch ublox_gnss_demo_launch demo.launch.py \
            ntrip:=true \
        "