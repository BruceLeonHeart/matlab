function msgResult = getGeoByLaneSection(Roadobj,laneSection_S)
%通过laneSection的S坐标找到对应的Geo
msgResult = struct();
    geoList = Roadobj.planView.geometry;
    for i =1:length(geoList)
        crtGeo = getSingleObject(geoList,i);
        msg = getMsgFromGeo(crtGeo);
        if abs(msg.s - laneSection_S) < 1e-3
            msg.id  = i;  %从上一个开始到i
            msgResult = msg;
            break;
        end
    end
end

