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

ch_plot_pos3d('p1', uwb.pos',  'legend', ["UWB�켣"]);
anch = uwb.anchor;
hold all;
scatter(anch(1, :),anch(2, :),'k');
for i=1:size(anch,2)
    text(anch(1, i),anch(2, i),"A"+(i-1))
end
hold off;



