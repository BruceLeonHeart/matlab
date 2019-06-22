%% 获取圆弧最终坐标
function [x_f,y_f,hdg] = CoorGetFinalArc(mGeo,mlength)
    origin_r = abs(1/mGeo.curvature); %起始圆半径
    if mGeo.curvature <= 0
        theta = mGeo.hdg + pi/2;
        delta_theta = mlength/origin_r;
        x_f = mGeo.x + origin_r*(cos(theta-delta_theta) - cos(theta));
        y_f = mGeo.y + origin_r*(sin(theta-delta_theta) - sin(theta));
        hdg = mGeo.hdg - delta_theta;
    else
        theta = mGeo.hdg - pi/2;
        delta_theta = mlength/origin_r;
        x_f = mGeo.x + origin_r*(cos(theta+delta_theta) - cos(theta));
        y_f = mGeo.y + origin_r*(sin(theta+delta_theta) - sin(theta));
        hdg = mGeo.hdg + delta_theta;
    end
end
