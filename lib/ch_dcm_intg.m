
function Cb2n_out = ch_dcm_intg(Cb2n_in, gyr, dt)
% רҵ������1
rv = gyr*dt;
dm = ch_rv2m(rv);

%רҵ��������������ת����
Cb2n_out = Cb2n_in * dm;

% ��רҵ������
%  rv = gyr*dt;
% dm = skew_symmetric(rv);
% Cb2n_out = Cb2n_in + dm;

end

