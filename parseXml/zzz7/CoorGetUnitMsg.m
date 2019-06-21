%当前的laneSection从geos中寻找参考信息
function [idx,flag] = CoorGetUnitMsg(s,Geos)
    idx = 999;
    flag = 0;
    %抛出idx类型,flag = 1 端点抛出； flag = -1中间抛出
    for i = 1:length(Geos)
%         tempS_end = Geos(i).s + Geos(i).mlength;
        if abs( s - Geos(i).s) < 1e-3
            idx = i;
            flag = 1;
            return;
        end
    end
    
    for i = 1:length(Geos)
        tempS_end = Geos(i).s + Geos(i).mlength;
        if s >= Geos(i).s  && tempS_end > s
            idx = i;
            flag = -1;
            break;
        end
    end
    
    
end