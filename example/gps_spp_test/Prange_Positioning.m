clear;
clc;
close all;

% �ο�: https://www.telesens.co/2017/07/17/calculating-position-from-raw-gps-data/#Rotating_the_Satellite_Reference_Frame
% GPSԭ��Ӧ�� л��


geodeticHstation=93.4e-3;%NaN                            %��վ��ظ�km�������֪����NaN

% filen='wuhn2470.01n';
% fileo='wuhn2470.01o';
%  Alpha = [0.2235D-07  0.2235D-07 -0.1192D-06 -0.1192D-06];  %��������ͷ�ļ��еĵ����Alpha
%  Beta = [0.1290D+06  0.4915D+05 -0.1966D+06  0.3277D+06];   %��������ͷ�ļ��еĵ����Beta



filen='SAVE2021_7_20_22-32-23.nav';
fileo='SAVE2021_7_20_22-32-23.obs';
Alpha = [0.4657D-08  0.1490D-07 -0.5960D-07 -0.5960D-07];  %��������ͷ�ļ��еĵ����Alpha
Beta = [ 0.7987D+05  0.6554D+05 -0.6554D+05 -0.3932D+06];   %��������ͷ�ļ��еĵ����Beta

chooseTropo = 2;                                           %���õĶ�����ģ��1:�򻯻��շƶ��£�Hopfield������ģ�� 2:��˹��Ī����Saastamoinen������ģ��

cv = 299792458;                                            %����m/s
a = 6378137;                                               %WGS84����볤��m
finv = 298.2572236;                                        %WGS84������ʵ���


fprintf("��ȡ renix obs ����...\r\n");
[obs, ~]  = read_rinex_obs(fileo);
%load 'obs.mat';


% ��ȡn�ļ�
fprintf("��ȡ renix nav ����...\r\n");
all_eph = read_rinex_nav(filen);
fprintf("��ȡ���\r\n");


fprintf("��ʼ��λ...\r\n");

RP_valid  = false;

%�����ʼ�����ò�վ����λ��ΪXr�����ջ��Ӳ��ֵΪdt��
X = [0 0 0 0]';

% ��ȡ��ǰʱ�̵���������obs ʱ��
epochs = unique(obs.data(:, obs.col.TOW));
TimeSpan=epochs(1:end);

% ��ȡ��ǰʱ���������ǵ�eph
%eph = unique(all_eph())
%one_sv_eph = all_eph([all_eph(:,1) == PRN], :); % ��ȡĳһ�����ǵ���������

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
    rho_corr = []; %У����α��
    
    while(1)
        j = 1;
        for i=1:sv_num
            % ѡ����ǰʱ�̵� ĳ�����ǵ����й۲�
            PRN_obs.data = curr_obs.data(i,:);
            PRN_obs.col = curr_obs.col;
            PRN = PRN_obs.data(obs.col.PRN);
            C1 = PRN_obs.data(obs.col.C1); %α��
            
            % ����뵱ǰʱ����ӽ���eph
            one_sv_eph = all_eph([all_eph(:,1) == PRN], :); % ��ȡĳһ�����ǵ���������
            if isempty(one_sv_eph)
                continue; %��ǰ����û��eph, pass
            end
            
            [diff, idx] = min(abs(one_sv_eph(:, 17) - this_TOW)); % ����һ�����������뵱ǰʱ����ӽ�����һ������
            
            one_sv_eph = one_sv_eph(idx, :);
            %  fprintf("PRN:%d ��ǰ %d toe:%d ���:%d\r\n", PRN, this_TOW, one_sv_eph(17), diff);
            
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
            [SP, ~] = ch_sat_pos(this_TOW - tau, toc, a0, a1, a2, Crs, Delta_n, M0, Cuc, e, Cus, sqrtA, toe, Cic, OMEGA, Cis, i0, Crc, omega, OMEGA_DOT, iDOT);
            
            % ����λ�õ�����תУ��
            spos = ch_sv_pos_rotate(SP, tau);
            
            % ����������ӳ� dtrop
            dx = spos - X(1:3);
            [~, E1, ~] = topocent(X(1:3), dx);
            if isnan(geodeticHstation)
                [~,~,h] = togeod(a, finv, X(1), X(2), X(3));
                geodeticHstation=h*10^(-3);
            end
            
            
            if RP_valid
                %��������ʱ
                [el, az] = satellite_az_el(SP, X(1:3));
                dtrop = tropo_correction(el, geodeticHstation);
                %���������ӳ� diono
                
            else
                dtrop = 0;
            end

            diono = iono_correction(X(1:3,1), SP, Alpha, Beta, this_TOW);
            
            rho_corr(i) = C1 + cv*sv_dt - dtrop - diono;
            %  l(j) = C1 + cv*sv_dt;
            sv_pos(j,:) = spos;
            j = j+1;
        end
        
        
        [X, residual, G] = ch_gpsls(X,  sv_pos',  rho_corr);
        
        %���������Զ����ʵ�һ�ˣ������µ���
        if (abs(norm(X(1:3)) - a) > 1000*100)
            RP_valid = true;
            X = [0 0 0 0]';
            break;
        else if norm(residual(1:3)) < 0.1
                RP_valid = false;
                outdata.rec_xyz(ii,:) = X;
                outdata.G{ii} = G;
                outdata.sv_num(ii) = sv_num;
                break;
            end
        end
    end
    
end

%% ����

% ɾ����λʧ�ܵ���
outdata.rec_xyz(all(outdata.rec_xyz==0,2),:) = [];

%% ��֤
%GT = [-2267749.30600679, 5009154.2824012134, 3221290.677045021]';
GT = [39.940093, 116.37498022 , 48.176];
GT = ch_LLA2ECEF(deg2rad(GT(1)), deg2rad(GT(2)), GT(3));

error = outdata.rec_xyz(:,1:3) - GT';

fprintf("ƫ��:%f std:%f\r\n", mean(vecnorm(error, 2, 2)), std(vecnorm(error, 2, 2)));

[lat, lon, h] = ch_ECEF2LLA(GT);

for i = 1: length(outdata.rec_xyz)
    [E, N, U] = ch_ECEF2ENU(outdata.rec_xyz(i, (1:3)), lat, lon, h);
    outdata.ENU(i,:) = [E, N, U];
    [lat, lon, h] = ch_ECEF2LLA(outdata.rec_xyz(end,:));
    outdata.lla(i,:) = [lat, lon, h];
    [VDOP, HDOP, PDOP, GDOP] = ch_gpsdop(outdata.G{i}, lat, lon);
    outdata.VDOP(i) = VDOP;
    outdata.HDOP(i) = HDOP;
    outdata.PDOP(i) = PDOP;
    outdata.GDOP(i) = GDOP;
end


fprintf("���һ��λ��: %f %f %f\r\n", rad2deg(outdata.lla(end,1)), rad2deg(outdata.lla(end,2)), outdata.lla(end,3));


figure;
subplot(3, 1, 1);
plot(outdata.ENU(:,1));
ylabel("E");
subplot(3, 1, 2);
plot(outdata.ENU(:,2));
ylabel("N");
subplot(3, 1, 3);
plot(outdata.ENU(:,3));
ylabel("U");


figure;
plot(outdata.ENU(:,1), outdata.ENU(:,2), '*');
xlabel("E"); ylabel("N");


figure;
plot(outdata.rec_xyz(:,4), '.-');
title("���ջ��Ӳ�");

figure;
plot(outdata.HDOP);
hold on;
plot(outdata.VDOP);
hold on;
plot(outdata.sv_num);
legend("HDOP", "VDOP", "SV");


