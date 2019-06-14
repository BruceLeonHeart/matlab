function dataSet = AStarGetDataSet(mPath,startPoint,endPoint,openDriveObj)
%根据起止点信息结合路网生成点集

roadObj = openDriveObj.road;
delta_s = 1; %参考线间距为1m进行打点


%在地图上显示算法规划出的路径
m = size(mPath,1);
dataSet = [];

%%同路同道同向
if startPoint.roadNum == endPoint.roadNum && startPoint.geoNum == endPoint.geoNum && startPoint.direction == endPoint.direction && m == 1 
    start_s = startPoint.s_e;%起点s
    end_s = endPoint.s_e;%终点s
    
    %起止点中心线
    x_middle_start = (startPoint.x_ref_offset + startPoint.x_ref)/2;
    y_middle_start = (startPoint.y_ref_offset + startPoint.y_ref)/2;
    x_middle_end = (endPoint.x_ref_offset + endPoint.x_ref)/2;
    y_middle_end = (endPoint.y_ref_offset + endPoint.y_ref)/2;
    x_dataset = linspace(x_middle_start,x_middle_end,abs(end_s - start_s)/delta_s);
    y_dataset = linspace(y_middle_start,y_middle_end,abs(end_s - start_s)/delta_s);
    dataSet = [x_dataset' y_dataset'];
    return; 
end


%%同路不同道同向
if startPoint.roadNum == endPoint.roadNum && startPoint.geoNum ~= endPoint.geoNum && startPoint.direction == endPoint.direction
    mRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPathData = getDataByStartPoint(startPoint,delta_s);
    endPathData = getDataByEndPoint(endPoint,delta_s);
    tempPlot1 = getDataByCondition1(mRoadObj,startPoint,endPoint,delta_s);
    dataSet = [startPathData;tempPlot1;endPathData];
    return;
end

%%其他情形
if m == 2
    startRoadObj = getRoadobjById(roadObj,mPath(2,1));
    endRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPathData = getDataByStartPoint(startPoint,delta_s);
    endPathData = getDataByEndPoint(endPoint,delta_s);
    tempPlot1 = getDataByCondition2(startRoadObj,startPoint,1,delta_s);
    tempPlot2 = getDataByCondition2(endRoadObj,endPoint,2,delta_s);
    dataSet = [startPathData;tempPlot1;tempPlot2;endPathData];
    return;
elseif m > 2
    startRoadObj = getRoadobjById(roadObj,mPath(2,1));
    endRoadObj = getRoadobjById(roadObj,mPath(1,1));
    startPathData = getDataByStartPoint(startPoint,delta_s);
    endPathData = getDataByEndPoint(endPoint,delta_s);
    tempPlot1 = getDataByCondition2(startRoadObj,startPoint,1,delta_s);
    tempPlot2 = getDataByCondition2(endRoadObj,endPoint,2,delta_s);
    others = [];
    for i = 2:m-1
        tempPlot = getDataByDirection(getRoadobjById(roadObj,mPath(i,1)),mPath(i,2),delta_s);
        others = [tempPlot;others];
    end
    dataSet = [startPathData;tempPlot1;others;tempPlot2;endPathData];
    return;
end

end

%获取完整路段数据集
function data = getDataByDirection(mRoadObj,direction,delta_s)
    data = [];
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
                        x_dataset = linspace(linemsg.x,linemsg.x+linemsg.dx,ceil(mGeo.mlength/delta_s));
                        y_dataset = linspace(linemsg.y,linemsg.y+linemsg.dy,ceil(mGeo.mlength/delta_s));
                        if  direction == -1
                            data = [data;x_dataset' y_dataset'];
                        else
                            data = [fliplr(x_dataset)' fliplr(y_dataset)';data];
                        end                        
                    end

                    if mGeo.lineType == "arc"
                        arcmsg = CoorGetArcSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvature,mLaneSection.offset,sign(mLaneSection.id),ceil(mGeo.mlength/delta_s));
                        if  direction == -1
                            data = [data;arcmsg.xs' arcmsg.ys'];
                        else
                            data = [fliplr(arcmsg.xs)' fliplr(arcmsg.ys)';data];
                        end
                    end

                    if mGeo.lineType == "spiral"
                        spiralmsg = CoorGetSpiralSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvStart,mGeo.curvEnd,mLaneSection.offset,sign(mLaneSection.id),ceil(mGeo.mlength/delta_s));
                        if  direction == -1
                            data = [data;spiralmsg.xs' spiralmsg.ys'];
                        else
                            data = [fliplr(spiralmsg.xs)' fliplr(spiralmsg.ys)';data];
                        end
                    end
                end
            end
        end
    end         
end


