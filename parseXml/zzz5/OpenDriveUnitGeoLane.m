function laneGeoMap = OpenDriveUnitGeoLane(mRoadObj)
%通过laneSection的S坐标找到对应的Geo
%建立laneSection与geo的连接关系
 %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    
    % 找到laneSection与Geo的对应关系
    laneSectionRange = [];
    for n = 1:laneSectionListSize
        temp_laneSection = getSingleObject(laneSectionList,n);
        temp_laneSection_S = str2double(temp_laneSection.Attributes.s);
     
        msgResult = struct();
        for i =1:length(tempGeoList)
            crtGeo = getSingleObject(tempGeoList,i);
            msg = OpenDriveGetGeoMsg(crtGeo);
            if abs(msg.s - temp_laneSection_S) < 1e-3
                msg.id  = i;  %从上一个开始到i
                msgResult = msg;
                break;
            end
        end
        laneSectionRange = [laneSectionRange,msgResult.id];
    end 
    if ~ismember(tempGeoListSize,laneSectionRange)
        laneSectionRange = [laneSectionRange,tempGeoListSize];
    end
    
   %%建立结构体记录对应关系
   laneGeoMap = struct();
    if laneSectionRange(end) == 1
        laneGeoMap.id =  1;
        laneGeoMap.geo = 1;
    else
        lsrSize = size(laneSectionRange,2);
        for k = 1:lsrSize            
            laneGeoMap(k).id = laneSectionRange(k);
            if k < lsrSize
                laneGeoMap(k).geo = laneSectionRange(k):laneSectionRange(k+1)-1;
            else
                laneGeoMap(k).geo = laneSectionRange(k):laneSectionRange(end);
            end
        end
    end    
end