clear;
clc;
close all;
%%


%load('LoggedSingleAxisGyroscope', 'omega', 'Fs')

load('adis16488_gyr.mat');
omega = omega(:,1);
omega = deg2rad(omega);

[avar1, tau1 , N, K, B] = ch_allan(omega, Fs, true);

fprintf('��ƫ���ȶ���                                    %frad/s                    ��   %fdeg/h \n', B, rad2deg(B)*3600);
fprintf('�Ƕ��������(ARW, Noise density)    %f(rad/s)/sqrt(Hz)    ��  %f deg/sqrt(h)\n', N, rad2deg(N)*3600^(0.5));
fprintf('����������                                       %f(rad/s)sqrt(Hz)      ��  %f deg/h/sqrt(h)\n', K, rad2deg(K) * (3600^(1.5)));



%% �÷������ݲ�

% L = 2160000;
% 
% gyro = gyroparams('NoiseDensity', N, 'RandomWalk', K,'BiasInstability', B);
% 
% 
% acc = zeros(L, 3);
% angvel = zeros(L, 3);
% imu = imuSensor('SampleRate', Fs, 'Gyroscope', gyro);
% [~, omega] = imu(acc, angvel);
% omega = omega(:,1);
% 
% 
% [avar2, tau2,  N, K, B] = ch_allan(omega, Fs, true);
% 
% fprintf('��ƫ���ȶ���                                    %frad/s                    ��   %fdeg/h \n', B, rad2deg(B)*3600);
% fprintf('�Ƕ��������(ARW, Noise density)    %f(rad/s)/sqrt(Hz)    ��  %f deg/sqrt(h)\n', N, rad2deg(N)*3600^(0.5));
% fprintf('����������                                       %f(rad/s)sqrt(Hz)      ��  %f deg/h/sqrt(h)\n', K, rad2deg(K) * (3600^(1.5)));

