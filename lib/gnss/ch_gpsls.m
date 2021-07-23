function [X, delta, G] = ch_gpsls(X,  SVP,  rho)
% GPS α����С���˷���⣬ ״̬��Ϊ X Y Z B(�Ӳ�)
% X: X ֵ(1:3) λ��delta, (4) �û��Ӳ�ƫ��
% rho: У�����α��
% SVP: ����λ�þ���
% delta: delta ֵ(1:3) λ��delta, (4) �û��Ӳ�ƫ��

B1=1;
END_LOOP=100;
%���Ǹ���
n = size(SVP, 2);

if n < 4
    delta = 0;
    G = 0;
    return
end
   X0 = X;

    for loop = 1:10
        % ��õ�ǰλ���������վ�ľ���
        r = vecnorm(SVP - X(1:3));
        
        % ���H����
        H = (SVP - X(1:3)) ./ r;
        H =-H';
        
        H = [H(:,1:3),  ones(n,1)];
        
        dp = ((rho - r) -  X(4))';
        
        % �����û�����
        delta =  (H'*H)^(-1)*H'*dp;
        X = X + delta;
        G = H;
        
    %    END_LOOP = vnorm(delta(1:3));
    end
    
    delta = X - X0;
    
end


