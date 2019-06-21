function [mGeos,mOffsets] = OpenDriveParser(crtRoadobj)
%以S为坐标系横向解析路
    mGeos = OpenDriveRoadGeo(crtRoadobj);
    mOffsets = OpenDriveRoadLaneSec(crtRoadobj);

end


%%解析道路参考线几何信息
function Geos = OpenDriveRoadGeo(mRoadObj)
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    Geos = struct('s',[],'x',[],'y',[],'hdg',[],'mlength',[],'lineType',[],'curvature',[],'curvStart',[],'curvEnd',[]);
    for m = 1:tempGeoListSize     
        crtmsg = OpenDriveGetGeoMsg(getSingleObject(tempGeoList,m));
        Geos(m) = crtmsg;
    end
end

%%解析道路(S,laneid)与offset关系
function Offsets = OpenDriveRoadLaneSec(mRoadObj)
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    Offsets = struct('idx',[],'s',[],'id',[],'type',[],'offset',[]);
    i = 1;
    for m = 1:laneSectionListSize     
        crtmsg = OpenDriveGetLaneOffset(getSingleObject(laneSectionList,m),m);
        for n = 1:length(crtmsg)
            Offsets(i) = crtmsg(n);
            i = i+1;
        end
    end
end

%解析道路S的参考线属性
