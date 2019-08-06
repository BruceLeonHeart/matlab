function  point = OpenDrivePointBelong(openDriveObj,pointX,pointY)
    point = struct();
    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    disList = [];
    for RoadIdx = 1:roadNum %roadNum是道路顺序号
         crtRoad = roadObj{1,RoadIdx};
         RoadNum = str2double(crtRoad.Attributes.id);
        if crtRoad.Attributes.junction == "-1"%不考虑落在junction上的情况
            [mGeos,mOffsets] = OpenDriveParser(crtRoad);
            RoadGeoEnd = mGeos(end).s + mGeos(end).mlength;
            for GeoIdx = 1 :length(mGeos)
                mGeo =  mGeos(GeoIdx);
                if strcmp(mGeo.lineType,'line')
                    
                    Geo_s = mGeo.s;
                    Geo_s_end = mGeo.s + mGeo.mlength;
                    Geo_x_start = mGeo.x;
                    Geo_y_start = mGeo.y;
                    Geo_x_end = Geo_x_start + mGeo.mlength*cos(mGeo.hdg);
                    Geo_y_end = Geo_y_start + mGeo.mlength*sin(mGeo.hdg);
                    [v,x,y] = CoorGetCrossMsg(Geo_x_start,Geo_y_start,mGeo.hdg,pointX,pointY); %与参考线的交点，距离
                        % 不落在线段上应该舍弃
                    flag1= (x<=max(Geo_x_start,Geo_x_end))&&(x>=min(Geo_x_start,Geo_x_end));
                    flag2= (y<=max(Geo_y_start,Geo_y_end))&&(y>=min(Geo_y_start,Geo_y_end));
                    if ~(flag1&&flag2)
                        continue;
                    end
                  
                    s_inGeo = Geo_s + CoorGetDis(x,y,Geo_x_start,Geo_y_start);%交点的s坐标
                    direction  =  CoorSideJudge(Geo_x_start,Geo_y_start,Geo_x_end,Geo_y_end,pointX,pointY);%判断点落在参考线的某一侧
                    offset = OpenDriveGetSOffset(s_inGeo,direction,mOffsets,RoadGeoEnd);
                    %计算参考线的交点关于offset的偏移
                    hdg = mGeo.hdg;
                    x_offset = x + offset * cos(hdg  + direction*pi/2); %偏移后
                    y_offset = y + offset * sin(hdg  + direction*pi/2); %偏移后
                    %同向偏移
                    if direction == -1
                        x_s_offset = Geo_x_start + offset * cos(hdg + direction*pi/2); %偏移后
                        y_s_offset = Geo_y_start + offset * sin(hdg + direction*pi/2); %偏移后
                        x_e_offset = Geo_x_end + offset * cos(hdg + direction*pi/2); %偏移后
                        y_e_offset = Geo_y_end + offset * sin(hdg + direction*pi/2); %偏移后
                    end
                    
                    %反向偏移
                    if direction == 1
                        x_s_offset = Geo_x_end + offset * cos(hdg + direction*pi/2); %偏移后
                        y_s_offset = Geo_y_end + offset * sin(hdg + direction*pi/2); %偏移后
                        x_e_offset = Geo_x_start + offset * cos(hdg + direction*pi/2); %偏移后
                        y_e_offset = Geo_y_start + offset * sin(hdg + direction*pi/2); %偏移后
                    end
                  
                    disList = [disList;abs(v),x,y,RoadNum,direction,hdg,Geo_x_start,Geo_y_start,Geo_x_end,Geo_y_end,s_inGeo,offset,x_offset,y_offset,x_s_offset,y_s_offset,x_e_offset,y_e_offset,GeoIdx,Geo_s,Geo_s_end];               
                end             
            end          
        end  
    end
        disList= sortrows(disList,1);  
        point.x = disList(1,2);
        point.y = disList(1,3);
        point.RoadNum = disList(1,4);
        point.direction = disList(1,5);
        point.hdg = disList(1,6);
        point.x_s = disList(1,7);
        point.y_s = disList(1,8);
        point.x_e = disList(1,9);
        point.y_e = disList(1,10);
        point.s_inGeo = disList(1,11);
        point.offset = disList(1,12);
        point.x_offset = disList(1,13);
        point.y_offset = disList(1,14);
        point.x_s_offset = disList(1,15);
        point.y_s_offset = disList(1,16);
        point.x_e_offset = disList(1,17);
        point.y_e_offset = disList(1,18);
        point.GeoIdx = disList(1,19); 
        point.s_start = disList(1,20);
        point.s_end = disList(1,21);
end