%获取同路同向不同道数据集
function data = getDataByCondition1(mRoadObj,startPoint,endPoint,delta_s)
    data = [];
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
                x_dataset = linspace(linemsg.x,linemsg.x+linemsg.dx,ceil(geomsg.mlength/delta_s));
                y_dataset = linspace(linemsg.y,linemsg.y+linemsg.dy,ceil(geomsg.mlength/delta_s));
                if  startPoint.direction == -1
                    data = [data;x_dataset' y_dataset'];
                else
                    data = [fliplr(x_dataset)' fliplr(y_dataset)';data];
                end
            end

            if geomsg.lineType == "arc"
                arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,startPoint.offset,startPoint.direction,ceil(geomsg.mlength/delta_s));
                if  startPoint.direction == -1
                    data = [data;arcmsg.xs' arcmsg.ys'];
                else
                    data = [fliplr(arcmsg.xs)' fliplr(arcmsg.ys)';data];
                end
            end

            if geomsg.lineType == "spiral"
                spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,startPoint.offset,startPoint.direction,ceil(geomsg.mlength/delta_s));
                    if  startPoint.direction == -1
                        data = [data;spiralmsg.xs' spiralmsg.ys'];
                    else
                        data = [fliplr(spiralmsg.xs)' fliplr(spiralmsg.ys)';data];
                    end
            end
        end
    end
  
end

%获取不同道路数据集
function data = getDataByCondition2(mRoadObj,Point,flag,delta_s)
%flag = 1表示起点方向
%flag = 2表示终点方向
    data = [];
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
                x_dataset = linspace(linemsg.x,linemsg.x+linemsg.dx,ceil(geomsg.mlength/delta_s));
                y_dataset = linspace(linemsg.y,linemsg.y+linemsg.dy,ceil(geomsg.mlength/delta_s));
                if  Point.direction == -1
                    data = [data;x_dataset' y_dataset'];
                else
                    data = [fliplr(x_dataset)' fliplr(y_dataset)';data];
                end
            end

            if geomsg.lineType == "arc"
                arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,Point.offset,Point.direction,ceil(geomsg.mlength/delta_s));
                if  Point.direction == -1
                    data = [data;arcmsg.xs' arcmsg.ys'];
                else
                    data = [fliplr(arcmsg.xs)' fliplr(arcmsg.ys)';data];
                end
            end

            if geomsg.lineType == "spiral"
                spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,Point.offset,Point.direction,ceil(geomsg.mlength/delta_s));
                    if  Point.direction == -1
                        data = [data;spiralmsg.xs' spiralmsg.ys'];
                    else
                        data = [fliplr(spiralmsg.xs)' fliplr(spiralmsg.ys)';data];
                    end
            end
        end
    end
  
end


%获取起始段的数据集
function data = getDataByStartPoint(startPoint,delta_s)
    x_middle_start = (startPoint.x_ref_offset + startPoint.x_ref)/2;
    y_middle_start = (startPoint.y_ref_offset + startPoint.y_ref)/2;
    if startPoint.direction == -1
        x_middle_end = (startPoint.x_e_offset + startPoint.x_e)/2;
        y_middle_end = (startPoint.y_e_offset + startPoint.y_e)/2;
    else
        x_middle_end = (startPoint.x_e_offset + startPoint.x_s)/2;
        y_middle_end = (startPoint.y_e_offset + startPoint.y_s)/2;
    end
    s_length = max(abs(x_middle_end - x_middle_start),abs(y_middle_end - y_middle_start));
    x_dataset = linspace(x_middle_start,x_middle_end,s_length/delta_s);
    y_dataset = linspace(y_middle_start,y_middle_end,s_length/delta_s);
    data = [x_dataset' y_dataset'];
end

%获取结束段的数据集
function data = getDataByEndPoint(endPoint,delta_s)
    x_middle_end = (endPoint.x_ref_offset + endPoint.x_ref)/2;
    y_middle_end = (endPoint.y_ref_offset + endPoint.y_ref)/2;
    if endPoint.direction == -1
        x_middle_start = (endPoint.x_s_offset + endPoint.x_s)/2;
        y_middle_start = (endPoint.y_s_offset + endPoint.y_s)/2;
    else
        x_middle_start = (endPoint.x_s_offset + endPoint.x_e)/2;
        y_middle_start = (endPoint.y_s_offset + endPoint.y_e)/2;
    end
    s_length = max(abs(x_middle_end - x_middle_start),abs(y_middle_end - y_middle_start));
    x_dataset = linspace(x_middle_start,x_middle_end,s_length/delta_s);
    y_dataset = linspace(y_middle_start,y_middle_end,s_length/delta_s);
    data = [x_dataset' y_dataset'];

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


