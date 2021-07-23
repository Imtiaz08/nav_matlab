%This Function approximate Ionospheric Group Delay ����������Ƶ����Ⱥ�ӳ�
%CopyRight By Moein Mehrtash
%************************************************************************
% Written by Moein Mehrtash, Concordia University, 3/21/2008            *
% Email: moeinmehrtash@yahoo.com                                        *
%************************************************************************
% ***********************************************************************
%      Function for   computing an Ionospheric range correction for the *
%      GPS L1 frequency from the parameters broadcasted in the GPS      *
%      Navigation Message.����:����GPS������Ϣ�й㲥�Ĳ��������������������GPS L1Ƶ�ʡ�                                              *
%      ==================================================================
%      References:                                                      *
%      Klobuchar, J.A., (1996) "Ionosphercic Effects on GPS", in        *
%        Parkinson, Spilker (ed), "Global Positioning System Theory and *
%        Applications, pp.513-514.                                      *
%      ICD-GPS-200, Rev. C, (1997), pp. 125-128                         *
%      NATO, (1991), "Technical Characteristics of the NAVSTAR GPS",    *
%        pp. A-6-31   -   A-6-33                                        *
%      ==================================================================
%    Input :                                                            *
%        Pos_Rcv       : XYZ position of reciever               (Meter) *
%        Pos_SV        : XYZ matrix position of GPS satellites  (Meter) *
%        GPS_Time      : Time of Week                           (sec)   *
%        Alfa(4)       : The coefficients of a cubic equation           *
%                        representing the amplitude of the vertical     *
%                        dalay (4 coefficients - 8 bits each)  ��ʾ��ֱdalay��������η��̵�ϵ��(4��ϵ����ÿ��8λ)         *
%        Beta(4)       : The coefficients of a cubic equation           *
%                        representing the period of the model           *
%                        (4 coefficients - 8 bits each) ��ʾģ�����ڵ����η��̵�ϵ��(4��ϵ��-��8λ)                *
%    Output:                                                            *
%       Delta_I        : Ionospheric slant range correction for         *
%                        the L1 frequency�����L1Ƶ�ʵ���б����У��(Sec)   *
%     ==================================================================

function [ delay ]=iono_correction(RP, SP, alpha, beta, gpst)
% RP: ���ջ�λ��
% SP: ����λ��
% Alpha Beta �����У׼����
% GPS Time
% delay ��λΪm

if norm(RP) < 1
    delay = 0;
    return;
end

[lat, lon, ~] = ch_ECEF2LLA(RP);


lat = lat/pi;
lon =lon/pi;   % semicircles unit Lattitdue and Longitude



[el, az] = satellite_az_el(SP, RP);
E = az/pi;                                            %SemiCircle Elevation
A = el;                                               %SemiCircle Azimoth
% Calculate the Earth-Centered angle, Psi
Psi = 0.0137/(E+.11)-0.022;                        %SemiCircle

%Compute the Subionospheric lattitude, Phi_L
Phi_L = lat+Psi*cos(A);                         %SemiCircle
if Phi_L>0.416
    Phi_L=0.416;
elseif Phi_L<-0.416
    Phi_L=-0.416;
end

%Compute the subionospheric longitude, Lambda_L
Lambda_L = lon+(Psi * sin(A)/cos(Phi_L*pi));  %SemiCircle

%Find the geomagnetic lattitude ,Phi_m, of the subionospheric location
%looking toward each GPS satellite:
Phi_m = Phi_L+0.064*cos((Lambda_L-1.617)*pi);

%Find the Local Time ,t, at the subionospheric point
t=4.32*10^4*Lambda_L+gpst;                 %GPS_Time(Sec)
t= mod(t,86400);
if t>86400
    t = t-86400;
elseif t<0
    t=t+86400;
end

%Convert Slant time delay, Compute the Slant Factor,F
F=1+16*(.53-E)^3;

%Compute the ionospheric time delay T_iono by first computing x
Per=beta(1)+beta(2)*Phi_m+beta(3)*Phi_m^2+beta(4)*Phi_m^3;
if Per <72000                                     %Period
    Per=72000;
end
x=2*pi*(t-50400)/Per;                       %Rad
AMP=alpha(1)+alpha(2)*Phi_m+alpha(3)*Phi_m^2+alpha(4)*Phi_m^3;
if AMP<0
    AMP=0;
end
if abs(x)>1.57
    T_iono=F*5*10^(-9);
else
    T_iono=F*(5*10^(-9)+AMP*(1-x^2/2+x^4/24));
end


delay = T_iono*299792458;
