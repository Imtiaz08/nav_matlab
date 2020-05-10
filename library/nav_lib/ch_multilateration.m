% ��С���˷���߲��

function pos = ch_multilateration(sv_pos, pos,  pr)

B1=1;
END_LOOP=100;
sv_num = size(sv_pos, 2);
max_retry = 5;
last_pos = pos;

if sv_num < 3
    return
end

while (END_LOOP > B1 && max_retry > 0)
    % ��õ�ǰλ���������վ�ľ���
    r = vecnorm(sv_pos - pos);
    
    % ���H����
    H = (sv_pos - pos) ./ r;
    H =-H';
    
    dp = (pr - r)';
    
    % �����û�����
    delta =  (H'*H)^(-1)*H'*dp;
    
    %����в�
    END_LOOP = vnorm(delta);
    
    pos = pos + delta;
    max_retry = max_retry - 1;
    
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

