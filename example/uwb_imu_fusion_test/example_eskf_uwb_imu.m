clc
clear
close all


%% ˵��
% UWB IMU �ں��㷨������������15ά����ģ�ͣ�α�����
% PR(TOF) α�ࣺ        UWBӲ��������ԭʼ��������ֵ
% IMU:                       ���ٶ�(3) 3������(3) ��6ά
% noimal_state:           ��������״̬: λ��(3) �ٶ�(3) ��Ԫ��(4) ��10ά
% err_state:                 KF���״̬: λ�����(3) �ٶ����(3) ʧ׼��(3) ���ٶȼ���ƫ(3) ������ƫ(3) ��15ά
% du:                          ��ƫ����: ���ٶȼ���ƫ(3) ������ƫ(3)

%% ��ȡ���ݼ�
load datas2;
dataset = datas;


N = length(dataset.imu.time);
dt = mean(diff(dataset.imu.time));

% ����ɾ��һЩ��վ�����ݣ������㷨�ڻ�վ�������ٵ�ʱ���ܷ���ʲô�漣���� 
% dataset.uwb.anchor(:,1) = [];
% dataset.uwb.tof(1,:) = [];


% EKF�ں�ʹ�õĻ�վ�������ں��㷨����2����վ�Ϳ���2D��λ
%dataset.uwb.cnt = size(dataset.uwb.anchor, 2);


m_div_cntr = 0;                         % �����Ƶ��
m_div = 50;                                 % ÿm_div�����⣬�Ÿ���һ��EKF����(UWB����),  ���Խ�Լ������ ���� ��ʵ�鿴Ч��
UWB_LS_MODE = 2;                 % 2 ��UWB�������2Dģʽ�� 3����UWB�������3Dģʽ
UWB_EKF_UPDATE_MODE = 2; % EKF �ںϲ���2Dģʽ��   3: EKF�ںϲ���3Dģʽ

%% ���ݳ�ʼ��
out_data.uwb = [];
out_data.uwb.time = dataset.uwb.time;
out_data.imu.time = dataset.imu.time;
out_data.uwb.anchor = dataset.uwb.anchor;
pr = 0;
last_pr = 0;

%% �˲�������ʼ��
settings = uwb_imu_example_settings();
R = diag(ones(dataset.uwb.cnt, 1)*settings.sigma_uwb^(2));
noimal_state = init_navigation_state(settings);
err_state = zeros(15, 1);

%ʹ�õ�һ֡α����Ϊ��ʼ״̬
pr = dataset.uwb.tof(:, 1);
noimal_state(1:3) = ch_multilateration(dataset.uwb.anchor, [ 0 0 0]',  pr', 3);

du = zeros(6, 1);
[P, Q1, Q2, ~, ~] = init_filter(settings);

fprintf("��%d֡����, IMU����Ƶ��:%d Hz ������ʱ�� %d s\n", N,  1 / dt, N * dt);
fprintf("UWB��վ����:%d\n", dataset.uwb.cnt);
fprintf("UWB�������Ƶ��Ϊ:%d Hz\n", (1 / dt) / m_div);
fprintf("UWB EKF�������ģʽ: %dDģʽ\n", UWB_EKF_UPDATE_MODE);
fprintf("��UWB��С���˽���: %dDģʽ\n", UWB_LS_MODE);
fprintf("EKF �˲�����:\n");
settings
fprintf("��ʼ�˲�...\n");


