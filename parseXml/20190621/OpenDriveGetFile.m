function  OpenDriveGetFile(data)
fileID = fopen('/home/pz1_ad_04/桌面/1.txt','w');
for i = 1:size(data,1)
    fprintf(fileID,'%4.2f %4.2f\n',data(i,1),data(i,2));
end
fclose(fileID);
end

