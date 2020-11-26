clear;
clc;
close all;

%% : read matlabe internal dataset 
load('LoggedSingleAxisGyroscope', 'omega', 'Fs')
gyroReading = omega;

%% ADIS16488 dataset
% load('adis16488_gyr.mat');
% gyroReading = omega(:,1);
% gyroReading = deg2rad(gyroReading);

%%  ch00   deg/s    m/s^(2)

% load('ch100.mat');
% gyroReading = gyroReading(:,2);
% gyroReading = deg2rad(gyroReading);
% accelReading = accelReading(:,2);
% accelReading = accelReading *  9.8066;
% Fs = 400;


%% 
% data = ch_data_import('UranusData.csv');


%% https://github.com/Aceinna/gnss-ins-sim
% VRW ��λ:                    m/s/sqrt(hr)           'accel_vrw': np.array([0.3119, 0.6009, 0.9779]) * 1.0,
% ���ٶ���ƫ���ȶ���:     m/s^(2)                 'accel_b_stability': np.array([1e-3, 3e-3, 5e-3]) * 1.0,
% ARW ��λ:                    deg/sqrt(hr)           'gyro_arw': np.array([0.25, 0.25, 0.25]) * 1.0,
% ���ٶ���ƫ�ȶ���:        deg/h                     'gyro_b_stability': np.array([3.5, 3.5, 3.5]) * 1.0,  

% M = csvread('gyro-0.csv',1 ,0);
% gyroReading = M(:,1);
% gyroReading = deg2rad(gyroReading); 
% 
% M = csvread('accel-0.csv',1 ,0);
% Fs = 100;
% accelReading = M(:,1);


%% ���ݷ��� , ���������λΪ rad/s
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
% [~, omega ] = imu(acc, angvel);
% omega  = omega (:,1);
 

 %% �ӼƷ���, ���������λΪ m/s^(2)
% B = 0.00203140909966965;
% N = 0.0125631765533906;
% K = 9.38284069320333e-05;
% L =2160000;
% Fs = 100;
% 
% 
% SpecAcc = accelparams('NoiseDensity', N, 'RandomWalk', K,'BiasInstability', B);
% acc = zeros(L, 3);
% angvel = zeros(L, 3);
% imu = imuSensor('SampleRate', Fs, 'Accelerometer', SpecAcc);
% [accelReading, ~] = imu(acc, angvel);
% accelReading = accelReading(:,1);


            
%% �������� allan
[avar1, tau1 , N, K, B] = ch_allan(gyroReading , Fs, true);
fprintf('GYR: ��ƫ���ȶ���                                                             %frad/s                    ��   %fdeg/h \n', B, rad2deg(B)*3600);
fprintf('GYR: �����ܶ�(�Ƕ��������, ARW, Noise density)              %f(rad/s)/sqrt(Hz)     ��  %f deg/sqrt(h)\n', N, rad2deg(N)*3600^(0.5));
fprintf('GYR: �������������, bias variations ("random walks")       %f(rad/s)sqrt(Hz)       ��  %f deg/h/sqrt(h)\n', K, rad2deg(K) * (3600^(1.5)));



% %% ���м��ٶȼ� allan
% [avar1, tau1 , N, K, B] = ch_allan(accelReading, Fs, true);
% 
% fprintf('ACC: ��ƫ���ȶ���                                                                                       %fm/s^(2)                       ��   %fmg  ��  %fug\n', B, B / 9.80665 *1000,  B / 9.80665 *1000*1000);
% fprintf('ACC: �����ܶ�(�����������,VRW, Noise Density, Rate Noise Density)          %f(m/s^(2))/sqrt(Hz)        ��   %f m/s/sqrt(hr)\n', N, N * 3600^(0.5));
% fprintf('ACC: ���ٶ�������ߣ�bias variations ("random walks")                               %f(m/s^(2)sqrt(Hz))\n',  K);



