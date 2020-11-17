clear;
clc;
close all;


%% option1: read matlabe internal dataset 
load('LoggedSingleAxisGyroscope', 'omega', 'Fs')

%% option2: 488 dataset

% load('adis16488_gyr.mat');
% omega = omega(:,1);
% omega = deg2rad(omega);

%% option3: ch00
% load('ch100_gyr.mat');
% omega = omega(:,3);
% omega = deg2rad(omega);


%% option4: generate data from simulation
% B = 0.00203140909966965;
% N = 0.0125631765533906;
% K = 9.38284069320333e-05;
% L =2160000;
% Fs = 100;
% 
% 
% gyro = gyroparams('NoiseDensity', N, 'RandomWalk', K,'BiasInstability', B);
% acc = zeros(L, 3);
% angvel = zeros(L, 3);
% imu = imuSensor('SampleRate', Fs, 'Gyroscope', gyro);
% [~, omega] = imu(acc, angvel);
% omega = omega(:,1);
 
 

[avar1, tau1 , N, K, B] = ch_allan(omega, Fs, true);

fprintf('��ƫ���ȶ���                                    %frad/s                    ��   %fdeg/h \n', B, rad2deg(B)*3600);
fprintf('�Ƕ��������(ARW, Noise density)    %f(rad/s)/sqrt(Hz)    ��  %f deg/sqrt(h)\n', N, rad2deg(N)*3600^(0.5));
fprintf('����������                                       %f(rad/s)sqrt(Hz)      ��  %f deg/h/sqrt(h)\n', K, rad2deg(K) * (3600^(1.5)));


