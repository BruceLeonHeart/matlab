function dataSet = AStarGetDataSet(mPath,startPoint,endPoint,openDriveObj)
%根据起止点信息结合路网生成点集
roadObj = openDriveObj.road;
%在地图上显示算法规划出的路径
m = size(mPath,1);
dataSet = [];

if m == 1%同一ROAD 同direction
    mRoadobj = getRoadobjById(roadObj,mPath(1,1));
    [mGeos,mOffsets] = OpenDriveParser(mRoadobj);
    RoadGeoEnd =  mGeos(end).s + mGeos(end).mlength;
    direction = sign(mPath(1,2));
    start_s = startPoint.s_inGeo;
    end_s =  endPoint.s_inGeo;
    [x_set, y_set]= getDatapathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);  
    dataSet  = [x_set,y_set];
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
             [x_set, y_set]= getDatapathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);
             dataSet  = [x_set,y_set;dataSet];
         
        elseif i == 1%终止段      
            if direction == -1
                start_s = 0;
            else
                start_s = RoadGeoEnd;
            end
            end_s = endPoint.s_inGeo;
            [x_set, y_set]= getDatapathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s);  
            dataSet  = [dataSet;x_set,y_set];         
        else %中间段
            if direction == -1
                start_s = 0;
                end_s = RoadGeoEnd;
            else
                start_s = RoadGeoEnd;
                end_s = 0;
            end
            [x_set, y_set]= getDatapathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s); 
            dataSet  = [x_set,y_set;dataSet];
                   
        end
    end
    return;
end


end
%%绘图
function [x_set, y_set]= getDatapathCommon(mGeos,mOffsets,RoadGeoEnd,direction,start_s,end_s)
    delta_s = 1;
    x_set = [];
    y_set = [];
    sValueSet = start_s:(-direction)*delta_s:end_s;
    temp = length(sValueSet);
    for j = 1:length(sValueSet)
        [x_s,y_s,hdg] = OpenDriveGetSXY(sValueSet(j),mGeos);
        %接下来的三行代码中，direction的位置应该为lane id这里因为行驶都为正负1就没有深究，后续需要考虑。
        offset = OpenDriveGetSOffset(sValueSet(j),direction,mOffsets,RoadGeoEnd);
        %取offset一半作为轨迹点
%         x = x_s + offset*cos(hdg + sign(direction)*pi/2)/2;
%         y = y_s + offset*sin(hdg + sign(direction)*pi/2)/2;
        
        x = x_s ;
        y = y_s ;
        %坐标置为列向量
        x_set = [x_set;x];
        y_set = [y_set;y];
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


