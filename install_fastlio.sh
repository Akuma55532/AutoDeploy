#!/bin/bash

# 默认起始步骤
START_STEP=${1:-1}

echo "Starting FASTLIO-EGO-ROS deployment from step $START_STEP..."

# Function to check last command result
check_error() {
    if [ $? -ne 0 ]; then
        local error_time=$(date '+%Y-%m-%d %H:%M:%S')
        local error_msg="Error: Step $1 failed at $error_time"
        echo "$error_msg" | tee -a /home/nv/install_fastlio_errors.txt
        echo "Exiting." | tee -a /home/nv/install_fastlio_errors.txt
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
    sudo cp /home/nv/20.04-fasterlio-ego-ros/fcu_core修改文件/fcu_bridge_001.cpp /home/nv/ros_ws/src/fcu_core/src/fcu_bridge_001.cpp
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

# Step 4: install the Livox-SDK2
if should_execute_step 4.1; then
    echo "Step 4: Installing Livox-SDK2..."
    sudo apt-get -y install libgoogle-glog-dev 
    sudo apt -y install cmake
fi

if should_execute_step 4.2; then
    cp -rf /home/nv/20.04-fasterlio-ego-ros/Livox-SDK2 /home/nv/
    cd /home/nv/Livox-SDK2
    mkdir build && cd build
    check_error "4.2"
fi

if should_execute_step 4.3; then
    cmake ..
    make -j8
    sudo make install
    check_error "4.3"
fi

# Step 5: chmod the usb permissions
if should_execute_step 5; then
    echo "Step 5: Setting USB permissions..."
    sudo cp /home/nv/20.04-fasterlio-ego-ros/70-ttyusb.rules /etc/udev/rules.d/
    check_error "5"
else
    echo "Skipping Step 5: Setting USB permissions..."
fi

# step 6: compile fastlio
if should_execute_step 6.1; then
    echo "Step 6: Compiling FAST-LIO..."
    cp -rf /home/nv/20.04-fasterlio-ego-ros/faster_lio /home/nv/
    cp /home/nv/20.04-fasterlio-ego-ros/mid360.yaml /home/nv/faster_lio/src/faster-lio/config/
    check_error "6.1"
fi

if should_execute_step 6.2; then
    cd /home/nv/faster_lio/src/livox_ros_driver2
    source /opt/ros/noetic/setup.sh
    ./build.sh ROS1
    check_error "6.2"
fi

# Step 7: compile ego-planner
if should_execute_step 7.1; then 
    sudo apt-get -y install libarmadillo-dev 
    sudo apt-get -y install ros-noetic-cv-bridge 
    sudo apt-get -y install ros-noetic-cmake-modules
fi

if should_execute_step 7.2; then
    echo "Step 7: Compiling EGO-PLANNER..."
    cp -rf /home/nv/20.04-fasterlio-ego-ros/ego-planner /home/nv/
    cd /home/nv/ego-planner
    source /opt/ros/noetic/setup.sh
    catkin_make -DCMAKE_BUILD_TYPE=Release
    check_error "7.2"
fi