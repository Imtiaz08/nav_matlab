%% Example:
% subplot���Ƿ���subplot
function ch_imu_data_plot(varargin)
%%  plot imu data
i = 1;
param= inputParser;
param.addOptional('time', []);
param.addOptional('acc', []);
param.addOptional('gyr', []);
param.addOptional('mag', []);
param.addOptional('eul', []);
param.addOptional('wb', []); % ������ƫ
param.addOptional('phi', []); %ʧ׼��
param.addOptional('P_phi', []); %ʧ׼�Ƿ���
param.addOptional('P_wb', []); %���ݷ���
param.addOptional('subplot', []);

%Ȼ������Ĳ������д�������в�ͬ��Ĭ��ֵ���Ǿ͸��ǵ�
param.parse(varargin{:});
r = param.Results;

if(r.time == 0 )
    error('no time data');
end

figure('Name', 'Sensor Data');

if(~isempty(r.gyr))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.gyr, {'X', 'Y', 'Z'}, 'Time (s)', 'Angular rate (deg/s)', 'Gyroscope');
    i = i+1;
end

if(~isempty(r.acc))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.acc, {'X', 'Y', 'Z'}, 'Time (s)', 'Acceleration (g)', 'Accelerometer');
    i = i+1;
end

if(~isempty(r.mag))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.mag, {'X', 'Y', 'Z'}, 'Time (s)', 'Flux (G)', 'Magnetometer');
    i = i+1;
end

if(~isempty(r.eul))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.eul, {'X', 'Y', 'Z'}, 'Time (s)', 'Angle(deg)', 'Eular Angle');
    i = i+1;
end

if(~isempty(r.wb))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.wb, {'X', 'Y', 'Z'}, 'Time (s)', 'Angle(deg)', 'Gyr Bias');
    i = i+1;
end

if(~isempty(r.phi))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.phi, {'X', 'Y', 'Z'}, 'Time (s)', 'Angle(deg)', 'ʧ׼��');
    i = i+1;
end

if(~isempty(r.P_phi))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.P_phi, {'X', 'Y', 'Z'}, 'Time (s)', '-', 'Phi Var(ʧ׼�Ƿ���)');
    i = i+1;
end
    
if(~isempty(r.P_wb))
    if(r.subplot == 1)
        subplot(2,2,i);
    else
        if i ~= 1; figure; end
    end
    interial_display(r.time,  r.P_wb, {'X', 'Y', 'Z'}, 'Time (s)', '-', 'Gyr Bias Var');
    i = i+1;
end

%    linkaxes(axis, 'x');

end


function interial_display(time, data, legendstr, xlabelstr, ylabelstr, titlestr)
hold on;
plot(time, data(:,1), 'r');
plot(time, data(:,2), 'g');
plot(time, data(:,3), 'b');
legend(legendstr);
xlabel(xlabelstr);
ylabel(ylabelstr);
title(titlestr);
hold off;
end
