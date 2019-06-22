function  point = OpenDrivePointBelong(openDriveObj,pointX,pointY)
    point = struct('RoadIdx',[],'GeoIdx',[],'direction',[],'x',[],'y',[],'s',[],'s_start',[],'s_end',[],'x_offset',[],'y_offset',[],'offset',[]);
    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    disList = [];
    for RoadIdx = 1:roadNum %roadNum是道路顺序号
         crtRoad = roadObj{1,RoadIdx};
        if crtRoad.Attributes.junction == "-1"%不考虑落在junction上的情况
            [mGeos,mOffsets] = OpenDriveParser(crtRoad);
            RoadGeoEnd = mGeos(end).s + mGeos(end).mlength;
            for GeoIdx = 1 :length(mGeos)
                mGeo =  mGeos(GeoIdx);
                if strcmp(mGeo.lineType,'line')
                    
                    s_start = mGeo.s; %本段几何起始s值
                    s_end = mGeo.s + mGeo.mlength; %本段几何终止s值
                    hdg = mGeo.hdg; %本直线段参考方向角
                    Geo_x_start = mGeo.x; 
                    Geo_y_start = mGeo.y;
                    Geo_x_end = Geo_x_start + mGeo.mlength*cos(hdg);
                    Geo_y_end = Geo_y_start + mGeo.mlength*sin(hdg);
                    [v,x,y] = CoorGetCrossMsg(Geo_x_start,Geo_y_start,hdg,pointX,pointY); %与参考线的交点，距离
                        % 不落在线段上应该舍弃
                    flag1= (x<=max(Geo_x_start,Geo_x_end))&&(x>=min(Geo_x_start,Geo_x_end));
                    flag2= (y<=max(Geo_y_start,Geo_y_end))&&(y>=min(Geo_y_start,Geo_y_end));
                    if ~(flag1&&flag2)
                        continue;
                    end
                  
                    s = s_start + CoorGetDis(x,y,Geo_x_start,Geo_y_start);%交点的s坐标
                    direction  =  CoorSideJudge(Geo_x_start,Geo_y_start,Geo_x_end,Geo_y_end,pointX,pointY);%判断点落在参考线的某一侧
                    offset = OpenDriveGetSOffset(s,direction,mOffsets,RoadGeoEnd);  
                    x_offset = x + offset * cos(hdg  + direction*pi/2); %偏移后
                    y_offset = y + offset * sin(hdg  + direction*pi/2); %偏移后              
                    disList = [disList;abs(v),RoadIdx,GeoIdx,direction,x,y,s,s_start,s_end,x_offset,y_offset,offset];               
                end             
            end          
        end  
    end
        disList= sortrows(disList,1);  
        point.RoadIdx = disList(1,2);
        point.GeoIdx = disList(1,3);
        point.direction = disList(1,4);
        point.x = disList(1,5);
        point.y = disList(1,6);
        point.s = disList(1,7);
        point.s_start = disList(1,8);
        point.s_end = disList(1,9);
        point.x_offset = disList(1,10);
        point.y_offset = disList(1,11);
        point.offset = disList(1,12);

end
