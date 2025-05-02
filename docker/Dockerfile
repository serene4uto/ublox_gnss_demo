ARG BASE_IMAGE=ros:humble-ros-base-jammy

FROM $BASE_IMAGE 
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG ROS_DISTRO

# Copy files
COPY default.env /ublox_gnss_demo/
# COPY src /ublox_gnss_demo/src
COPY docker/scripts/cleanup_apt.sh /ublox_gnss_demo/cleanup_apt.sh
RUN chmod +x /ublox_gnss_demo/cleanup_apt.sh

# Install apt packages and add GitHub to known hosts for private repositories
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  gosu \
  ssh \
  && /ublox_gnss_demo/cleanup_apt.sh \
  && mkdir -p ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

