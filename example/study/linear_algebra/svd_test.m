%% svd study 

clear all;
close all;
clc;

a=imread('svd_pic.jpg');
a = a(:,:,1); %ȡһ������

imshow(mat2gray(a))
[m, n]=size(a);
a=double(a);
r=rank(a);

[U, S, V]=svd(a);

k = 30; %�޸����ֵ��ȡǰk�����ɷ�
%re=U*S*V';
re=U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
figure;
imshow(mat2gray(re));

figure;
plot(diag(S));
title("����ֵ")

