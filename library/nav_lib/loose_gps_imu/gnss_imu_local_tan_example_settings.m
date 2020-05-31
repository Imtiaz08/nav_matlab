%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function that outputs a struct "settings" with the settings used in the
% GNSS-aided INS
%
% Edit: Isaac Skog (skog@kth.se), 2016-09-01
% Revised: Bo Bernhardsson 2018-01-01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function settings = gnss_imu_local_tan_example_settings()



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%              GENERAL PARAMETERS         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settings.gnss_outage = 'on';
settings.outagestart = 120;
settings.outagestop = 150;
settings.non_holonomic = 'off';
settings.speed_aiding = 'off';

settings.init_heading = 0*pi/180;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%             FILTER PARAMETERS           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Process noise covariance (Q)
% Standard deviations, need to be squared
settings.sigma_acc = 0.1; 
settings.sigma_gyro = deg2rad(0.5); 
settings.sigma_acc_bias = 0.01; 
settings.sigma_gyro_bias = deg2rad(0.1); 


% GNSS position measurement noise covariance (R)
% Standard deviations, need to be squared
settings.sigma_gps =2/sqrt(3); %[m]
settings.sigma_speed = 1; %[m/s]  Trim here
%settings.sigma_speed = 24; %[m/s]  Trim here
settings.sigma_non_holonomic = 20; %[m/s] Trim here
%settings.sigma_non_holonomic = 3; %[m/s] Trim here


% Initial Kalman filter uncertainties (standard deviations)
settings.factp(1) = 100;                                 % Position [m]
settings.factp(2) = 100;                                  % Velocity [m/s]
settings.factp(3:5) = (pi/180*[50 50 50]');     % Attitude (roll,pitch,yaw) [rad]
settings.factp(6) = 0.02;                               % Accelerometer biases [m/s^2]
settings.factp(7) = deg2rad(0.5);                     % Gyro biases [rad/s]

settings.gravity  = [0, 0, -9.8184]';

end




