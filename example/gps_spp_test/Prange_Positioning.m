clear;
clc;
close all;

% �ο�: https://www.telesens.co/2017/07/17/calculating-position-from-raw-gps-data/#Rotating_the_Satellite_Reference_Frame
% GPSԭ��Ӧ�� л��


%tob = [01, 9, 4, 0, 30, 0];                                     %�۲�ʱ�̵�UTCʱ����ȡ����λ

geodeticHstation=93.4e-3;%NaN                            %��վ��ظ�km�������֪����NaN
Alpha = [0.2235D-07  0.2235D-07 -0.1192D-06 -0.1192D-06];  %��������ͷ�ļ��еĵ����Alpha
Beta = [0.1290D+06  0.4915D+05 -0.1966D+06  0.3277D+06];   %��������ͷ�ļ��еĵ����Beta
filen='wuhn2470.01n';
fileo='wuhn2470.01o';

%  filen='rtcm_data.nav';
%  fileo='rtcm_data.obs';

chooseTropo = 2;                                           %���õĶ�����ģ��1:�򻯻��շƶ��£�Hopfield������ģ�� 2:��˹��Ī����Saastamoinen������ģ��

cv = 299792458;                                            %����m/s
a = 6378137;                                               %WGS84����볤��m
finv = 298.2572236;                                        %WGS84������ʵ���

%------------------------------------------------------------------------
%����Ϊ�������
%1����O�ļ�����ȡ�Ŀ��������ǵ�C1�۲�ֵ��
fprintf("��ȡ renix obs ����...\r\n");
%[obs, ~]  = read_rinex_obs(fileo);
load 'obs.mat';


% ��ȡN�ļ�,�����ҵ��͵�ǰʱ�������һ������
fprintf("��ȡ renix nav ����...\r\n");
all_eph = read_rinex_nav(filen);
fprintf("��ȡ���\r\n");


fprintf("��ʼ��λ...\r\n");

%3�������ʼ�����ò�վ����λ��ΪXr�����ջ��Ӳ��ֵΪdt��
X = [0 0 0 0]';

epochs = unique(obs.data(:, obs.col.TOW));
TimeSpan=epochs(1:200);

