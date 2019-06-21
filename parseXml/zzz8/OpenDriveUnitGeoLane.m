function [Geos,laneSections,laneSecMap] = OpenDriveUnitGeoLane(mRoadObj)
    %%将geo与laneSection分别做成结构体进行记录   
    %　参考线部分
    
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    Geos = struct('s',[],'x',[],'y',[],'hdg',[],'mlength',[],'lineType',[],'curvature',[],'curvStart',[],'curvEnd',[]);
    for m = 1:tempGeoListSize     
        crtmsg = OpenDriveGetGeoMsg(getSingleObject(tempGeoList,m));
        Geos(m) = crtmsg;
    end 
    
     %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    laneSections = struct('idx',[],'laneSecIdx',[],'s',[],'id',[],'type',[],'offset',[],'speed',[],'s_end',[]);
    k = 1;
    for n = 1:laneSectionListSize
        laneSectionsMsg = OpenDriveGetLaneSecMsg1(getSingleObject(laneSectionList,n));
        
        for n1 = 1 :length(laneSectionsMsg)
            laneSections(k) = laneSectionsMsg(n1);
            laneSections(k).idx = k; %将同一Road的laneSection信息汇总，并修改idx的表达
            laneSections(k).laneSecIdx = n;
            k = k + 1;
        end
    end
    
    %对应关系
    laneSecMap = struct('laneSecIdx',[],'startGeoNum',[],'endGeoNum',[]);
    for i = 1 :laneSectionListSize
        crtlaneSec = getSingleObject(laneSectionList,i);
        s = str2double(crtlaneSec.Attributes.s);
        laneSecMap(i).laneSecIdx = i;
        laneSecMap(i).startGeoNum = CoorGetUnitMsg(s,Geos);
        laneSecMap(i).endGeoNum = tempGeoListSize;
        if i + 1 <=laneSectionListSize
            nextlaneSec = getSingleObject(laneSectionList,i+1);
            s1 = str2double(nextlaneSec.Attributes.s);
            [nextStartGeoNum ,nextFlag] =  CoorGetUnitMsg(s1,Geos);
            if  nextStartGeoNum == tempGeoListSize && tempGeoListSize ==1
                laneSecMap(i).endGeoNum = tempGeoListSize;
            elseif nextStartGeoNum == laneSecMap(i).startGeoNum || nextFlag == -1
                laneSecMap(i).endGeoNum = nextStartGeoNum;
            else
                laneSecMap(i).endGeoNum = nextStartGeoNum - 1;
            end
        end
    end
    
end