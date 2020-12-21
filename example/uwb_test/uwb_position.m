clc;
close all;
clear;

%% load data
load('uwb_test_dataset1.mat');
uwb = dataset.uwb;

%% remove outliler
tof = uwb.tof';
f_tof = smoothdata(tof,'rlowess', 100);

figure;
plot(tof, '.');
hold on;
plot(f_tof);
legend('ԭʼX', 'ԭʼY', 'ԭʼZ', '�˲�X', '�˲�Y', '�˲�Z');


tof = f_tof';

%% ����λ��
n = length(tof);

pos = [1 1 1]';
uwb.pos = zeros(size(uwb.anchor,1), n);

% ��߶�λ����
for i = 1:n
    pos =  ch_multilateration(uwb.anchor, pos, tof(:,i)', 3);
    uwb.pos(:,i)   =pos;
end

%% plot data
ch_plot_uwb(uwb.anchor, uwb.pos, 3);


