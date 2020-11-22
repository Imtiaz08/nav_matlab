%% ��С���˷���߲��
% sv_pos: ��վλ�� mxn m: ά:2 or 3, n ��վ����
% pos:  mx1  m:2or3
%pr:  α�� mx1
%dim : 2 or 3 : 2:2D��λ  3: 3D��λ
function pos = ch_multilateration(sv_pos, pos, pr, dim)

B1=1;
END_LOOP=100;
sv_num = size(sv_pos, 2);
max_retry = 5;
last_pos = pos;
support_2d = false; %% ֻ��������վ������£�3D��λ��Ҫ��Ӹ�������

if sv_num < 3
    return
end

if sv_num <= 3 && dim == 3
    % ֻ��������վ��3D��λ����Ҫ��Ӹ������̣� dZ = 0
    support_2d = true;
end

while (END_LOOP > B1 && max_retry > 0)
    % ��õ�ǰλ���������վ�ľ���
    r = vecnorm(sv_pos - pos);
    
    % ���H����
    H = (sv_pos - pos) ./ r;
    if support_2d == true
        H = [H [0 0 -1]'];
    end
    H =-H';
    
    dp = (pr - r)';
    if support_2d == true
        dp = [dp; 0];
    end
    
    % �����û�����
    delta =  (H'*H)^(-1)*H'*dp;
    
    %����в�
    END_LOOP = vnorm(delta);
    
    %����λ��
    pos = pos + delta;
    max_retry = max_retry - 1;
    
    %����ʧ��
    if(max_retry == 0 && END_LOOP > 10)
        pos = last_pos;
        return;
    end
    
end

end



%
% % ��С���˷���߲��
%
% function pos = ch_multilateration(anchor_pos,  pos, pr)
%
% pr = pr(1:size(anchor_pos, 2));
%
% b = vecnorm(anchor_pos).^(2) - pr.^(2);
% b = b(1:end-1) - b(end);
% b = b';
%
% A =  anchor_pos - anchor_pos(:,end);
% A = A(:,1:end-1)'*2;
%
% pos = (A'*A)^(-1)*A'*b;
%
%
% end

