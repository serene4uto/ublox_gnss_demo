#!/bin/bash

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
WORKSPACE_ROOT="$SCRIPT_DIR/.."

DOCKER_IMAGE="ghcr.io/serene4uto/ublox_gnss_demo:latest"

# Default values
option_log_path=""
option_gt_lat=""
option_gt_lon=""
option_pull="no"  # Default: do not pull

# Function to print help message
print_help() {
    echo "Usage: run_eval.sh [OPTIONS]"
    echo "Options:"
    echo "  --help          Display this help message"
    echo "  -h              Display this help message"
    echo "  --log-path      Specify the log path (default: /tmp/ublox_gnss_eval_logs)"
    echo "  --gt-lat        Specify the ground truth latitude"
    echo "  --gt-lon        Specify the ground truth longitude"
    echo "  --pull          Pull the Docker image before running"
}

# Parse command line arguments
parse_arguments() {
    while [ "$1" != "" ]; do
        case "$1" in
        --help | -h)
            print_help
            exit 1
            ;;
        --log-path)
            shift
            option_log_path="$1"
            ;;
        --gt-lat)
            shift
            option_gt_lat="$1"
            ;;
        --gt-lon)
            shift
            option_gt_lon="$1"
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
    # Parse arguments
    parse_arguments "$@"

    if [ -z "$option_gt_lat" ] || [ -z "$option_gt_lon" ]; then
        echo "Error: Ground truth latitude and longitude must be specified."
        print_help
        exit 1
    fi

    # Check if the log path is set, if not, use the default
    if [ -z "$option_log_path" ]; then
        option_log_path="/tmp/ublox_gnss_eval_logs"
    fi

    echo "Parsed arguments:"
    echo "  Log path: $option_log_path"
    echo "  Ground truth latitude: $option_gt_lat"
    echo "  Ground truth longitude: $option_gt_lon"
    echo "  Pull docker image: $option_pull"

    mkdir -p ${option_log_path}

    # Only pull if --pull is specified
    if [ "$option_pull" = "yes" ]; then
        echo "Pulling the latest Docker image: ${DOCKER_IMAGE}"
        docker pull ${DOCKER_IMAGE}
    else
        echo "Skipping docker pull."
    fi

    set -x
    docker run \
        --rm \
        -it \
        --net host \
        --ipc host \
        --privileged \
        -v /dev/shm:/dev/shm \
        -v /etc/localtime:/etc/localtime:ro \
        -v ${option_log_path}:/tmp/ublox_gnss_eval_logs \
        ${DOCKER_IMAGE} \
        /bin/bash -c " \
            source /opt/ros/humble/setup.bash \
            && source /opt/ublox_gnss_demo/setup.bash \
            && ros2 run gnss_utils_ros gnss_eval \
                --ros-args \
                --param log_enable:=false \
                --param log_path:=${option_log_path} \
                --param ground_truth.latitude:=${option_gt_lat} \
                --param ground_truth.longitude:=${option_gt_lon} \
                --remap /fix:=/ublox/fix \
            "
}

main "$@"
