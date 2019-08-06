%% 获取螺旋线最终坐标
function [x_f,y_f,hdg] = CoorGetFinalSpiral(mGeo,mlength)
    c = (mGeo.curvEnd - mGeo.curvStart)/mGeo.mlength;
    cosline = @(t)(cos(mGeo.hdg + mGeo.curvStart * t + c/2.0*t.^2));
    sinline = @(t)(sin(mGeo.hdg + mGeo.curvStart * t + c/2.0*t.^2));
    x_f = mGeo.x + integral(cosline,0,mlength);
    y_f = mGeo.y + integral(sinline,0,mlength);
    hdg = mGeo.hdg + mGeo.curvStart * mlength + c/2.0*mlength.^2;  
end 