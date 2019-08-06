clear;
clc;
GPS_data = csvread('nav_100hz.csv',1,1);
[row,column] = size(GPS_data);
L_gps = 1;      % GPS到后轴中点的距离
L = 2.7;        % 轴距
B = 1.802;        % 车身宽度
Lf = 1;         % 前悬长度
Lr = 1.1;       % 后悬长度
%---------------------------------------------------------------------------------------------------
%滤波
% c=1;
% for i=1:1:(row-1)
%     if abs(GPS_data(i,1)-GPS_data(i+1,1))>0.01 || abs(GPS_data(i,2)-GPS_data(i+1,2))>0.01 || abs(GPS_data(i,3)-GPS_data(i+1,3))>1 || abs(GPS_data(i,13)-GPS_data(i+1,13))>1 || abs(GPS_data(i,1))>1000 || abs(GPS_data(i,2))>1000     
%         b(c,1)=i;
%         c=c+1;
% %         fprintf('i=%d\n',i);
%      end
% end
% % 将不满足条件的GPS数据置空
% d=length(b);
% for i=d:-1:1
%     e=b(i,1);
%     GPS_data(e,:)=[];
% end

%原点位置大概在进入圆广场的十字路口
original_latitude = 23.384265425953;                                       % 原点处纬度
original_longitude = 113.171198359442;                                     % 原点处经度
original_altitude = 0.0;                                                   %原点处海拔：0
original_heading = 0.0;                                                    %正北方向为航向角0点

original_GPS = [original_latitude, original_longitude]; % 原点绝对地理坐标
original_point = [0 0];                                                  % 原点直角坐标

%% 距离差分信息---------------------------------------------------
latitude_step = 111210;                                                    % DNTC附近，南北方向 111,210m/1°N(latitude)
longitude_step = 101950;                                                   % DNTC附近，东西方向 101,950m/1°E(longitude)

%% 
%经纬度转笛卡尔坐标系
[m,n]=size(GPS_data);
P=zeros(m-1,3);%y,x,z
for i = 1:m-1
    P(i,1) = (GPS_data(i,4)-original_GPS(2))*longitude_step;
    P(i,2) = (GPS_data(i,3)-original_GPS(1))*latitude_step;
   
end