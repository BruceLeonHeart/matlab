close all;clear
%% Copyright@https://www.jianshu.com/u/1f9b23cfe862

density = 0.2;
Grid_X = 0:density:10;
Grid_Y = 0:density:10;
Basic_Z = ones(length(Grid_X), length(Grid_Y));

P0 = 20;
a = 20; %斥力影响因素
b = 10; %引力影响因素
%%
Goal = [10,10]; %目标
Obs = [3,2;
            3,3;
             5,7;
             5.3,6;
             6,6;
             2,4;
             3,8;
             4,7;
             8,9]; %障碍物坐标
         for k1 = 1: length(Grid_X)
             for k2 =1:length(Grid_Y)
                 X_c = Grid_X(k1);
                 Y_c = Grid_Y(k2);
                 rre =[];                 
                 rat = sqrt((Goal(1)-X_c)^2 +(Goal(2)-Y_c)^2);                 
                 Y_rre = [];
                 Y_ata = [];               
                 for k3 = 1:length(Obs)
                     rre(k3) =    sqrt((Obs(k3,1)-X_c)^2 +(Obs(k3,2)-Y_c)^2);
                     Y_rre(k3) = a*(1/rre(k3)  - 1/P0 ) *1/(rre(k3)^2); %基本斥力场公式                     
                     if  isinf(Y_rre(k3))==1|| Y_rre(k3)>150 %为显示效果做的限制处理
                         Y_rre = 150;
                     end                     
                 end
                Y_ata = b*rat; %基本引力场公式，注意这里引力只有一个值
                 Field_rre(k1,k2) = sum(Y_rre);
                 Field_ata(k1,k2) =  Y_ata;
             end
         end

SUM = Field_rre  + Field_ata;
surf(Grid_X,Grid_Y,SUM) %总力场