#!/bin/bash

# 默认起始步骤
START_STEP=${1:-1}

echo "Starting VINS-ROS-EGO deployment from step $START_STEP..."

# Function to check last command result
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: Step $1 failed. Exiting."
        exit 1
    else
        echo "Step $1 completed successfully."
    fi
}

# Function to check if current step should be executed
should_execute_step() {
    local step_num=$1
    # Convert to number for comparison (in case of decimal steps like 2.1)
    if (( $(echo "$step_num >= $START_STEP" | bc -l) )); then
        return 0  # Should execute
    else
        return 1  # Should skip
    fi
}

# Step 1: create the ros workspace
if should_execute_step 1; then
    echo "Step 1: Creating ROS workspace..."
    mkdir -p /home/nv/ros_ws/src
    cd /home/nv/ros_ws/src
    check_error "1"
    echo "Created ROS workspace at /home/nv/ros_ws/src"
else
    echo "Skipping Step 1: Creating ROS workspace..."
    cd /home/nv/ros_ws/src
fi

# Step 2: clone the repository
if should_execute_step 2.1; then
    echo "Step 2: Cloning repositories..."
    git clone https://gitee.com/fancinnov/fcu_core.git
    check_error "2.1"
fi

if should_execute_step 2.2; then
    git clone https://gitee.com/fancinnov/quadrotor_msgs.git
    check_error "2.2"
fi

if should_execute_step 2.3; then
    sudo apt-get -y install ros-noetic-serial libeigen3-dev 
    check_error "2.3"
fi

if should_execute_step 2.4; then
    sudo cp /home/nv/20.04-vins-ego-ros/fcu_core修改文件/fcu_bridge_001.cpp /home/nv/ros_ws/src/fcu_core/src/fcu_bridge_001.cpp
    check_error "2.4"
fi

# Step 3: build the workspace
if should_execute_step 3; then
    echo "Step 3: Building ROS workspace..."
    cd /home/nv/ros_ws
    source /opt/ros/noetic/setup.bash
    catkin_make
    check_error "3"
    echo "Built the ROS workspace."
else
    echo "Skipping Step 3: Building ROS workspace..."
    cd /home/nv/ros_ws
    source /opt/ros/noetic/setup.bash
fi

# Step 4: chmod the usb permissions
if should_execute_step 4; then
    echo "Step 4: Setting USB permissions..."
    sudo cp /home/nv/20.04-vins-ego-ros/70-ttyusb.rules /etc/udev/rules.d/
    check_error "4"
else
    echo "Skipping Step 4: Setting USB permissions..."
fi

# Step 5: install nvidia jetpack
if should_execute_step 5.1; then
    echo "Step 5: Installing NVIDIA Jetpack..."
    echo "deb http://repo.download.nvidia.com/jetson/common r35.4 main" | sudo tee -a /etc/apt/sources.list.d/nvidia-l4t-apt-source.list > /dev/null
    check_error "5.1"
fi

if should_execute_step 5.2; then
    echo "deb http://repo.download.nvidia.com/jetson/t234 r35.4 main" | sudo tee -a /etc/apt/sources.list.d/nvidia-l4t-apt-source.list > /dev/null
    check_error "5.2"
fi

if should_execute_step 5.3; then
    sudo apt update
    check_error "5.3"
fi

if should_execute_step 5.4; then
    sudo apt -y install nvidia-jetpack
    check_error "5.4"
fi

if should_execute_step 5.5; then
    cat >> ~/.bashrc <<EOF

# CUDA environment variables
export CUDA_HOME=/usr/local/cuda
export PATH=\$CUDA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH
EOF
    check_error "5.5"
fi

if should_execute_step 5.6; then
    cd /usr/include && sudo cp cudnn* /usr/local/cuda/include 
    check_error "5.6"
fi

if should_execute_step 5.7; then
    cd /usr/lib/aarch64-linux-gnu && sudo cp libcudnn* /usr/local/cuda/lib64 
    check_error "5.7"
fi

if should_execute_step 5.8; then
    sudo apt -y install python3-pip 
    check_error "5.8"
fi

if should_execute_step 5.9; then
    sudo -H pip3 install -U pip
    check_error "5.9"
fi

if should_execute_step 5.10; then
    sudo -H pip install jetson-stats
    check_error "5.10"
fi

# step 6: install librealsense
if should_execute_step 6.1; then
    echo "Step 6: Installing librealsense..."
    unzip /home/nv/20.04-vins-ego-ros/其它依赖库/librealsense -d /home/nv/
    check_error "6.1"
fi

if should_execute_step 6.2; then
    sudo apt-get update
    check_error "6.2"
fi

