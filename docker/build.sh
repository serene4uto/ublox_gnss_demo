#!/bin/env bash

set -e

# Function to print help message
print_help() {
    echo "Usage: build.sh [OPTIONS]"
    echo "Options:"
    echo "  --help          Display this help message"
    echo "  -h              Display this help message"
    echo "  --platform      Specify the platform (default: current platform)"
    echo ""
    echo "Note: The --platform option should be one of 'linux/amd64' or 'linux/arm64'."
}

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
WORKSPACE_ROOT="$SCRIPT_DIR/.."

# Parse arguments
parse_arguments() {
    while [ "$1" != "" ]; do
        case "$1" in
        --help | -h)
            print_help
            exit 1
            ;;
        --platform)
            option_platform="$2"
            shift
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

# Set platform
set_platform() {
    if [ -n "$option_platform" ]; then
        platform="$option_platform"
    else
        platform="linux/amd64"
        if [ "$(uname -m)" = "aarch64" ]; then
            platform="linux/arm64"
        fi
    fi
}

# Load env
load_env() {
    source "$WORKSPACE_ROOT/default.env"
}

# Install necessary packages
install_packages() {
    sudo apt-get update
    sudo apt-get install -y \
        git \
        python3-vcstool
}

# Clone repositories
clone_repositories() {
    cd "$WORKSPACE_ROOT"
    if [ ! -d "src" ]; then
        mkdir -p src
        vcs import src <ublox_gnss_demo.repos
    else
        echo "Source directory already exists. Updating repositories..."
        vcs import src <ublox_gnss_demo.repos
        vcs pull src
    fi
}

# Build images
build_images() {
    # https://github.com/docker/buildx/issues/484
    export BUILDKIT_STEP_LOG_MAX_SIZE=10000000

    echo "Building images for platform: $platform"
    echo "ROS distro: $rosdistro"
    echo "Base image: $base_image"

    set -x
    docker buildx build \
        --platform "$platform" \
        --build-arg ROS_DISTRO="$rosdistro" \
        --build-arg BASE_IMAGE="$base_image" \
        -t "$ublox_gnss_demo_image" \
        -f "$WORKSPACE_ROOT/docker/Dockerfile" \
        "$WORKSPACE_ROOT"
}

# Remove dangling images
remove_dangling_images() {
    docker image prune -f
}

# Main script execution
parse_arguments "$@"
set_platform
load_env
install_packages
clone_repositories
build_images
remove_dangling_images