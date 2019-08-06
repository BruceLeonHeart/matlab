function pathList = PlotPath(ax0,mPath,startPoint,endPoint,openDriveObj)
global ax;
ax = ax0;
roadObj = openDriveObj.road;
%在地图上显示算法规划出的路径
m = size(mPath,1);
pathList = [];

if m == 1%同一ROAD 同direction
    mRoadobj = getRoadobjById(roadObj,mPath(1,1));
    [mGeos,mOffsets] = OpenDriveParser(mRoadobj);
    RoadGeoEnd =  mGeos(end).s + mGeos(end).mlength;
    direction = sign(mPath(1,2));
    start_s = startPoint.s_inGeo;
    end_s =  endPoint.s_inGeo;
    tempPath = plotpathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);  
    pathList  = tempPath;
    return;
end



if m >= 2
    for i = 1:m
         mRoadobj = getRoadobjById(roadObj,mPath(i,1));
         [mGeos,mOffsets] = OpenDriveParser(mRoadobj);
         RoadGeoEnd =  mGeos(end).s + mGeos(end).mlength;
         direction = sign(mPath(i,2));
         
         if i == m %起始段
             start_s = startPoint.s_inGeo;
             if direction == -1
                end_s = RoadGeoEnd;
             else
                end_s = 0;
             end
             tempPath = plotpathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);  
             pathList  = [tempPath;pathList];
         
        elseif i == 1%终止段      
            if direction == -1
                start_s = 0;
            else
                start_s = RoadGeoEnd;
            end
            end_s = endPoint.s_inGeo;
            tempPath = plotpathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);
            pathList  = [tempPath;pathList];          
        else %中间段
            if direction == -1
                start_s = 0;
                end_s = RoadGeoEnd;
            else
                start_s = RoadGeoEnd;
                end_s = 0;
            end
            tempPath = plotpathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);  
            pathList  = [pathList;tempPath];
                   
        end
    end
end
end

%%绘图
function tempPath = plotpathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s)
    global ax;
    delta_s = 0.5;
    x_set = [];
    y_set = [];
    sValueSet = start_s:(-direction)*delta_s:end_s;
    for j = 1:length(sValueSet)
        [x_s,y_s,hdg] = OpenDriveGetSXY(sValueSet(j),mGeos);
        %接下来的三行代码中，direction的位置应该为lane id这里因为行驶都为正负1就没有深究，后续需要考虑。
        offset = OpenDriveGetSOffset(sValueSet(j),direction,mOffsets,RoadGeoEnd);
        x = x_s + offset*cos(hdg + sign(direction)*pi/2);
        y = y_s + offset*sin(hdg + sign(direction)*pi/2);
        x_set = [x_set,x];
        y_set = [y_set,y];
    end
    tempPath  = plot(ax,x_set,y_set,'lineWidth',5,'color','b');
    
end



%%通过road id获取road实体
function mRoadobj = getRoadobjById(road,id)
    for n = 1:length(road)
        singleRoad = getSingleObject(road,n);
        if str2double(singleRoad.Attributes.id) == id
            mRoadobj = singleRoad;
            break;
        end
    end
end
