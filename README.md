# Visual Inertial Navigation

A Vision-aided Inertial Navigation System (VINS) [1] fuses data from a camera and an Inertial Measurement Unit (IMU) to track the six-degrees-of-freedom (d.o.f.) position and orientation (pose) of a sensing platform. In this project, the poses which are calculated from a vision system are fused with an IMU using Extended Kalman Filter (EKF) to obtain the optimal pose.

## About Code

The poses of a quadcopter navigating an environment consisting of AprilTags are obtained by solving a factor graph formulation of SLAM using GTSAM(See [here](https://github.com/rahul-sb/SLAMusingGTSAM) for the project). Accelerometer and gyroscope values are derived from an IMU mounted on the quadcopter. 

The sampling frequency of IMU is higher than that of the camera, so the IMU data is downsampled to match the rate of the camera data. Each of these downsampled IMU data is transformed to coordinate system of the camera (since camera and IMU are not physically in the same location).

The orientation from GTSAM is received as a quaternion, so this is converted to Euler angles before it is used in the Extended Kalman filter (EKF) algorithm. 

The EKF consists of two main steps: Predict and Update. During the predict step, the most likely state of the quadcopter is calculated using the IMU data. This state is then updated during the update step with the pose obtained from the perception system (using GTSAM for this project) using a weighted average, with more weight being given to system (camera/IMU) with higher certainty. The exact calculation, along with derivation, can be found [here](https://alliance.seas.upenn.edu/~meam620/wiki/index.php?n=Main.Schedule2015?action=download&upname=2015_filtering.pdf).

## How to run the code?

Add to MATLAB path the folders "/src", "/libraries" and "/data". Open the "efk_main.m" file in "/src" folder. If you want to view the results from different flight patterns of quadcopter change the 'DataStraightLine.mat' to any file in "/data", in the "ekf_main.m" file. Run the "ekf_main.m" file. You can visualize the results for different noise values by changing the "Q_t" and "R_t" values in lines 20 and 21 in the "ekf_main.m" file and see what happens when you give a very high noise value to one of the sensors.


## Results

Location of quadcopter:

![img](https://drive.google.com/uc?export=view&id=16eCEcQqhZCgYkVDb4z0_MCXcgG35HtHf)

You can see that the EKF tracks the GTSAM pose. There are two reasons for this:

1. I've specified a higher noise sigma for the IMU data compared to the camera data.

2. I've chosen the starting position (global coordinates) of quadcopter as (0,0,0). I decided to use these values to interpret the working of the algorithm. You can change this value in line 27 in "ekf_main.m" to the initial value obtained from GTSAM.


## References
[1] D. G. Kottas and J. A. Hesch and S. L. Bowman and S. I. Roumeliotis, On the Consistency of Vision-aided
Inertial Navigation, International Symposium on Experimental Robotics, Quebec, Canada, June 2012.

[2] https://alliance.seas.upenn.edu/~meam620/wiki/index.php?n=Main.Schedule2015?action=download&upname=2015_filtering.pdf
