clear;
clc
close all;

%% EXAMPLE 2.1(a) 
%% Conversion of Euler attitude to Coordinate Transformation Matrices and Quaternions
roll = deg2rad(-30);
pitch = deg2rad(30);
yaw = deg2rad(45);
eul = [roll pitch yaw]';

Cn2b = ch_eul2m(eul);
Cn2b

% Conversion to Quaternions
Cb2n = [0.612372 -0.78915 -0.04737;  0.612372 0.435596 0.65974 ; -0.5 -0.43301 0.75];
Qn2b = ch_m2q(Cb2n);
Qn2b


%% EXAMPLE 2.1(b)
%% Conversion of Coordinate Transformation Matrix to Euler attitude and Quaternions
Cb2n = [0.612372 -0.78915 -0.04737; 0.612372 0.435596 0.65974; -0.5 -0.43301 0.75];
eul = ch_m2eul(Cb2n');
eul


Qn2b = ch_m2q(Cb2n);
Qn2b

%% EXAMPLE 2.1(c)
%% Conversion of Quaternions to Coordinate Transformation Matrix and Euler attitude 
Qn2b = [0.836356 -0.32664 0.135299 0.418937]';
Cb2n = ch_q2m(Qn2b);
Cb2n

eul = ch_q2eul(Qn2b);
rad2deg(eul)