for k=1:N
    
    acc = dataset.imu.acc(:,k);
    gyr = dataset.imu.gyr(:,k);
    
    % ����
    acc = acc + du(1:3);
    gyr = gyr + du(4:6);
    
    % �����ߵ�
    p = noimal_state(1:3);
    v = noimal_state(4:6);
    q =  noimal_state(7:10);
    
    [p, v, q] = ch_nav_equ_local_tan(p, v, q, acc, gyr, dt, [0, 0, -9.8]'); % ����������ϵ������Ϊ-9.8
    
    %   С�����裺������ƽ���˶���Nϵ��Z���ٶȻ���Ϊ0��ֱ�Ӹ�0
     v(3) = 0;
    
    noimal_state(1:3) = p;
    noimal_state(4:6) = v;
    noimal_state(7:10) = q;
    out_data.eul(k,:) = ch_q2eul(q);
    
    % ����F��   G��
    [F, G] = state_space_model(noimal_state, acc, dt);
    
    %������P��Ԥ�⹫ʽ
    P = F*P*F' + G*blkdiag(Q1, Q2)*G';
    
    %��¼����
    out_data.x(k,:)  = noimal_state;
    out_data.delta_u(k,:) = du';
    out_data.diag_P(k,:) = trace(P);
    
    
    %% EKF UWB�������
    m_div_cntr = m_div_cntr+1;
    if m_div_cntr == m_div
        m_div_cntr = 0;
        
        pr = dataset.uwb.tof(1:dataset.uwb.cnt, k);
        
        %�ж�����PR ������̫������Ϊ�����վPR�Ƚ��ã���Ҫ�ˡ��൱��GNSS�������
        %                         arr = find(abs(pr - last_pr) < 0.05);
        %                         last_pr = pr;
        %                         out_data.good_anchor_cnt(k,:) = length(arr); %��¼�������Ļ�վ��
        %
        %                         if(isempty(arr))
        %                             continue;
        %                         end
        %
        %                         %���� �޳����õĻ�վ֮��Ļ�վλ�þ����R����
        %                         pr = pr(arr);
        %                         anch = dataset.uwb.anchor(:, arr);
        %                         R1 = R(arr, arr);
        
        % ���˲�����վ�ˣ����л�վֱ�Ӳ��붨λ����ʵҲ�̫��
        anch = dataset.uwb.anchor;
        R1 = R;
        
        %���ⷽ��
        [Y, H]  = uwb_hx(noimal_state, anch, UWB_EKF_UPDATE_MODE);
        
        % ��������ʽ������K
        S = H*P*H'+R1; % system uncertainty
        residual = pr - Y; %residual ���߽���Ϣ
        
        %% �����������Ŷȸ�RһЩ����   Self-Calibrating Multi-Sensor Fusion with Probabilistic
        %Measurement Validation for Seamless Sensor Switching on a UAV, ��������ɿ���
        %
        L = (residual'*S^(-1)*residual);
        out_data.L(k,:) = L;
        
        %         if(L > 20 ) %����������ŶȱȽϴ��������������
        %             S = H*P*H'+R1*5;
        %         end
        
        K = (P*H')/(S);
        err_state = [zeros(9,1); du] + K*(residual);
        
        % �����ٶ�λ��
        noimal_state(1:6) = noimal_state(1:6) + err_state(1:6);
        
        % ������̬
        q = noimal_state(7:10);
        q = ch_qmul(ch_qconj(q), ch_rv2q(err_state(7:9)));
        q = ch_qconj(q);
        noimal_state(7:10) = q;
        
        %�洢���ٶȼ���ƫ��������ƫ
        du = err_state(10:15);
        
        % P��������
        P = (eye(15)-K*H)*P;
    end
    
    
        %% ����Լ����Z���ٶ�Լ���� Bϵ�� Z���ٶȱ���Ϊ0(�������).. ������Ч��ֹZ��λ������ �ο�https://kth.instructure.com/files/677996/download?download_frd=1 �� https://academic.csuohio.edu/simond/pubs/IETKalman.pdf
        R2 = eye(1)*0.5;
        Cn2b = ch_q2m(ch_qconj(noimal_state(7:10)));
    
        H = [zeros(1,3), [0 0 1]* Cn2b, zeros(1,9)];
    
        K = (P*H')/(H*P*H'+R2);
        z = Cn2b*noimal_state(4:6);
    
        err_state = [zeros(9,1); du] + K*(0-z(3:3));
    
        % �����ٶ�λ��
        noimal_state(1:6) = noimal_state(1:6) + err_state(1:6);
    
        % ������̬
        q = noimal_state(7:10);
        q = ch_qmul(ch_qconj(q), ch_rv2q(err_state(7:9)));
        q = ch_qconj(q);
        noimal_state(7:10) = q;
    
        %�洢���ٶȼ���ƫ��������ƫ
        % du = err_state(10:15);
    
        % P��������
        P = (eye(15)-K*H)*P;
    
    
end

fprintf("��ʼ��UWB��С����λ�ý���...\n");
%% �� UWB λ�ý���
j = 1;
uwb_pos = [0 0 0]';
N = length(dataset.uwb.time);

for i=1:N
    pr = dataset.uwb.tof(:, i);
    % ȥ��NaN��
    %if all(~isnan(pr)) == true
        
        uwb_pos = ch_multilateration(dataset.uwb.anchor, uwb_pos,  pr', UWB_LS_MODE);
        out_data.uwb.pos(:,j) = uwb_pos;
        j = j+1;
    %end
end
fprintf("�������...\n");

%% plot ����
out_data.uwb.tof = dataset.uwb.tof;
out_data.uwb.fusion_pos = out_data.x(:,1:3)';
demo_plot(dataset, out_data);



%%  Init navigation state
function x = init_navigation_state(~)

% ��ʼ��normial state
q = ch_eul2q(deg2rad([0 0 0]));
x = [zeros(6,1); q];
end


%% ��ʼ���˲�������
function [P, Q1, Q2, R, H] = init_filter(settings)

% Kalman filter state matrix
P = zeros(15);
P(1:3,1:3) = settings.factp(1)^2*eye(3);
P(4:6,4:6) = settings.factp(2)^2*eye(3);
P(7:9,7:9) = diag(settings.factp(3:5)).^2;
P(10:12,10:12) = settings.factp(6)^2*eye(3);
P(13:15,13:15) = settings.factp(7)^2*eye(3);

% Process noise covariance
Q1 = zeros(6);
Q1(1:3,1:3) = diag(settings.sigma_acc).^2*eye(3);
Q1(4:6,4:6) = diag(settings.sigma_gyro).^2*eye(3);

Q2 = zeros(6);
Q2(1:3,1:3) = settings.sigma_acc_bias^2*eye(3);
Q2(4:6,4:6) = settings.sigma_gyro_bias^2*eye(3);

R =0;
H = 0;

end

%%  ����F��G��
function [F,G] = state_space_model(x, acc, dt)
Cb2n = ch_q2m(x(7:10));

% Transform measured force to force in the tangent plane coordinate system.
sf = Cb2n * acc;
sk = ch_askew(sf);

% Only the standard errors included
O = zeros(3);
I = eye(3);
F = [
    O I   O O       O;
    O O sk Cb2n O;
    O O O O       -Cb2n;
    O O O O       O;
    O O O O       O];

% Approximation of the discret  time state transition matrix
F = eye(15) + dt*F;

% Noise gain matrix
G=dt*[
    O       O         O  O;
    Cb2n  O         O  O;
    O        -Cb2n O  O;
    O        O         I   O;
    O        O        O   I];
end

%% UWB�������
% Y ���ݵ�ǰ״̬��UWB��վ����Ԥ�������α��
% H �������
% anchor: ��վ����  M x N: M:3(��ά����)��  N:��վ����
% dim:  2: ��ά  3����ά
function [Y, H] = uwb_hx(x, anchor, dim)
N = size(anchor,2); %��վ����

pos = x(1:3);
if(dim)== 2
    pos = pos(1:2);
    anchor = anchor(1:2, 1:N);
    %  uwb.anchor
end

Y = [];
H = [];
residual = repmat(pos,1,N) - anchor(:,1:N);
for i=1:N
    
    if(dim)== 2
        H = [H ;residual(:,i)'/norm(residual(:,i)),zeros(1,13)];
    else
        H = [H ;residual(:,i)'/norm(residual(:,i)),zeros(1,12)];
    end
    Y = [Y ;norm(residual(:,i))];
end



end
