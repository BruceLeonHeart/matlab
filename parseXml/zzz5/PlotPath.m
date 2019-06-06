function pathList = PlotPath(ax,mPath,startPoint,endPoint,openDriveObj)
roadObj = openDriveObj.road;
%在地图上显示算法规划出的路径
m = size(mPath,1);
pathList = [];
%%当仅有一段时，表明终点就在起点前方，不更换车道
if m ==1
    pathList = line(ax,[startPoint.x_ref_offset,endPoint.x_ref_offset],[startPoint.y_ref_offset,endPoint.y_ref_offset],'lineWidth',5,'color','b');
    return;
end

%%一般情况
for i = 1:m
    if i == 1%end
        pathList =  [pathList;line(ax,[endPoint.x_ref_offset,endPoint.x_s_offset],[endPoint.y_ref_offset,endPoint.y_s_offset],'lineWidth',5,'color','b')];
    
    elseif i == m %start
        pathList =  [pathList;line(ax,[startPoint.x_ref_offset,startPoint.x_e_offset],[startPoint.y_ref_offset,startPoint.y_e_offset],'lineWidth',5,'color','b')];
    else
        tempPlot = plotRoadByDirection(ax,getRoadobjById(roadObj,mPath(i,1)),mPath(i,2));
        pathList = [pathList;tempPlot];
    end
    
end

end

function tempPlot = plotRoadByDirection(ax,mRoadObj,direction)
    tempPlot = [];
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);

    % 　绘制车道线
    % 找到laneSection与Geo的对应关系
    laneSectionRange = [];
    for n = 1:laneSectionListSize
        temp_laneSection = getSingleObject(laneSectionList,n);
        temp_laneSection_S = str2double(temp_laneSection.Attributes.s);
        msgResult = OpenDriveUnitGeoLane(mRoadObj,temp_laneSection_S);%车道的对应参考线信息
        laneSectionRange = [laneSectionRange,msgResult.id];
    end 
    if ~ismember(tempGeoListSize,laneSectionRange)
        laneSectionRange = [laneSectionRange,tempGeoListSize];
    end
   laneGeoMap = struct();
    if laneSectionRange(end) == 1
        laneGeoMap.id =1;
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
    %以laneSection为基准绘制下属的Geo区域
    for i0 = 1:length(laneGeoMap)
        crtlaneSection = laneGeoMap(i0).id;
        crtGeos = laneGeoMap(i0).geo;
        temp_laneSection = getSingleObject(laneSectionList,crtlaneSection);
        lanemsg = OpenDriveGetLaneSecMsg(temp_laneSection);%车道信息
        for i1 = 1:length(crtGeos)
            crtgeo = getSingleObject(tempGeoList,crtGeos(i1));
            geomsg = OpenDriveGetGeoMsg(crtgeo);
                for i2 = 1:size(lanemsg,1)
                    laneId = lanemsg(i2,1);
                    offset = lanemsg(i2,2);
                    if laneId == direction %%类似绘制整张地图(PlotMap)，这里舍弃了参考线的部分和不需要的车道部分
                    
                        if geomsg.lineType == "line"
                            linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,offset,sign(laneId));
                            tempPlot = [tempPlot;line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'lineWidth',5,'color','b')];  
                        end
                        
                        if geomsg.lineType == "arc"
                            arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId));
                            tempPlot = [tempPlot;plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b')];
                        end
                        
                        if geomsg.lineType == "spiral"
                            spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId));
                            tempPlot = [tempPlot;plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b')];
                        end
                    
                    end    
                end      
        end       
    end    
end

%%通过road id获取road实体
function mRoadobj = getRoadobjById(road,id)
    for i = 1:length(road)
        singleRoad = getSingleObject(road,i);
        if str2double(singleRoad.Attributes.id) == id
            mRoadobj = singleRoad;
            break;
        end
    end
end
