function [imu2cam, imu, gtsam, isam2] = fn_loadData(file_name)

load('CalibParams.mat');
load(file_name);

%% Get the transformations
euler_angles = quat2eul(qIMUToC','zyx');
rot = eul2rotm(euler_angles,'zyx'); 
trans = TIMUToC;

imu2cam = var2struct(rot, trans);

imu.values = IMU(:,5:end-1)';
imu.time = IMU(:,end)' - IMU(1,end);

rpy = quat2eul(PoseGTSAM(:,4:end),'xyz');
gtsam.state = [PoseGTSAM(:,1:3), rpy, VelGTSAM]';
gtsam.time = TLeftImgs' - TLeftImgs(1);

rpy = quat2eul(PoseiSAM2(:,4:end),'xyz');
isam2.state = [PoseiSAM2(:,1:3), rpy, VeliSAM2]';
isam2.time = TLeftImgs'- TLeftImgs(1);

%{ 
    IMU: 
    [QuaternionW, QuaternionX, QuaternionY, QuaternionZ,... 
     AccelX, AccelY, AccelZ,GyroX, GyroY, GyroZ, Timestamp]
    
    TLeftImgs:
    Timestamps for Left Camera Frames (Images).
    Example: Frame 1 was collected at time TLeftImgs(1)

    qIMUToC:
    Quaternion to transform from IMU to Camera frame (QuaternionW,
    QuaternionX, QuaternionY, QuaternionZ).
    
    TIMUToC:
    Translation to transform from IMU to Camera frame (TransX, TransY, TransZ).

    PoseGTSAM and PoseiSAM2:
    [PosX, PosY, PosZ, QuaternionW, QuaternionX, QuaternionY, QuaternionZ]
    Here the row number corresponds to frame number, if pose doesn't exist or is erroneous
    due to missed tag detections then the whole row will be zeros.

    VelGTSAM and VeliSAM2:
    [Vx,Vy,Vz]
    Here the row number corresponds to frame number, if velocity doesn't exist or is
    erroneous due to missed tag detections then the whole row will be zeros.
    
%}


end