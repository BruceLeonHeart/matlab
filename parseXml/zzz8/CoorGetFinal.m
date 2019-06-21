function [x_f,y_f] = CoorGetFinal(lineMsg,offset,direction)
x = lineMsg.x;
y = lineMsg.y;
hdg = lineMsg.hdg;
mlength = lineMsg.mlength;
if strcmp(lineMsg.lineType,'line')
    [x_f,y_f] = CoorGetFinalLine(x,y,hdg,mlength,offset,direction);
elseif strcmp(lineMsg.lineType,'arc')
    [x_f,y_f] = CoorGetFinalArc(x,y,hdg,mlength,curvature,offset,direction);
elseif strcmp(lineMsg.lineType,'spiral')
    [x_f,y_f] = CoorGetFinalSpiral(x,y,hdg,mlength,cvstart,cvend,offset,direction);
else
     x_f = -9999;
     y_f = -9999;  
end

end

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

%% 螺旋线通过起点计算终点坐标
function [x_f,y_f] = CoorGetFinalSpiral(x,y,hdg,mlength,cvstart,cvend,offset,direction)
    c = (cvend - cvstart)/mlength;
    cosline = @(mlength)(cos(hdg + cvstart * mlength + c/2.0*mlength.^2));
    sinline = @(mlength)(sin(hdg + cvstart * mlength + c/2.0*mlength.^2));
    x_f = x + integral(cosline,0,mlength);
    y_f = y + integral(sinline,0,mlength);
    if direction == 0     
    elseif direction == -1
        x_f = x_f + offset*cos(hdg + cvstart * mlength + c/2.0*mlength.^2 -pi/2);
        y_f = y_f + offset*sin(hdg + cvstart * mlength + c/2.0*mlength.^2 -pi/2);
    elseif direction == 1
        x_f = x_f + offset*cos(hdg + cvstart * mlength + c/2.0*mlength.^2 +pi/2);
        y_f = y_f + offset*sin(hdg + cvstart * mlength + c/2.0*mlength.^2 +pi/2);
    end
    
end 