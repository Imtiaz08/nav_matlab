
function out = ch_qintg(in, gyr, dt)

% ��������תʸ��
 rv = gyr*dt;
 dq = ch_rv2q(rv);

%��רҵ������
%                  dq(1) = 1;
%                  dq(2) = rv(1)*0.5;
%                  dq(3) = rv(2)*0.5;
%                  dq(4) = rv(3)*0.5;

out = ch_qmul(in, dq);
out = ch_qnormlz(out);
end

