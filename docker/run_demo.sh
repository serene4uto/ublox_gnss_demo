#!/bin/bash

DOCKER_IMAGE="ghcr.io/serene4uto/ublox_gnss_demo:latest"

option_pull="no"

print_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --help, -h      Display this help message"
    echo "  --pull          Pull the Docker image before running"
}

parse_arguments() {
    while [ "$1" != "" ]; do
        case "$1" in
            --help|-h)
                print_help
                exit 0
                ;;
            --pull)
                option_pull="yes"
                ;;
            *)
                echo "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    parse_arguments "$@"

    set -x

    if [ "$option_pull" = "yes" ]; then
        echo "Pulling the latest Docker image..."
        docker pull "$DOCKER_IMAGE"
    else
        echo "Skipping docker pull."
    fi

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
}

main "$@"
