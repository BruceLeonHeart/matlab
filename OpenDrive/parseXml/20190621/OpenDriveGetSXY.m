%%当前S值的x y hdg坐标
function [x,y,hdg] = OpenDriveGetSXY(s,Geo)
    x = -999;
    y = -999;
    hdg = -999;
    idx = length(Geo);
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

