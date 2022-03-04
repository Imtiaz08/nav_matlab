clear;
clc;
close all;
%% ������ƽ������ϵ GPS IMU ��ϵ���������15άESKF
% �ܹ�����: https://kth.instructure.com/courses/4962/files/805888/download?verifier=0pYkYUwoZPMGlukMWCScvyVnXQY5br6Bxmqhpvvk&wrap=1
%% Load data ���data
load('gps_ins_dataset1.mat');

%%  load couersera data
%load('gps_ins_dataset2.mat');

% pvt:                        ����״̬: ��������״̬: λ��(3) �ٶ�(3) ��Ԫ��(4) ��10ά
% X:                           KF���״̬: λ�����(3) �ٶ����(3) ʧ׼��(3) ���ٶȼ���ƫ(3) ������ƫ(3) ��15ά
% bias:                       ��ƫ����: ���ٶȼ���ƫ(3) ������ƫ(3)�� ��6ά

%% extract data
u = [dataset.imu.acc; dataset.imu.gyr];
gnss = dataset.gnss.pos_ned;
gnss_time = dataset.gnss.time;
imu_t = dataset.imu.time;

%% load settings
settings = gnss_imu_eskf15_settings();

%% ������
disp('Runs the GNSS-aided INS');

proc_div = 0; %���̵��Ʒ�Ƶ��
pvt = init_navigation_state(u, settings);

% ��ʼ��ƫ
bias = zeros(6, 1);

% ��ʼ���˲���
[P, Q, ~, ~] = init_filter(settings);

n = size(u,2);

ctr_gnss_data = 1;

for k=2:n
    dt = imu_t(k)-imu_t(k-1);
    
    % ������ƫ����Ϊ������Y���ϼ�һ�����bias
    u(5,k) = u(5,k) + deg2rad(5);
    
    % ��ƫ״̬����
    u_h = u(:,k) - bias;
    
    % �����ߵ�����
    [pvt(1:3), pvt(4:6), pvt(7:10)] = ch_nav_equ_local_tan(pvt(1:3), pvt(4:6), pvt(7:10), u_h(1:3), u_h(4:6), dt, settings.gravity);
    
    proc_div = proc_div+1;
    if proc_div == 10
        
        % ����F���G��
        [F, G] = state_space_model(pvt, u_h, dt*proc_div);
        
        % �������� �������
        P = F*P*F' + G*Q*G';
        
        proc_div = 0;
    end
    
    % �������
    if abs(imu_t(k) - gnss_time(ctr_gnss_data)) < 0.01
        if imu_t(k)<settings.outagestart || imu_t(k) > settings.outagestop || ~strcmp(settings.gnss_outage, 'on')
            
            y = gnss(:, ctr_gnss_data);
            H = [eye(3) zeros(3,12)];
            R = [settings.sigma_gps^2*eye(3)];
            
            % Calculate the Kalman filter gain.
            K=(P*H')/(H*P*H'+R);
            X = [zeros(9,1); bias] + K*(y - pvt(1:3));
            
            %% ����
            pvt(1:6) = pvt(1:6) + X(1:6); % λ���ٶȷ���
            q = pvt(7:10); % ʧ׼�Ƿ���
            q = ch_qmul(ch_rv2q(X(7:9)), q);
            pvt(7:10) = q;
            
            bias = X(10:15);
            
            %����P ʹ��Joseph ��ʽ��ȡ�� (I-KH)*P, ��ô��ֵ������ȶ�
            I_KH = (eye(size(P,1))-K*H);
            P= I_KH*P*I_KH' + K*R*K';
            
        end
        ctr_gnss_data = min(ctr_gnss_data+1, length(gnss_time));
    end
    
    % Save the data to the output data structure
    log.x(:,k) = pvt;
    log.eul(:,k) = ch_q2eul(pvt(7:10));
    
    log.diag_P(:,k) = diag(P);
    log.delta_u_h(:,k) = bias;
end


