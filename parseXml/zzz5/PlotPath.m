function pathList = PlotPath(ax,mPath,startPoint,endPoint,openDriveObj)
roadObj = openDriveObj.road;
%在地图上显示算法规划出的路径
m = size(mPath,1);
pathList = [];

%%同路同道同向
if startPoint.roadNum == endPoint.roadNum && startPoint.geoNum == endPoint.geoNum && startPoint.direction == endPoint.direction && m == 1   
    pathList =  line(ax,[startPoint.x_ref_offset,endPoint.x_ref_offset],[startPoint.y_ref_offset,endPoint.y_ref_offset],'lineWidth',5,'color','b');
    return;
end

%%同路不同道同向
if startPoint.roadNum == endPoint.roadNum && startPoint.geoNum ~= endPoint.geoNum && startPoint.direction == endPoint.direction
    mRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPath = line(ax,[startPoint.x_ref_offset,startPoint.x_e_offset],[startPoint.y_ref_offset,startPoint.y_e_offset],'lineWidth',5,'color','b');
    endPath = line(ax,[endPoint.x_ref_offset,endPoint.x_s_offset],[endPoint.y_ref_offset,endPoint.y_s_offset],'lineWidth',5,'color','b');
    tempPlot1 = plotRoadByCondition1(ax,mRoadObj,startPoint,endPoint);
    pathList = [startPath;tempPlot1;endPath];
    return;
end

%%其他情形
if m == 2
    startRoadObj = getRoadobjById(roadObj,mPath(2,1));
    endRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPath = line(ax,[startPoint.x_ref_offset,startPoint.x_e_offset],[startPoint.y_ref_offset,startPoint.y_e_offset],'lineWidth',5,'color','b');
    endPath = line(ax,[endPoint.x_ref_offset,endPoint.x_s_offset],[endPoint.y_ref_offset,endPoint.y_s_offset],'lineWidth',5,'color','b');
    tempPlot1 = plotRoadByCondition2(ax,startRoadObj,startPoint,1);
    tempPlot2 = plotRoadByCondition2(ax,endRoadObj,endPoint,2);
    pathList = [startPath;tempPlot1;tempPlot2;endPath];
    
elseif m > 2
    startRoadObj = getRoadobjById(roadObj,mPath(2,1));
    endRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPath = line(ax,[startPoint.x_ref_offset,startPoint.x_e_offset],[startPoint.y_ref_offset,startPoint.y_e_offset],'lineWidth',5,'color','b');
    endPath = line(ax,[endPoint.x_ref_offset,endPoint.x_s_offset],[endPoint.y_ref_offset,endPoint.y_s_offset],'lineWidth',5,'color','b');
    tempPlot1 = plotRoadByCondition2(ax,startRoadObj,startPoint,1);
    tempPlot2 = plotRoadByCondition2(ax,endRoadObj,endPoint,2);
    others = [];
    for i = 2:m-1
        tempPlot = plotRoadByDirection(ax,getRoadobjById(roadObj,mPath(i,1)),mPath(i,2));
        others = [tempPlot;others];
    end
    pathList = [startPath;tempPlot1;others;tempPlot2;endPath];
    return;
end
end


%绘制完整路段
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
    laneGeoMap = OpenDriveUnitGeoLane(mRoadObj);

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
                            arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId),100);
                            tempPlot = [tempPlot;plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b')];
                        end
                        
                        if geomsg.lineType == "spiral"
                            spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId),100);
                            tempPlot = [tempPlot;plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b')];
                        end
                    
                    end    
                end      
        end       
    end    
end


%绘制同路同向不同道
function tempPlot1 = plotRoadByCondition1(ax,mRoadObj,startPoint,endPoint)
    tempPlot1 = [];
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);     
    if tempGeoListSize == 1%处理同一直线段的特殊情况
        return;
    else
        %起始段到终止段之间的情况
        if startPoint.direction == -1 %同向
            startGeoNum = startPoint.geoNum + 1;
            endGeoNum = endPoint.geoNum - 1;        
        end
        
        if startPoint.direction == 1 %反向
            endGeoNum = startPoint.geoNum - 1;
            startGeoNum = endPoint.geoNum + 1;
        end  
        
       for i = startGeoNum : endGeoNum
            crtgeo = getSingleObject(tempGeoList,i);
            geomsg = OpenDriveGetGeoMsg(crtgeo);
            if geomsg.lineType == "line"
                linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,startPoint.offset,startPoint.direction);
                tempPlot1 = [tempPlot1;line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'lineWidth',5,'color','b')];  
            end

            if geomsg.lineType == "arc"
                arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,startPoint.offset,startPoint.direction,100);
                tempPlot1 = [tempPlot1;plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b')];
            end

            if geomsg.lineType == "spiral"
                spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,startPoint.offset,startPoint.direction,100);
                tempPlot1 = [tempPlot1;plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b')];
            end
        end
    end
  
end

%绘制不同道
function tempPlot1 = plotRoadByCondition2(ax,mRoadObj,Point,flag)
%flag = 1表示起点方向
%flag = 2表示终点方向
    tempPlot1 = [];
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);      
    if tempGeoListSize == 1%处理同一直线段的特殊情况
        return;
    else
        %起始段到终止段之间的情况
        if flag == 1 && Point.direction == -1 %同向
            startGeoNum = Point.geoNum + 1;
            endGeoNum = tempGeoListSize;
        elseif flag == 2 && Point.direction == -1 %同向
            startGeoNum =  1;
            endGeoNum = Point.geoNum - 1;
        elseif flag == 1 && Point.direction == 1 %反向
            startGeoNum =  1;
            endGeoNum = Point.geoNum - 1;
        elseif flag == 2 && Point.direction == 1 %反向
            startGeoNum = Point.geoNum + 1;
            endGeoNum = tempGeoListSize;
        end
 
        
       for i = startGeoNum : endGeoNum
            crtgeo = getSingleObject(tempGeoList,i);
            geomsg = OpenDriveGetGeoMsg(crtgeo);
            if geomsg.lineType == "line"
                linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,Point.offset,Point.direction);
                tempPlot1 = [tempPlot1;line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'lineWidth',5,'color','b')];  
            end

            if geomsg.lineType == "arc"
                arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,Point.offset,Point.direction,100);
                tempPlot1 = [tempPlot1;plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b')];
            end

            if geomsg.lineType == "spiral"
                spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,Point.offset,Point.direction,100);
                tempPlot1 = [tempPlot1;plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b')];
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
