%{
    How to use:
    1. Add the contents of this folder, "Data" and "Supplementary"
       folder to the path.
    2. Change the different .mat files such as DataStraightLine.mat,
       DataMountain.mat etc., to test on different datasets.
    3. Refer to EKF_Tutorial.pdf in "Docs" folder for how this algorithm is implemented.
%}

%% Load data and equations
[imu2cam, IMU, GTSAM, iSAM2] = fn_loadData('DataStraightLine.mat'); % Make sure that the data is in MATLAB path
[model, jacobians] = fn_loadEquations();

%% Specify Noise Sigmas
N_g = [1;1;1]*1e0; % for gyroscope
N_a = [1;1;1]*1e0; % for accelerometer
N_bias_g = [1;1;1]*1e1;  % for gyro bias
N_bias_a = [1;1;1]*1e1;  % for accelerometer bias

Q_t = diag([N_g; N_a; N_bias_g; N_bias_a]); % Process noise
R_t = diag([ones(3,1)*1e-3;ones(3,1)*1e-3;ones(3,1)*1e-3]);  % Measurement Noise: [position;roll_pitch_yaw;velocities];

%% Specify Initial values
time_thresh = 0.01; % Max Time diff to align Cam to IMU timestamps
                    % Any measurement that arrives greater than this time difference will be discarded
                    
mu_t_1 = zeros(15,1); % Initializing with zero state
sigma_t_1 = diag([zeros(3,1); N_g; N_a; N_bias_g; N_bias_a]);
isam_idx = 1; % Used to track which measurements have been used
imu_idx = 1; % Used to keep track of last used IMU index

%% Create variable to track the history of states
state_history = DataIO(15,length(IMU.time));
time_stamp = DataIO(1,length(IMU.time));
state_history.store(mu_t_1);
time_stamp.store(IMU.time(1));


%% Loop through and filter out states
for i=2:length(IMU.time)
    meas_idx = fn_alignTimeStamps(IMU.time(i), iSAM2.time, time_thresh);
    
    % Nearest time not found or if state is nan or if measurement has already been used
    if isnan(meas_idx) || any(isnan(iSAM2.state(:,meas_idx))) || isam_idx == meas_idx
        continue;
    else
        delta_t = IMU.time(i) - IMU.time(imu_idx); % If you use IMU.time(i) - IMU.time(i-1), then the x,y,z positions are not representative of the true x,y,z
        isam_idx = meas_idx; % Store currently used isam index in memory
        imu_idx = i; % Store current imu index in memory
        
        % Inputs for Prediction Step 
        accelerations = imu2cam.rot*IMU.values(1:3,i) + imu2cam.trans; %  Transform the accelerometer measurements to camera coordinates
        angular_velocities = imu2cam.rot*IMU.values(4:6,i) + imu2cam.trans; %  Transform the gyroscope measurements to camera coordinates
        u_t = [accelerations; angular_velocities]; % Control Inputs.
        F_t = eye(length(mu_t_1)) + jacobians.A_t(mu_t_1, u_t, zeros(12,1)) * delta_t;
        V_t = jacobians.U_t(mu_t_1, u_t, zeros(12,1)) * delta_t;
        
        % Prediction Step
        mu_bar_t = mu_t_1 + model.process(mu_t_1, u_t, zeros(12,1)) * delta_t;
        sigma_bar_t = F_t * sigma_t_1 * F_t' + V_t * Q_t * V_t';
        
        % Inputs for Update Step
        z_t = iSAM2.state(:,meas_idx); % Measurement Vector
        C_t = jacobians.C_t(mu_bar_t, zeros(9,1));
        W_t = jacobians.W_t(mu_bar_t, zeros(9,1));        
        
        % Estimate Kalman Gain
        K_t = sigma_bar_t * C_t' / (C_t * sigma_bar_t * C_t' + W_t * R_t * W_t');
        
        % Update Step
        mu_t = mu_bar_t + K_t * (z_t - model.measurement(mu_bar_t, zeros(9,1)));
        sigma_t = sigma_bar_t - K_t*C_t*sigma_bar_t;
        
        % Update variables for next iteration
        mu_t_1 = mu_t;
        sigma_t_1 = sigma_t;
        state_history.store(mu_t_1);
        time_stamp.store(IMU.time(i));
    end    
end

%% Collect EKF outputs in variable
ekf.state = state_history.retrieve;
ekf.time = time_stamp.retrieve;

%% Plot Outputs
fn_plotState(ekf, GTSAM);
