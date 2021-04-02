close all;
clear;
clc;

%% Import and plot sensor data
load('imu_dataset.mat');

%%  plot sensor data  gyr��λΪdps
imu = dataset.imu;
dt = mean(diff(imu.time));
N = length(imu.time);

quat(:,1) = [1 0 0 0]';
err_state = zeros(6, 1); %ʧ׼��(3) , ������ƫ(3)

[P, Q] = init_filter(dt);

for i = 1:N
    
    %ǿ�Ƽ�һ��bias����
    imu.gyr(3,i) =  imu.gyr(3,i) + deg2rad(10);
    
    % ��������ƫ����
     imu.gyr(:,i)  = imu.gyr(:,i) -  err_state(4:6);
    
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
    gyr = imu.gyr(:,i);
    acc =  imu.acc(:,i);
    
    quat = ch_att_upt(quat, gyr, dt);
    
    %����F��
    [F, G] = state_space_model(quat, dt);
    
    %״̬����
   % err_state = F*err_state;
    
    P = F*P*F' + G*Q*G';
    
    outdata.phi(:,i) = err_state(1:3);
    
    % �����������
    [P, quat, err_state]=  measurement_update_gravity(quat, err_state,  acc, P);
    
    %���������
    %  [P, q, err_state]=  measurement_update_mag(q, err_state,  imu.mag(:,i), P);
    
    %P��ǿ������
    P = (P + P')/2;
    
    %��¼���ƴ������ƫ
    outdata.eul(:,i) = ch_q2eul(quat);
    outdata.wb(:,i) = err_state(4:6);
    outdata.P(:,:,i) = P;
end

outdata.eul = rad2deg(outdata.eul);
fprintf("������̬��:%f, %f %f\n", outdata.eul(:,end));


ch_plot_imu('acc', imu.acc', 'gyr', imu.gyr', 'mag', imu.mag',  'eul', outdata.eul', 'time',  imu.time');
ch_plot_imu('wb',rad2deg(outdata.wb'), 'phi', rad2deg(outdata.phi'), 'time',  imu.time');


P_wb = zeros(3, N);
P_phi = zeros(3, N);

for i = 1: length(outdata.P)
    P = outdata.P(:,:,i);
    P_phi(1, i) = P(1,1);
    P_phi(2, i) = P(2,2);
    P_phi(3, i) = P(3,3);
    P_wb(1, i) = P(4,4);
    P_wb(2, i) = P(5,5);
    P_wb(3, i) = P(6,6);
end

ch_plot_imu('P_phi', P_phi', 'P_wb', P_wb', 'time',  imu.time');


% F��G
function [F,G] = state_space_model(x, dt)

Cb2n = ch_q2m(x(1:4));

O = zeros(3);

F = [ O -Cb2n; O O];
%��ɢ��
F = eye(6) + F*dt;
G = eye(6);
end


function [P, Q] = init_filter(dt)

Q_att = 1;   %
Q_wb = 0.0;

P = eye(6)*1;

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
err_state = err_state +  K*(z(1:2) - H*err_state);

%����P ʹ��Joseph ��ʽ��ȡ�� (I-KH)*P, ��ô��ֵ������ȶ�
I_KH = (eye(size(P,1))-K*H);
P= I_KH*P*I_KH' + K*R*K';


%���״̬�������������
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
err_state = err_state +  K*(h - H*err_state);

% 
% %����P ʹ��Joseph ��ʽ��ȡ�� (I-KH)*P, ��ô��ֵ������ȶ�
% I_KH = (eye(size(P,1)) - K*H);
% P= I_KH*P*I_KH' + K*R*K';

P = (eye(6) - K*H)*P;

%���״̬�������������

%���ڵشţ�ֻ���������9
% err_state(1) = 0;
% err_state(2) = 0;

%��������0
q(1:4) = ch_qmul(ch_rv2q(err_state(1:3)), q);
err_state(1:3) = 0;

end


