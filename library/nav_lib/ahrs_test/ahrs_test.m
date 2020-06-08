%% Start of script
close all;
clear;
clc;

%% Import and plot sensor data
load('imu_dataset.mat');

%%  plot sensor data 
imu = dataset.imu;
dt = mean(diff(imu.time));
n = length(imu.time);

q(:,1) = [1 0 0 0]';
err_state = zeros(6, 1);%ʧ׼�ǣ� �������
wb = [0 0 0]'; %������ƫ
[P, Q] = init_filter(dt);


for i = 1:n
    
    
    %ǿ�Ƽ�һ��bias : 11 dps
%     imu.gyr(2,i) =  imu.gyr(2,i) + deg2rad(20);
    imu.gyr(1,i) =  imu.gyr(1,i) - deg2rad(10);
 
     % ��������ƫ����
    imu.gyr(:,i)  = imu.gyr(:,i) - 0;
%     
%     imu.gyr(1,i) = deg2rad(1);
%     imu.gyr(2,i) = deg2rad(2);
%     imu.gyr(3,i) = deg2rad(3);
%     
%     imu.acc(1,i) = 0.01;
%     imu.acc(2,i) = 0.12;
%     imu.acc(3,i) = 0.98;
%     
%     imu.mag(1,i) = 0.01;
%     imu.mag(2,i) = 0.12;
%     imu.mag(3,i) = 0.98;
    
%	q = ch_mahony.imu(q, imu.gyr(:,i), imu.acc(:,i), dt, 1);
%    q = ch_mahony.ahrs(q, imu.gyr(:,i), imu.acc(:,i), imu.mag(:,i), dt, 1);
    

    
  % ��������
    q = ch_qintg(q, imu.gyr(:,i), dt);
    
    %����F��
	[F, G] = state_space_model(q, dt);
     
    %״̬����
    err_state = F*err_state;
    
    %����
    P = F*P*F' + G*Q*G';
    

     % �����������
    [P, q, err_state]=  measurement_update_gravity(q, err_state,  imu.acc(:,i), P);

    %���������
    [P, q, err_state]=  measurement_update_mag(q, err_state,  imu.mag(:,i), P);

    %P��ǿ������
    P = (P + P')/2;
    
    %��¼���ƴ������ƫ
    wb = err_state(4:6);

    outdata.eul(:,i) = ch_q2eul(q);
    outdata.wb(:,i) = wb;
end

ch_imu_data_plot('acc', imu.acc', 'gyr', imu.gyr', 'mag', imu.mag', 'time', imu.time');

figure('Name', 'Euler Angles');
hold on;
plot(imu.time, outdata.eul(1,:), 'r');
plot(imu.time, outdata.eul(2,:), 'g');
plot(imu.time, outdata.eul(3,:), 'b');
title('Euler angles');
xlabel('Time (s)');
ylabel('Angle (deg)');
legend('\phi', '\theta', '\psi');
hold off;

rad2deg( outdata.eul(:,end))

figure;
plot(rad2deg(outdata.wb'));
title('��ƫ');

% F��G
function [F,G] = state_space_model(x, dt)

Cb2n = ch_q2m(x(1:4));

I = eye(3);
O = zeros(3);

F = [ O -Cb2n; O O];
%��ɢ��
F = eye(6) + F*dt;

G = eye(6);
end


function [P, Q] = init_filter(dt)

Q_att = 2;
Q_wb = 1;

P = eye(6)*2;

Q = zeros(6);
Q(1:3,1:3) = Q_att*eye(3);
Q(4:6,4:6) = Q_wb*eye(3);
Q = Q*dt^(2);
end


function [P, q, err_state]= measurement_update_gravity(q, err_state, acc, P)
  
   %��������
    R_sigma = 4;
    R = zeros(2,2);
    R(1:2,1:2) = R_sigma*eye(2);
    
	% ���ٶȼƵ�λ��
	acc = acc / norm(acc);    % normalise magnitude
   
    % ����������� �Ϲ����� 7.5.14
    H = ch_askew([0 0 -1]');
    H = H(1:2,:);
    H = [H zeros(2,3)];

    %������Ϣ
    z = ch_qmulv(q, -acc) - [0 0 -1]';
    
    %��������
	K=(P*H')/(H*P*H'+R);
    
     %����״̬
	err_state = err_state +  K*(z(1:2));

    %����P
    P=(eye(6)-K*H)*P;
    
    %���״̬�������������
    %��������ʸ�����⣬ֻ�����������
  %  err_state(3) = 0;
    q = ch_qmul(ch_rv2q(err_state(1:3)), q);
    err_state(1:3) = 0;
end



function [P, q,  err_state]= measurement_update_mag(q, err_state, mag, P)
%�ش���������
R = eye(3)*2;

% �ų���λ��
mag = mag / norm(mag);   % normalise magnitude

%������Ϣ
h = ch_qmulv(q, mag);
b = [norm([h(1) h(2)]) 0 h(3)]';
h = h - b;

% ����������� �Ϲ����� 7.5.14
H = ch_askew(b);
H = [H zeros(3)];

%��������
K=(P*H')/(H*P*H'+R);

%����״̬
err_state = err_state +  K*(h);

%����P
P = (eye(6)-K*H)*P;

%���״̬�������������

%���ڵشţ�ֻ���������
% err_state(1) = 0;
% err_state(2) = 0;
q(1:4) = ch_qmul(ch_rv2q(err_state(1:3)), q);
err_state(1:3) = 0;

end


