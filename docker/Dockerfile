ARG BASE_IMAGE=ros:humble-ros-base-jammy

FROM $BASE_IMAGE 
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG ROS_DISTRO
ENV CCACHE_DIR="/root/.ccache"

# Copy files
COPY default.env requirements.txt /ublox_gnss_demo/
COPY src /ublox_gnss_demo/src
COPY docker/scripts/resolve_rosdep_keys.sh /ublox_gnss_demo/resolve_rosdep_keys.sh
RUN chmod +x /ublox_gnss_demo/resolve_rosdep_keys.sh
COPY docker/scripts/cleanup_apt.sh /ublox_gnss_demo/cleanup_apt.sh
RUN chmod +x /ublox_gnss_demo/cleanup_apt.sh
COPY  docker/scripts/build_and_clean.sh /ublox_gnss_demo/build_and_clean.sh
RUN chmod +x /ublox_gnss_demo/build_and_clean.sh
WORKDIR /ublox_gnss_demo

# Install apt packages and add GitHub to known hosts for private repositories
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  gosu \
  ssh \
  ccache \
  python3 \
  python3-pip \
  && /ublox_gnss_demo/cleanup_apt.sh \
  && mkdir -p ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install ROS packages
RUN rosdep update && /ublox_gnss_demo/resolve_rosdep_keys.sh /ublox_gnss_demo/src ${ROS_DISTRO} \
  > /rosdep-depend-packages.txt \
  && cat /rosdep-depend-packages.txt 

RUN apt-get update \
  && cat /rosdep-depend-packages.txt | xargs apt-get install -y --no-install-recommends \
  && /ublox_gnss_demo/cleanup_apt.sh

# Install Python packages
RUN pip install --no-cache-dir -r /ublox_gnss_demo/requirements.txt

# Build source
RUN mkdir -p ${CCACHE_DIR} \
    && source /opt/ros/"$ROS_DISTRO"/setup.bash \
    && /ublox_gnss_demo/build_and_clean.sh ${CCACHE_DIR} /opt/ublox_gnss_demo

# Create entrypoint
COPY docker/etc/ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