%% ��ͼ
log.eul = rad2deg(log.eul);
imu = dataset.imu;
imu.gyr = rad2deg(imu.gyr);

% ԭʼ����
ch_plot_imu('acc', imu.acc', 'gyr', imu.gyr',  'eul', log.eul', 'time',  imu.time');

% ��ƫ����plot
ch_plot_imu('wb', rad2deg(log.delta_u_h(4:6,:))', 'gb', log.delta_u_h(1:3,:)', 'time',  imu.time');

% P�󷽲�
ch_plot_imu('P_phi', log.diag_P(7:9,:)', 'P_wb', log.diag_P(10:12,:)', 'P_pos', log.diag_P(1:3,:)', 'time',  imu.time');

% 2D�켣
ch_plot_gps_imu_pos('pos',log.x(1:3,:)', 'gnss', dataset.gnss.pos_ned',  'time',  imu.time');

% % % 3D�켣
% ch_plot_pos3d('p1', log.x(1:3,:)', 'p2', dataset.gnss.pos_ned', 'legend', ["�ں�", "GNSS"] )

figure;
xest = log.x(2,:);
yest = log.x(1,:);
xgps = interp1(dataset.gnss.time, dataset.gnss.pos_ned(2,:), dataset.imu.time,'linear','extrap')';
ygps = interp1(dataset.gnss.time, dataset.gnss.pos_ned(1,:), dataset.imu.time,'linear','extrap')';
xerr = xest - xgps; 
yerr = yest - ygps;
plot(dataset.imu.time, xerr)
grid on
hold on
plot(dataset.imu.time, yerr)
xlabel('time [s]')
ylabel('position difference [m]')
title('�ںϺ���GNSSλ�����');
legend('x', 'y')

positionerr_RMS = sqrt(mean(xerr.^2+yerr.^2));

fprintf("�ںϺ�켣��GPS���:%.3f\n", positionerr_RMS);

%%  ��ʼ������״̬
function x = init_navigation_state(~, settings)

roll = 0;
pitch = 0;

% Initial coordinate rotation matrix
q = ch_eul2q([roll pitch settings.init_heading]);
x = [zeros(6,1); q];

end

%%  ��ʼ���˲���
function [P, Q, R, H] = init_filter(settings)


% Kalman filter state matrix
P = zeros(15);
P(1:3,1:3) = settings.factp(1)^2*eye(3);
P(4:6,4:6) = settings.factp(2)^2*eye(3);
P(7:9,7:9) = diag(settings.factp(3:5)).^2;
P(10:12,10:12) = settings.factp(6)^2*eye(3);
P(13:15,13:15) = settings.factp(7)^2*eye(3);

% Process noise covariance
Q = zeros(12);
Q(1:3,1:3) = diag(settings.sigma_acc).^2*eye(3);
Q(4:6,4:6) = diag(settings.sigma_gyro).^2*eye(3);
Q(7:9,7:9) = settings.sigma_acc_bias^2*eye(3);
Q(10:12,10:12) = settings.sigma_gyro_bias^2*eye(3);

% GNSS-receiver position measurement noise
R = settings.sigma_gps^2*eye(3);

% Observation matrix
H = [eye(3) zeros(3,12)];

end


%%  ����״̬ת�ƾ���
function [F, G] = state_space_model(x, acc, dt)
Cb2n = ch_q2m(x(7:10));

% Transform measured force to force in the tangent plane coordinate system.
sf = Cb2n * acc(1:3);
sk = ch_askew(sf);

% Only the standard errors included
O = zeros(3);
I = eye(3);
F = [  O I   O O        O;
    O O -sk -Cb2n O;
    O O O O       -Cb2n;
    O O O O       O;
    O O O O       O];

% ��ɢ��
F = eye(15) + dt*F;

% ��������
G= [O       O         O  O;
     Cb2n  O         O  O;
     O        -Cb2n O  O;
     O        O         I   O;
     O        O        O   I];
 G = G * dt;
end



