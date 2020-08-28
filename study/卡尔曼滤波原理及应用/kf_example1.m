addpath('../../library');
clc; 
clear;
close all;

N=100;

CON=25; %�����¶�����ֵ
Xexpect=CON*ones(1,N);
X=zeros(1,N);  % ��ʵֵ
Xkf=zeros(1,N); % �������˲�ֵ
Z=zeros(1,N); %�۲�ֵ
P=zeros(1,N); 

X(1)=25.1;
Z(1)=24.9;

Q=0.01; %��������
R=0.25; %��������

W=sqrt(Q)*randn(1,N); %�������
V=sqrt(R)*randn(1,N);  %�������

F=1; 
G=1;
H=1; 

for k = 2:N
    X(k)=F*X(k-1)+G*W(k-1);
    Z(k)=H*X(k)+V(k);
end

numobs = size(Z, 2);

% ��ʼֵ
Xkf(:, 1) = X(1);
P(1)=0.01;
Xkf(1)=Z(1);

for k = 2 : numobs
   [ Xkf(:, k) , P] = kf(Xkf(:, k-1), Z(k), F, H, R ,Q, P);
end

Err_Messure=zeros(1,N);
Err_Kalman=zeros(1,N);
for k=1:N
    Err_Messure(k)=abs(Z(k)-X(k));
    Err_Kalman(k)=abs(Xkf(k)-X(k));
end
t=1:N;
figure('Name','Kalman Filter Simulation','NumberTitle','off');
plot(t,Xexpect,'-b',t,X,'-r',t,Z,'-k',t,Xkf,'-g');
legend('expected','real','measure','kalman estimate');         
xlabel('sample time');
ylabel('temperature');
title('Kalman Filter Simulation');
figure('Name','Error Analysis','NumberTitle','off');
plot(t,Err_Messure,'-b',t,Err_Kalman,'-k');
legend('�˲�ǰ���','�˲������')  
xlabel('sample time');





