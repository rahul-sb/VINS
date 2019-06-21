function fn_plotState(ekf, GTSAM)
pos = {"X","Y","Z"};
rpy = {"Roll", "Pitch", "Yaw"};
vel = {"Vx", "Vy", "Vz"};

GTSAM = fn_filterOutNan(GTSAM);

figure;
for i=1:3
    fn_subplot(ekf, GTSAM, i, i, pos{i});
end

figure;
for i=1:3
    fn_subplot(ekf, GTSAM, i, i+3, rpy{i});
end

figure;
for i=1:3
    fn_subplot(ekf, GTSAM, i, i+6, vel{i});
end

end

function GTSAM = fn_filterOutNan(GTSAM)
    idx = any(isnan(GTSAM.state));
    GTSAM.state = GTSAM.state(:,~idx);
    GTSAM.time = GTSAM.time(:,~idx);
end

function fn_subplot(ekf, GTSAM, i, j, y_label)
subplot(3,1,i);
hold on;
scatter(ekf.time, ekf.state(j,:), 'b.');
scatter(GTSAM.time, GTSAM.state(j,:), 'g.');
ylabel(y_label);
xlabel("Time (sec)");
legend('EKF','GTSAM');
hold off;
end