for ii = 1:length(TimeSpan);
    % ��ȡ��ǰTOWʱ�̵�����OBS
    this_TOW = TimeSpan(ii);
    index = find(obs.data(:,obs.col.TOW) == this_TOW);
    curr_obs.data = obs.data(index, :);
    curr_obs.col = obs.col;
    
    sv_num = size(curr_obs.data,1);

    if (sv_num < 4)
        continue;
    end
    
	sv_pos = [];
    l = [];
    
    while(1)
        j = 1;
        for i=1:sv_num
            % ѡ����ǰʱ�̵� ĳ�����ǵ����й۲�
            PRN_obs.data = curr_obs.data(i,:);
            PRN_obs.col = curr_obs.col;
            PRN = PRN_obs.data(obs.col.PRN);
            C1 = PRN_obs.data(obs.col.C1);
            
            % ����뵱ǰʱ����ӽ���eph
            one_sv_eph = all_eph([all_eph(:,1) == PRN], :); % ��ȡĳһ�����ǵ���������
            if isempty(one_sv_eph)
                continue; %��ǰ����û��eph, pass
            end
            
            [~,idx] = min(abs(one_sv_eph(:, 17) - this_TOW)); % ����һ�����������뵱ǰʱ����ӽ�����һ������
            one_sv_eph = one_sv_eph(idx, :);
            
            M0 = one_sv_eph(2);
            Delta_n = one_sv_eph(3);
            e = one_sv_eph(4);
            sqrtA = one_sv_eph(5);
            OMEGA = one_sv_eph(6);
            i0 = one_sv_eph(7);
            omega =  one_sv_eph(8);
            OMEGA_DOT = one_sv_eph(9);
            iDOT = one_sv_eph(10);
            Cuc = one_sv_eph(11);
            Cus = one_sv_eph(12);
            Crc = one_sv_eph(13);
            Crs = one_sv_eph(14);
            Cic = one_sv_eph(15);
            Cis = one_sv_eph(16);
            toe = one_sv_eph(17);
            toc = one_sv_eph(20);
            a0 = one_sv_eph( 21);
            a1 = one_sv_eph(22);
            a2 = one_sv_eph(23);
            
            % �źŴ���ʱ��
            tau = C1./cv;
            
            %���������Ӳ�(���������ЧӦ����)
            sv_dt = sv_clock_bias(this_TOW , toc, a0, a1, a2, e, sqrtA, toe, Delta_n, M0);
            
            % ��������λ��
            [Xs, Ys, Zs, ~] = ch_sat_pos(this_TOW - tau, toc, a0, a1, a2, Crs, Delta_n, M0, Cuc, e, Cus, sqrtA, toe, Cic, OMEGA, Cis, i0, Crc, omega, OMEGA_DOT, iDOT);
            
            % ����λ�õ�����תУ��
            spos = ch_sv_pos_rotate([Xs ;Ys; Zs], tau);
  
            %7������������ӳ� dtrop
            dx = spos - X(1:3);
            [~, E1, ~] = topocent(X(1:3), dx);
            if isnan(geodeticHstation)
                [~,~,h] = togeod(a, finv, X(1), X(2), X(3));
                geodeticHstation=h*10^(-3);
            end
            if chooseTropo==1
                dtrop = tropo(sind(E1),geodeticHstation,P0,T,e0,geodeticHstation,geodeticHstation,geodeticHstation);
            elseif chooseTropo==2
                dtrop = tropo_error_correction(E1,geodeticHstation);
            end
            % dtrop=0;%�ݲ�����dtrop
            %8�����������ӳ� diono
            diono = Error_Ionospheric_Klobuchar(X(1:3,1)',[Xs; Ys; Zs]', Alpha, Beta, this_TOW);
            
            l(j) = C1 + cv*sv_dt - dtrop - diono;
            sv_pos(j,:) = spos;
            j = j+1;
        end
        
        L = l;
        
        [X, residual, G] = ch_gpsls(X,  sv_pos',  L);

        %���������Զ����ʵ�һ�ˣ������µ���
        if (abs(norm(X(1:3)) - a) > 1000*100)
            X = [0 0 0 0]';
            break;
        else if norm(residual(1:3)) < 0.1
                rec_xyz(ii,:) = X;
                break;
            end
        end
    end
    
end

%% ɾ����λʧ�ܵ���
rec_xyz(all(rec_xyz==0,2),:) = [];

%% ��֤
GT = [-2267749.30600679, 5009154.2824012134, 3221290.677045021]';
error = rec_xyz(:,1:3) - GT';

fprintf("ƫ��:%f std:%f\r\n", mean(vecnorm(error, 2, 2)), std(vecnorm(error, 2, 2)));

[lat, lon, h] = ch_ECEF2LLA(GT);

for i = 1: length(rec_xyz)
    [E, N, U] = ch_ECEF2ENU(rec_xyz(i, (1:3)), lat, lon, h);
    ENU(i,:) = [E, N, U];
end

figure;
subplot(3, 1, 1);
plot(ENU(:,1));
ylabel("E");
subplot(3, 1, 2);
plot(ENU(:,2));
ylabel("N");
subplot(3, 1, 3);
plot(ENU(:,3));
ylabel("U");



figure;
plot(ENU(:,1), ENU(:,2), '*');
xlabel("E"); ylabel("N");


figure;
plot(rec_xyz(:,4), '.-');
title("���ջ��Ӳ�");

%
% %% plot
% plot(outdata.poslla(:,2), outdata.poslla(:,1), '.');
% xlabel('lon');
% ylabel('lat');
%
% [lat0, lon0, h0] = ch_ECEF2LLA(outdata.pos_ecef(1,:));
% for i = 1:length(outdata.pos_ecef)-1
%     [E, N, U]  = ch_ECEF2ENU(outdata.pos_ecef(i,:), lat0, lon0, h0 );
%     pos_enu(i,:) = [E; N; U];
% end
%
% pos_enu(end,:)
%
%
% %  [az, el] = satellite_az_el(outdata.pos_sv(2,:)' , outdata.pos_ecef(1,:)');
% %  rad2deg(az)
% %  rad2deg(el)
%
%
% figure;
% plot(pos_enu(:,1), pos_enu(:,2), '.');
% xlabel('E');
% ylabel('N');
%
% figure;
% subplot(3,1,1);
% plot(pos_enu(:,1));
% ylabel('E');
% subplot(3,1,2);
% plot(pos_enu(:,2));
% ylabel('N');
% subplot(3,1,3);
% plot(pos_enu(:,3));
% ylabel('U');
%
%
% figure;
% subplot(3,1,1);
% plot(outdata.HDOP);
% title('HDOP');
% subplot(3,1,2);
% plot(outdata.VDOP);
% title('VDOP');
% subplot(3,1,3);
% plot(outdata.usr_clk_bias/c);
% title('usc_clk_bias');
%
%
%
