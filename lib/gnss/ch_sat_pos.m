function [XYZ, sv_dt]=ch_sat_pos(t, toc, a0, a1, a2, Crs, Delta_n, M0, Cuc, e, Cus, sqrtA, toe, Cic, OMEGA, Cis, i0, Crc, omega, OMEGA_DOT, iDOT)
% ����:
% toe: �����ο�ʱ�䣺 һ����������Ч��Ϊtoeǰ��4Сʱ
% a0 a1 a2 toc: ����ʱ��У��ģ�ͷ�����3��������  toc: ��һ���ݿ�ο�ʱ��, ������ʱ��У��ģ����ʱ��ο���


% ������������(16��):
% sqrtA: ���ǹ���������ƽ����
% es: ���ƫ����
% i0: toeʱ�̹�����
% OMEGA0: ����ʱ����0ʱ�̵Ĺ��������ྭ
% omega: ������ؽǾ�
% M0: toeʱ�̵�ƽ�����
% Delta_n�� ƽ���˶����ٶ�У��ֵ
% iDOT�� �����Ƕ�ʱ��ı仯��
% OMEGA_DOT�� ���������ྭ��ʱ��ı仯��
% Cuc: ������Ǿ����Һ�У�����
% Cus: ������Ǿ����Һ�У�����
% Cic: ���������Һ�У�����
% Cis: ���������Һ�У�����

%���:
% X, Y, Z ECEF������λ��
% sv_dt�� ����ʱ��ƫ��

%����: 
%�㶯��������������uk������ʸ��rk�͹�����ik
%�����ڹ��������ϵ�е�����x,y
%����ʱ��������ľ���L


%����Ϊ�������
%1.�����������е�ƽ�����ٶ�
n0=sqrt(3.986005E+14)/(sqrtA.^3);
n=n0+Delta_n;
%2.�����źŷ���ʱ���ǵ�ƽ�����
sv_dt = a0+a1*(t-toc)+a2*(t-toc).^2;%tΪδ���Ӳ�����Ĺ۲�ʱ��
t = t - 0;%����tΪ���Ӳ�������ֵ
tk = t-toe;%�黯ʱ��
if tk>302400
    tk=tk-604800;
elseif tk<-302400
    tk=tk+604800;
else
    tk=tk+0;
end
Mk=M0+n*tk;
%3.����ƫ����ǣ�������
%E=M+e*sin(E);
ed(1)=Mk;
for i=1:3
   ed(i+1)=Mk+e*sin(ed(i));
end
Ek=ed(end);
%4.����������
Vk=atan2(sqrt(1-e.^2)*sin(Ek),(cos(Ek)-e));
%5.����������ǣ�δ���Ľ�ʱ��
u=omega+Vk;
%6.�����㶯������
deltau=Cuc*cos(2*u)+Cus*sin(2*u);
deltar=Crc*cos(2*u)+Crs*sin(2*u);
deltai=Cic*cos(2*u)+Cis*sin(2*u);
%7.�����㶯��������������uk������ʸ��rk�͹�����ik
uk=u+deltau;
rk=(sqrtA.^2)*(1-e*cos(Ek))+deltar;
ik=i0+deltai+iDOT*tk;
%8.���������ڹ��������ϵ�е�����
x=rk*cos(uk);
y=rk*sin(uk);
%9.���㷢��ʱ��������ľ���67
L=OMEGA+(OMEGA_DOT-7.2921151467e-5)*tk-7.2921151467e-5*toe;
%10.���������ڵع�����ϵ������
XYZ(1)=x*cos(L)-y*cos(ik)*sin(L);
XYZ(2)=x*sin(L)+y*cos(ik)*cos(L);
XYZ(3)=y*sin(ik);
XYZ = XYZ';

end