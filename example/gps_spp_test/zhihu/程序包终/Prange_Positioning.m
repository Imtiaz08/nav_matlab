clear;
clc;
close all;

%----------------------------���ò���------------------------------------
tob = [01, 9, 4, 1, 30, 0];                                     %�۲�ʱ�̵�UTCʱ����ȡ����λ
geodeticHstation=93.4e-3;%NaN                            %��վ��ظ�km�������֪����NaN
Alpha=[0.2235D-07  0.2235D-07 -0.1192D-06 -0.1192D-06];  %��������ͷ�ļ��еĵ����Alpha
Beta=[0.1290D+06  0.4915D+05 -0.1966D+06  0.3277D+06];   %��������ͷ�ļ��еĵ����Beta
filen='wuhn2470.01n';
fileo='wuhn2470.01o';
chooseTropo = 2;                                           %���õĶ�����ģ��1:�򻯻��շƶ��£�Hopfield������ģ�� 2:��˹��Ī����Saastamoinen������ģ��
%------------------------------------------------------------------------
%----------------------------������--------------------------------------
cv = 299792458;                                            %����m/s
a = 6378137;                                               %WGS84����볤��m
finv = 298.2572236;                                        %WGS84������ʵ���

%------------------------------------------------------------------------
%����Ϊ�������
%1����O�ļ�����ȡ�Ŀ��������ǵ�C1�۲�ֵ��
fprintf("��ȡ renix obs ����...\r\n");
[obs, rec_xyz]  = read_rinex_obs(fileo);

% ȡ����ǰGPST ʱ�̵����й۲�����
[~,tow] = UTC2GPST(tob(1),tob(2),tob(3),tob(4),tob(5),tob(6));
obs.data = obs.data([obs.data(:,2) == tow], :);

% ��õ�ǰʱ�̹۲����ݵ�PRN�����Ǹ����͹۲�ֵ
PRN = obs.data(:,3);
sv_num = numel(PRN);
C1 = obs.data(:,6);

fprintf("��ǰʱ��: %d %d %d %d %d %d\r\n", tob(1), tob(2), tob(3), tob(4), tob(5), tob(6));
fprintf("����PRN:\r\n");
PRN'


% ��ȡN�ļ�,�����ҵ��͵�ǰʱ�������һ������
fprintf("��ȡ renix nav ����...\r\n");
all_eph = read_rinex_nav(filen);
for i = 1: sv_num
    one_sv_eph = all_eph([all_eph(:,1) == PRN(i)], :); % ��ȡĳһ�����ǵ���������
    [~,idx] = min(abs(one_sv_eph(:, 17) - tow)); % ����һ�����������뵱ǰʱ����ӽ�����һ������
    eph(i,:) = one_sv_eph(idx, :);
end

% �����������ǵ��Ӳ�
for i=1:sv_num
    toc = eph(i, 20);
    a0 = eph(i, 21);
    a1 = eph(i, 22);
    a2 = eph(i, 23);
    sv_dt = sv_clock_bias(tow, toc, a0, a1, a2);
    deltat(i) = sv_dt;
end

