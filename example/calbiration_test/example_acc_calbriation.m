%% Example: ��С���˷�У׼���ٶȼ�
clc;
clear;
close all;
format short;

%% У׼����
input =[
      0.9896   0.0121  -0.0193 
     -0.0124   1.0013   0.0024 
     -0.0083  -0.0087   0.9944 
     -1.0094  -0.0084   0.0018 
     -0.0068  -0.9974  -0.0198 
     -0.0119   0.0115  -1.0081 
    ];







 
[C, B] = acc_calibration(input);

fprintf('У׼����:');
C
fprintf('��ƫ:');
B

%% ����У׼�������
output(1,:) = C*(input(1,:)') - B;
output(2,:) = C*(input(2,:)') - B;
output(3,:) = C*(input(3,:)') - B;

output(4,:) = C*(input(4,:)') - B;
output(5,:) = C*(input(5,:)') - B;
output(6,:) = C*(input(6,:)') - B;



%% ����У׼ǰ�����
err =  input - [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];
residul_input =  sum(sum(abs(err).^2, 2).^(1/2));

err =  output - [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];
residul_output =  sum(sum(abs(err).^2, 2).^(1/2));
fprintf('У׼ǰ���: %f    У׼�����: %f\n', residul_input, residul_output);

%% plot
grid on;
plot3(input(:,1), input(:,2), input(:,3), 'or');
hold on;
plot3(output(:,1), output(:,2), output(:,3), '*b');
axis equal

legend('����', 'У׼��');

