%% 获取直线最终坐标
function [x_f,y_f,hdg] = CoorGetFinalLine(mGeo,mlength)
     dx = mlength * cos(mGeo.hdg);
     dy = mlength * sin(mGeo.hdg);
     x_f = mGeo.x + dx;
     y_f = mGeo.y + dy;
     hdg = mGeo.hdg;
end