%3�������ʼ�����ò�վ����λ��ΪXr�����ջ��Ӳ��ֵΪdt��
X = [0 0 0 0]';
%4��ѡ��epoch��һ������Si������α��ΪGSiC1
while 1
    
    for i=1:sv_num
        %5����������Si�������Ӳ�dt
        %�ɼ�����������ʱ����
        %6����������-���ջ��Ľ��Ƽ��ξ���Rs
        %��1�����ݽ���ʱ���α�� �����źŷ���ʱ��
        tau(i) = C1(i)./cv;
        ttr(i) = tow-(tau(i) + deltat(i));
        
        %��2�����㷢��ʱ�̵��������� ����������������е�����ת����
        M0 = eph(i, 2);
        Delta_n = eph(i, 3);
        e = eph(i, 4);
        sqrtA = eph(i, 5);
        OMEGA = eph(i, 6);
        i0 = eph(i, 7);
        omega =  eph(i, 8);
        OMEGA_DOT = eph(i, 9);
        iDOT = eph(i, 10);
        Cuc = eph(i, 11);
        Cus = eph(i, 12);
        Crc = eph(i, 13);
        Crs = eph(i, 14);
        Cic = eph(i, 15);
        Cis = eph(i, 16);
        toe = eph(i, 17);
        toc = eph(i, 20);
        a0 = eph(i, 21);
        a1 = eph(i, 22);
        a2 = eph(i, 23);
        [Xs(i), Ys(i), Zs(i), deltat(i)] = ch_sat_pos(ttr(i), toc, a0, a1, a2, Crs, Delta_n, M0, Cuc, e, Cus, sqrtA, toe, Cic, OMEGA, Cis, i0, Crc, omega, OMEGA_DOT, iDOT);
        % [Xs(i), Ys(i), Zs(i), deltat(i)] = readatandcomp(filen, PRN(i), tob, Tems(i));
        spos = ch_sv_pos_rotate([Xs(i);Ys(i);Zs(i)], tau(i));
        
        %7������������ӳ� dtrop
        dx = spos - X(1:3,1);
        [~, E1(i), ~] = topocent(X(1:3,1),dx);
        if isnan(geodeticHstation)
            [~,~,h] = togeod(a,finv,X(1,1),X(2,1),X(3,1));
            geodeticHstation=h*10^(-3);
        end
        if chooseTropo==1
            dtrop = tropo(sind(E1(i)),geodeticHstation,P0,T,e0,geodeticHstation,geodeticHstation,geodeticHstation);
        elseif chooseTropo==2
            dtrop = tropo_error_correction(E1(i),geodeticHstation);
        end
        % dtrop=0;%�ݲ�����dtrop
        %8�����������ӳ� diono
        diono = Error_Ionospheric_Klobuchar(X(1:3,1)',[Xs(i);Ys(i);Zs(i)]', Alpha, Beta, tow);
        
        % diono=0;%�ݲ�����dtrop
        l(i) = C1(i) + cv*deltat(i) - dtrop - diono+0;
        
        
        %10��������Si��������
        sv_pos(i,:) = spos;
    end
    % 11��ѡ��Epoch�е���һ�����ǣ�����α��Ϊ��S��
    % 12���ظ�5--11��������ÿ�����ǵ�ϵ���������
    %13�����������ǵ�ϵ��������̣��ԣ�x,y,z,cdtr��Ϊδ֪��������⣬��ʽΪ:AX=L
    L = l;
    
    [X, delta, G] = ch_gpsls(X,  sv_pos',  L);
    
    
    % PȨ��
    % P=[sind(E1(1))^2,0,0,0,0,0;
    %     0,sind(E1(2))^2,0,0,0,0;
    %     0,0,sind(E1(3))^2,0,0,0;
    %     0,0,0,sind(E1(4))^2,0,0;
    %     0,0,0,0,sind(E1(5))^2,0;
    %     0,0,0,0,0,sind(E1(6))^2];
    % X=(inv(A'*P*A))*(A'*P*L);
    % Xi=X+X;%��һ����Ҫ
    % 15����X0���бȽϣ��ж�λ�ò�ֵ��
    %    X = X + delta;
    if abs(delta(1,1))>0.001 || abs(delta(2,1))>0.001 || abs(delta(3,1))>0.001
    else
        break;
    end
end

% %16���������������Xi��
GT = [-2267749.30600679, 5009154.2824012134, 3221290.677045021]';
residual = X(1:3) - GT;

fprintf("����λ�ò�: %f, %f, %f, ������:%f\r\n", residual(1), residual(2), residual(3), norm(residual));

% ECEFת LLA
[lat, lon, h] = ch_ECEF2LLA(X);

% ����DOP
[VDOP, HDOP, ~, ~] = ch_gpsdop(G, lat, lon);

fprintf("����: lat:%f lon:%f\r\n", rad2deg(lat), rad2deg(lon));
fprintf("VDOP: %f  HDOP: %f\r\n", VDOP, HDOP);



