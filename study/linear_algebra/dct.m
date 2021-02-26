clear;
clc;


RGB = imread('autumn.tif');
I = rgb2gray(RGB);

% ��I ����dct�任
J = dct2(I);


figure
% ��ӡJ(Ƶ��ͼ)
imshow(log(abs(J)),[])
colormap(gca,jet(64))
colorbar

%ȥ����Ƶ����
J(abs(J) < 20) = 0;

%��任��ʱ��ͼ��
K = idct2(J);

figure
imshowpair(I,K,'montage')
title('Original Grayscale Image (Left) and Processed Image (Right)');

