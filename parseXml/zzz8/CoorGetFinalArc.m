%% 圆弧通过起点计算终点坐标
function [x_f,y_f] = CoorGetFinalArc(x,y,hdg,mlength,curvature,offset,direction)
    origin_r = abs(1/curvature); %起始圆半径
    if direction == 0 %原始
        if curvature <= 0
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + origin_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + origin_r*(sin(theta-delta_theta) - sin(theta));
        else
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + origin_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + origin_r*(sin(theta+delta_theta) - sin(theta));
        end
    elseif direction == -1% right
        % 修改起始位置         
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        %顺时针时，右侧的圆半径减小;逆时针时，右侧的圆半径增大
        if curvature <= 0
            current_r = origin_r -offset;
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta-delta_theta) - sin(theta));            
        else
            current_r = origin_r +offset;
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta+delta_theta) - sin(theta));
        end      
    elseif direction == 1 %left
         % 修改起始位置
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        %顺时针时，左侧的圆半径增大;逆时针时，左侧的圆半径减小
        if curvature <= 0
            current_r = origin_r + offset;
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta-delta_theta) - sin(theta));
        else
            current_r = origin_r - offset;
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta+delta_theta) - sin(theta));
        end        
    end
end