if should_execute_step 6.3; then
    sudo apt-get -y install git cmake libssl-dev libusb-1.0-0-dev pkg-config libgtk-3-dev
    check_error "6.3"
fi

if should_execute_step 6.4; then
    sudo apt-get -y install libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev
    check_error "6.4"
fi

if should_execute_step 6.5; then
    cd /home/nv/librealsense/build
    cmake ..
    check_error "6.5"
fi

if should_execute_step 6.6; then
    sudo make install -j8
    check_error "6.6"
fi

if should_execute_step 6.7; then
    cd /home/nv/librealsense
    sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/ 
    check_error "6.7"
fi

if should_execute_step 6.8; then
    sudo udevadm control --reload-rules 
    check_error "6.8"
fi

if should_execute_step 6.9; then
    sudo udevadm trigger 
    check_error "6.9"
fi

if should_execute_step 6.10; then
    pip install pyrealsense2
    check_error "6.10"
fi

if should_execute_step 6.11; then
    sudo apt-get -y install ros-noetic-realsense2-camera 
    check_error "6.11"
fi

if should_execute_step 6.12; then
    source ~/.bashrc 
    check_error "6.12"
fi

# step 7: install opencv 4.6.0
if should_execute_step 7.1; then
    echo "Step 7: Installing OpenCV 4.6.0..."
    unzip /home/nv/20.04-vins-ego-ros/其它依赖库/opencv-4.6.0.zip -d /home/nv/
    check_error "7.1"
fi

if should_execute_step 7.2; then
    unzip /home/nv/20.04-vins-ego-ros/其它依赖库/opencv_contrib-4.6.0.zip -d /home/nv/
    check_error "7.2"
fi

if should_execute_step 7.3; then
    cd /home/nv/opencv-4.6.0/build
    sudo make install
    check_error "7.3"
fi

# step 8: install cv-bridge for ROS Noetic
if should_execute_step 8.1; then
    echo "Step 8: Installing cv-bridge for ROS Noetic..."
    cp -rf /home/nv/20.04-vins-ego-ros/其它依赖库/catkin_pkg /home/nv/
    check_error "8.1"
fi

if should_execute_step 8.2; then
    cd /home/nv/catkin_pkg
    source /opt/ros/noetic/setup.bash
    catkin_make
    check_error "8.2"
fi

if should_execute_step 8.3; then
    echo "source /home/nv/catkin_pkg/devel/setup.bash" >> /home/nv/.bashrc
    check_error "8.3"
fi

# step 9: install ceres-solver and vins-fusion-gpu
if should_execute_step 9.1; then
    echo "Step 9: Installing ceres-solver and vins-fusion-gpu..."
    unzip /home/nv/20.04-vins-ego-ros/其它依赖库/ceres-solver-1.14.0.zip -d /home/nv/
    check_error "9.1"
fi

if should_execute_step 9.2; then
    cd /home/nv/ceres-solver-1.14.0/build
    sudo apt-get -y install libgoogle-glog-dev libgflags-dev 
    check_error "9.2"
fi

if should_execute_step 9.3; then
    sudo apt-get -y install libatlas-base-dev 
    check_error "9.3"
fi

if should_execute_step 9.4; then
    sudo apt-get -y install libeigen3-dev
    check_error "9.4"
fi

if should_execute_step 9.5; then
    cmake ..
    check_error "9.5"
fi

if should_execute_step 9.6; then
    sudo make install -j8
    check_error "9.6"
fi

if should_execute_step 9.7; then
    cp -rf /home/nv/20.04-vins-ego-ros/vins-fusion-gpu /home/nv/
    check_error "9.7"
fi

if should_execute_step 9.8; then
    cd /home/nv/vins-fusion-gpu
    source /opt/ros/noetic/setup.bash
    catkin_make
    check_error "9.8"
fi

# step 10: install ego-planner
if should_execute_step 10.1; then
    echo "Step 10: Installing ego-planner..."
    sudo apt-get -y install libarmadillo-dev
    check_error "10.1"
fi

if should_execute_step 10.2; then
    sudo apt-get -y install ros-noetic-cv-bridge
    check_error "10.2"
fi

if should_execute_step 10.3; then
    sudo apt-get -y install ros-noetic-cmake-modules
    check_error "10.3"
fi

if should_execute_step 10.4; then
    cp -rf /home/nv/20.04-vins-ego-ros/ego-planner /home/nv/
    check_error "10.4"
fi

if should_execute_step 10.5; then
    cd /home/nv/ego-planner
    source /opt/ros/noetic/setup.bash
    catkin_make -DCMAKE_BUILD_TYPE=Release 
    check_error "10.5"
fi

echo "All steps completed successfully!"