# Use the official ROS image as the base image
FROM ros:humble-ros-core-jammy

# Set shell for running commands
SHELL ["/bin/bash", "-c"]

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  git \
  python3-colcon-common-extensions \
  python3-colcon-mixin \
  python3-rosdep \
  python3-vcstool \
  && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

# setup colcon mixin and metadata
RUN colcon mixin add default \
  https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
  colcon mixin update && \
  colcon metadata add default \
  https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
  colcon metadata update

RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-humble-desktop=0.10.0-1* \
  && rm -rf /var/lib/apt/lists/*

# install Gazebo Harmonic, Xacro
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  lsb-release \
  gnupg \
  && curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
  && apt-get update \
  && apt-get install -y --no-install-recommends gz-harmonic ros-humble-xacro ros-humble-ros-gz-bridge ros-humble-ros-gz-sim \
  && rm -rf /var/lib/apt/lists/*

# Set the entrypoint to source ROS setup.bash and run a bash shell
CMD ["/bin/bash"]
