function SP = ch_sv_pos_rotate(SP, tau)
%% ���㾭��������ת�����������λ��
% Earth's rotation rate
% SP: ����λ��
omega_e = 7.2921151467e-5; %(rad/sec)
theta = omega_e * tau;
SP = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*SP;
end
