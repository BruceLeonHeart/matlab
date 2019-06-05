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