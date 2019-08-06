function  OpenDriveGetFile(data)
fileID = fopen('/home/pz1_ad_04/桌面/1.txt','w');
%% coor data-> GPS data
%原点位置大概在进入圆广场的十字路口
original_latitude = 23.384265425953;                                       % 原点处纬度
original_longitude = 113.171198359442;                                     % 原点处经度
% original_altitude = 0.0;                                                   %原点处海拔：0
% original_heading = 0.0;                                                    %正北方向为航向角0点

original_GPS = [original_latitude, original_longitude]; % 原点绝对地理坐标

%% 距离差分信息---------------------------------------------------
latitude_step = 111210;                                                    % DNTC附近，南北方向 111,210m/1°N(latitude)
longitude_step = 101950;                                                   % DNTC附近，东西方向 101,950m/1°E(longitude)

%% 
%经纬度转笛卡尔坐标系
[m,~]=size(data);
GPS_data=zeros(m-1,3);%y,x,z
for i = 1:m-1   
     GPS_data(i,1) = data(i,1)/longitude_step + original_GPS(2);
     GPS_data(i,2) = data(i,2)/latitude_step + original_GPS(1);
end



for i = 1:size(GPS_data,1)
    fprintf(fileID,'%4.15f,%4.15f\n',GPS_data(i,1),GPS_data(i,2));
end
fclose(fileID);
end

