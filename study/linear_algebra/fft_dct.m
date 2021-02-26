clear;
clc;
close all;

figure;


origin  = imread('autumn.tif');

imshow(origin); title('ԭͼ');

ratio = 1.0;
[z, k] = fft_compress(origin, ratio);

figure;
subplot(3, 2, 1);
imshow(z);
subplot(3, 2, 2);
imshow(k), title( ['FFT ѹ������:',num2str(ratio)]);

ratio = 0.6;
[z, k] = fft_compress(origin, ratio);

subplot(3, 2, 3);
imshow(z);
subplot(3, 2, 4);
imshow(k), title( ['FFT ѹ������:',num2str(ratio)]);

ratio = 0.3;
[z, k] = fft_compress(origin, ratio);

subplot(3, 2, 5);
imshow(z);
subplot(3, 2, 6);
imshow(k), title( ['FFT ѹ������:',num2str(ratio)]);












ratio = 1.0;
[z, k] = dct_compress(origin, ratio);

figure;
subplot(3, 2, 1);
imshow(z);
subplot(3, 2, 2);
imshow(k), title( ['DCT ѹ������:',num2str(ratio)]);

ratio = 0.6;
[z, k] = fft_compress(origin, ratio);

subplot(3, 2, 3);
imshow(z);
subplot(3, 2, 4);
imshow(k), title( ['DCT ѹ������:',num2str(ratio)]);

ratio = 0.3;
[z, k] = fft_compress(origin, ratio);

subplot(3, 2, 5);
imshow(z);
subplot(3, 2, 6);
imshow(k), title( ['DCT ѹ������:',num2str(ratio)]);


