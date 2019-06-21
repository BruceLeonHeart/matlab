%%当前S值的x y hdg坐标
function [x,y,hdg] = OpenDriveGetSXY(s,Geo)
    x = -999;
    y = -999;
    hdg = -999;
    idx = 1;
    for i = 1:length(Geo)
        if s >= Geo(i).s && s < Geo(i).s + Geo(i).mlength
            idx = i;
            break;
        end
    end 
    mlength = s - Geo(i).s;
    if strcmp(Geo(idx).lineType,'line')
        [x,y,hdg] = CoorGetFinalLine(Geo(idx),mlength);
    end
    if strcmp(Geo(idx).lineType,'arc')
        [x,y,hdg] = CoorGetFinalArc(Geo(idx),mlength);
    end
    if strcmp(Geo(idx).lineType,'spiral')
        [x,y,hdg] = CoorGetFinalSpiral(Geo(idx),mlength);
    end
end

%% 获取直线最终坐标
function [x_f,y_f,hdg] = CoorGetFinalLine(mGeo,mlength)
     dx = mlength * cos(mGeo.hdg);
     dy = mlength * sin(mGeo.hdg);
     x_f = mGeo.x + dx;
     y_f = mGeo.y + dy;
     hdg = mGeo.hdg;
end

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

%% 获取螺旋线最终坐标
function [x_f,y_f,hdg] = CoorGetFinalSpiral(mGeo,mlength)
    c = (mGeo.curvEnd - mGeo.curvStart)/mGeo.mlength;
    cosline = @(t)(cos(mGeo.hdg + mGeo.curvStart * t + c/2.0*t.^2));
    sinline = @(t)(sin(mGeo.hdg + mGeo.curvStart * t + c/2.0*t.^2));
    x_f = mGeo.x + integral(cosline,0,mlength);
    y_f = mGeo.y + integral(sinline,0,mlength);
    hdg = mGeo.hdg + mGeo.curvStart * mlength + c/2.0*mlength.^2;  
end 
