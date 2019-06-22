function pathList = PlotPath(ax0,mPath,startPoint,endPoint,openDriveObj)
global ax;
ax = ax0;
roadObj = openDriveObj.road;
%在地图上显示算法规划出的路径
m = size(mPath,1);
pathList = [];




if startPoint.roadNum == endPoint.roadNum && startPoint.direction == endPoint.direction && m == 1 %起点终点处于同一道路同方向
    if startPoint.geoNum == endPoint.geoNum %处于同一直线段
    
    else % 处于不同直线段
    
    end

end


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
    laneSectionList = mRoadObj.lanes.laneSection;
    [Geos,laneSections,laneSecMap] = OpenDriveUnitGeoLane(mRoadObj);

    %车道线基于参考线
    %laneSection中的每一个s至少对应一个geo
    %即对任意的一个laneSection，与geo的关系是一对一或者一对多
    %构建对应关系结构体   
    for j =1:length(laneSecMap)
        crtLaneSec = getSingleObject(laneSectionList,j);
        startGeo = laneSecMap(j).startGeoNum;
        endGeo = laneSecMap(j).endGeoNum;
        for j1 = 1:length(laneSections)
            if laneSections(j1).s == str2double(crtLaneSec.Attributes.s)&& strcmp(laneSections(j1).type,'driving') && laneSections(j1).id == direction
                mLaneSection = laneSections(j1);
                for j2 = startGeo:endGeo
                    mGeo = Geos(j2);
                    if mGeo.lineType == "line"
                        linemsg = CoorGetLineSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mLaneSection.offset,sign(mLaneSection.id));
                        tempPlot = [tempPlot;line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'lineWidth',5,'color','b')];                         
                    end

                    if mGeo.lineType == "arc"
                        arcmsg = CoorGetArcSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvature,mLaneSection.offset,sign(mLaneSection.id),100);
                        tempPlot = [tempPlot;plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b')];
                    end

                    if mGeo.lineType == "spiral"
                        spiralmsg = CoorGetSpiralSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvStart,mGeo.curvEnd,mLaneSection.offset,sign(mLaneSection.id),100);
                        tempPlot = [tempPlot;plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b')];
                    end
                end
            end
        end
    end     
end


%补充绘制 startPoint和endPoint所在的车道之间的车道
function tempPlot1 = plotLanebetweenStartAndEnd(ax,mRoadObj,startPoint,endPoint)
    tempPlot1 = [];
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;    
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
            tempPlotRes = plotByPointAndGeo(startPoint,geomsg);
            tempPlot1 = [tempPlot1;tempPlotRes];
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
            tempPlotRes = plotByPointAndGeo(Point,geomsg);
            tempPlot1 = [tempPlot1;tempPlotRes];
        end
    end
  
end
%%根据点信息以及geo信息进行绘制
function tempPlotRes = plotByPointAndGeo(Point,geomsg)
    global ax;
    tempPlotRes = [];
    if geomsg.lineType == "line"
        linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,Point.offset,Point.direction);
        tempPlotRes = line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'lineWidth',5,'color','b');  
    end

    if geomsg.lineType == "arc"
        arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,Point.offset,Point.direction,100);
        tempPlotRes = plot(ax,arcmsg.xs,arcmsg.ys,'lineWidth',5,'color','b');
    end

    if geomsg.lineType == "spiral"
        spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,Point.offset,Point.direction,100);
        tempPlotRes = plot(ax,spiralmsg.xs,spiralmsg.ys,'lineWidth',5,'color','b');
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
