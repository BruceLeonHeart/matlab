function  point = OpenDrivePointBelong(openDriveObj,pointX,pointY)
    point = struct();
    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    disList = [];
    for roadIdx = 1:roadNum %roadNum是道路顺序号
         crtRoad = roadObj{1,roadIdx};
        if crtRoad.Attributes.junction == "-1"%不考虑落在junction上的情况
            tempGeometryList = crtRoad.planView.geometry;
            currentRoadNum = str2double(crtRoad.Attributes.id);
            for geoIdx = 1:length(tempGeometryList)
                tempGeometry = getSingleObject(tempGeometryList,geoIdx);
                if isfield (tempGeometry,'line') %仅考虑落在直线上的情况
                    msg = OpenDriveGetGeoMsg(tempGeometry);
                    s = msg.x; %参考线的起点s
                    x_s = msg.x; %参考线的起点x
                    y_s = msg.y; %参考线的起点y
                    s_length = msg.mlength; %参考线长度
                    hdg = msg.hdg;%参考线延伸角度
                    x_e = x_s + s_length*cos(hdg); %参考线的终点x
                    y_e = y_s + s_length*sin(hdg); %参考线的终点y
                    
                    
                    [v,x_ref,y_ref] = CoorGetCrossMsg(x_s,y_s,hdg,pointX,pointY); %与参考线的交点，垂足
                    s_e = s + CoorGetDis(x_ref,y_ref,x_s,y_s);%交点的s坐标
                    direction  =  CoorSideJudge(x_s,y_s,x_e,y_e,pointX,pointY);%判断点落在参考线的某一侧
                    offset = getOffset(crtRoad,tempGeometry,direction);
                    %计算参考线的交点关于offset的偏移
                    x_ref_offset = x_ref + offset * cos(hdg + direction*pi/2); %偏移后
                    y_ref_offset = y_ref + offset * sin(hdg + direction*pi/2); %偏移后
                    %同向偏移
                    if direction == -1
                        x_s_offset = x_s + offset * cos(hdg + direction*pi/2); %偏移后
                        y_s_offset = y_s + offset * sin(hdg + direction*pi/2); %偏移后
                        x_e_offset = x_e + offset * cos(hdg + direction*pi/2); %偏移后
                        y_e_offset = y_e + offset * sin(hdg + direction*pi/2); %偏移后
                    end
                    
                    %反向偏移
                    if direction == 1
                        x_s_offset = x_e + offset * cos(hdg + direction*pi/2); %偏移后
                        y_s_offset = y_e + offset * sin(hdg + direction*pi/2); %偏移后
                        x_e_offset = x_s + offset * cos(hdg + direction*pi/2); %偏移后
                        y_e_offset = y_s + offset * sin(hdg + direction*pi/2); %偏移后
                    end
                     % 不落在线段上应该舍弃
                    flag1= (x_ref<=max(x_s,x_e))&&(x_ref>=min(x_s,x_e));
                    flag2= (y_ref<=max(y_s,y_e))&&(y_ref>=min(y_s,y_e));

                    if ~(flag1&&flag2)
                        continue;
                    end

                    disList = [disList;abs(v),x_ref,y_ref,currentRoadNum,direction,hdg,x_s,y_s,x_e,y_e,s_e,offset,x_ref_offset,y_ref_offset,x_s_offset,y_s_offset,x_e_offset,y_e_offset];
                    
                end              
            end          
        end    
    end
    disList= sortrows(disList,1);  
    point.x_ref = disList(1,2);
    point.y_ref = disList(1,3);
    point.roadNum = disList(1,4);
    point.direction = disList(1,5);
    point.hdg = disList(1,6);
    point.x_s = disList(1,7);
    point.y_s = disList(1,8);
    point.x_e = disList(1,9);
    point.y_e = disList(1,10);
    point.s_e = disList(1,11);
    point.offset = disList(1,12);
    point.x_ref_offset = disList(1,13);
    point.y_ref_offset = disList(1,14);
    point.x_s_offset = disList(1,15);
    point.y_s_offset = disList(1,16);
    point.x_e_offset = disList(1,17);
    point.y_e_offset = disList(1,18);
    
end


%%通过geo信息找到laneSeciton中的offset属性
%当前道路对象roadObj
%当前geo对象geoObj
function offset = getOffset(roadObj,geoObj,side)    
    s1 =  str2double(geoObj.Attributes.s);
    currentlanes = roadObj.lanes.laneSection;
    tempLen2 = length(currentlanes);
    offset = 0.0;
    for m =1:tempLen2
        currentlaneSection = getSingleObject(currentlanes,m);
        if abs(str2double(currentlaneSection.Attributes.s) - s1)<1e-004
            if isfield(currentlaneSection,'right')&& side == -1
                lanes = currentlaneSection.right.lane;
                for zz1= 1:length(lanes)
                    crtlane = getSingleObject(lanes,zz1);
                    if crtlane.Attributes.type == "driving"
                        curlane = crtlane;
                        break;
                    end
                end
                offset = str2double(curlane.width.Attributes.a);
            end
            
            if isfield(currentlaneSection,'left') && side ==1
                lanes = currentlaneSection.left.lane;
                for zz1= 1:length(lanes)
                    if lanes{1,zz1}.Attributes.type == "driving"
                        curlane = lanes{1,zz1};
                        break;
                    end
                end
                offset = str2double(curlane.width.Attributes.a);
            end
            break;
        end      
    end

end
