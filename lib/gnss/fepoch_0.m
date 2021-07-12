function [time, dt, sats, eof] = fepoch_0(fid)
% FEPOCH_0   Finds the next epoch in an opened RINEX file with
%	          identification fid. From the epoch line is produced
%	          time (in seconds of week), number of sv.s, and a mark
%	          about end of file. Only observations with epoch flag 0
%	          are delt with.

%Kai Borre 09-14-96; revised 03-22-97; revised Sept 4, 2001
%Copyright (c) by Kai Borre
%$Revision: 1.0 $  $Date: 1997/09/22  $
%fide = fopen(fid,'rt');

%���ú���ֻ���أ��ļ���һ����Ԫ�����²�����

% time��������
% dt�����ջ��Ӳ�ò���Ϊ��ѡ���һ�����е�o�ļ��ж��У�
% sats����ǰ��Ԫ���۲⵽������
% eof���Ƿ��ļ�ĩβ

global sat_index;
time = 0;
dt = 0;
sats = [];
NoSv = 0;
eof = 0;

%ѭ����ȡo�ļ���ÿһ��
while 1
   lin = fgets(fid); % earlier fgetl  �ȶ�һ��
   
   if (feof(fid) == 1); % �����ļ�ĩβ�������
      eof = 1;
      break
   end;
   
   % ��������
   if length(lin) <= 1
       continue;
   end
   
%    answer = findstr(lin,'COMMENT'); % �жϸ������Ƿ����ַ�����COMMENT��
%    
%    if ~isempty(answer);  % ���С�COMMENT�������������һ��
%       lin = fgetl(fid);
%    end;
   
   % ����������ݵ�29���ַ���Ϊ0��0�������Ԫ��������
   % �����ܳ���ֻ��29��Ҳ����û�к��������PRN���ݣ���
   % �������
   % if ((strcmp(lin(29),'0') == 0) & (size(deblank(lin),2) == 29)) 
   %    eof = 1; 
   %    break
   % end; % We only want type 0 data
   
   % ������еڶ����ַ���1�����ߵ�29���ַ���0����˵��
   % ��һ����ĳһ��Ԫ�Ŀ�ʼ�У��������Ϳ��ԴӸ�������ȡʱ�䡢PRN�Ȳ���
   if ((strcmp(lin(2),'1') == 1)  &  (strcmp(lin(29),'0') == 1))
      ll = length(lin)-2;
      if ll > 60, ll = 60; end;
      linp = lin(1:ll);        
      %fprintf('%60s\n',linp);
      
      %ʹ��strtok������ü����ǰ����ַ�����
      % �����ǻ�õ�ǰʱ��
      [nian, lin] = strtok(lin);
      % year;
      
      [month, lin] = strtok(lin);
      % month;
      
      [day, lin] = strtok(lin);
      % day;
      
      [hour, lin] = strtok(lin);
      % hour
      
      [minute, lin] = strtok(lin);
      % minute
      
      [second, lin] = strtok(lin);
      % second
      
      [OK_flag, lin] = strtok(lin); 
      % OK_flag���ǵ�29���ַ��������0�������Ԫ����
      
      %��ʱ��ת����ֵ�ͣ�Ȼ���ټ����GPS�ܺ�������
      h = str2num(hour)+str2num(minute)/60+str2num(second)/3600;
      jd = julday(str2num(nian)+2000, str2num(month), str2num(day), h);
      [week, sec_of_week] = gps_time(jd);
      time = sec_of_week;
      
      %��ø���Ԫ������
      [NoSv, lin] = strtok(lin,'G');
      
      %�������Ԫÿ�����ǵ�PRN
      for k = 1:str2num(NoSv)
         [sat, lin] = strtok(lin,'G');
         prn(k) = str2num(sat);
      end
      
      % prn��1��NoSv�еľ���sats����ת��
      sats = prn(:);
      
      % ���ռ��Ӳ�е�o�ļ���û�иò���
      dT = strtok(lin);
      if isempty(dT) == 0 %���dT��Ϊ0�������¼
         dt = str2num(dT);
      end
      
      break % ����whileѭ��
      
   end
   
end; 

% datee=[str2num(nian) str2num(month) str2num(day) str2num(hour) str2num(minute) str2num(second)];

%%%%%%%% end fepoch_0.m %%%%%%%%%
