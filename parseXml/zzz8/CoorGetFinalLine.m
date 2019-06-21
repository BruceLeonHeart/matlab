%% 直线通过起点计算终点坐标
function [x_f,y_f] = CoorGetFinalLine(x,y,hdg,mlength,offset,direction)
     dx = mlength * cos(hdg);
     dy = mlength * sin(hdg);
    %% 原始参考线
     if direction == 0
        x_f = x + dx;
        y_f = y + dy;

    %% 右侧 基于s方向顺时针旋转
     elseif direction == -1 
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        x_f = x + dx;
        y_f = y + dy;
    %% 左侧 基于s方向逆时针旋转
     elseif  direction == 1
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        x_f = x + dx;
        y_f = y + dy;

     end
end