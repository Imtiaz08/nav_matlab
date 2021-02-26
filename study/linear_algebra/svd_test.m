%% svd study 

clear all;
close all;
clc;

a=imread('svd_pic.jpg');
a = a(:,:,1); %ȡһ������

imshow(mat2gray(a))
[m, n]=size(a);
title("ԭʼͼ��");
fprintf("ͼƬ�ߴ�:%d x %d\n", m, n);


fprintf("ԭʼͼ���С:%d\n", m*n);
a=double(a);
r=rank(a);


[U, S, V]=svd(a);

k = 70; %�޸����ֵ��ȡǰk�����ɷ�
%re=U*S*V';
U = U(:,1:k);
V = V(:,1:k);
S = S(1:k, 1:k);
re=U*S*V';

figure;
imshow(mat2gray(re));
title("ѹ����ͼ��");
fprintf("ѹ�����С:%d\n", numel(U)  + k +  numel(V));

figure;
plot(diag(S));
title("����ֵ")

