function  [point,cache] = pointBelongs1(openDriveObj,pointX,pointY,ax)
    format short;
    cache = [];
    cache(length(cache)+1) = plot(ax,pointX,pointY,'+');
    point = struct;
    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    k = 0;
    for i = 1:roadNum %roadNum是道路顺序号
        if roadObj{1,i}.Attributes.junction == "-1"
            tempGeometryList = roadObj{1,i}.planView.geometry;
            currentRoadNum = str2double(roadObj{1,i}.Attributes.id);
            f = length(tempGeometryList);
            for j = 1:f
                tempGeometry = getSingleObject(tempGeometryList,j);
                if isfield (tempGeometry,'line')
                    msg = getMsgFromGeo(tempGeometry);
                    x_s = msg.x; %参考线的起点x
                    y_s = msg.y; %参考线的起点y
                    s_length = msg.mlength; %参考线长度
                    hdg = msg.hdg;%参考线延伸角度
                    x_e = x_s + s_length*cos(hdg); %参考线的终点x
                    y_e = y_s + s_length*sin(hdg); %参考线的终点y
                    
                    [~,x_ref,y_ref] = getCrossMsg(x_s,y_s,hdg,pointX,pointY);
                    
                    side  =  sideJudge(x_s,y_s,x_e,y_e,pointX,pointY);
                    
                    [offset,rotateFlg] = getOffset(roadObj,i,j,side);
                    
                    % 在右侧的车道起止点与参考线同向；左侧则反向
                    if rotateFlg == -1
                    x_start = x_s + offset * cos(hdg + rotateFlg*pi/2); %偏移后的起点x
                    y_start = y_s + offset * sin(hdg + rotateFlg*pi/2); %偏移后的终点y
                    x_end = x_start + s_length*cos(hdg); %偏移后的终点x
                    y_end = y_start + s_length*sin(hdg); %偏移后的终点y
                    end
                    
                    if rotateFlg == 1
                    x_end = x_s + offset * cos(hdg + rotateFlg*pi/2); %偏移后的起点x
                    y_end = y_s + offset * sin(hdg + rotateFlg*pi/2); %偏移后的终点y
                    x_start = x_end + s_length*cos(hdg); %偏移后的终点x
                    y_start = y_end + s_length*sin(hdg); %偏移后的终点y
                    end
                    
                    [v,x,y] = getCrossMsg(x_start,y_start,hdg,pointX,pointY);
                    % 不落在线段上应该舍弃
                    flag1= (x<=max(x_start,x_end))&&(x>=min(x_start,x_end));
                    flag2= (y<=max(y_end,y_start))&&(y>=min(y_start,y_end));
%                     fprintf("hdg:%f  x_start:%f y_start:%f  RoadNum :%f  GeoNum:%f  x :%f  y:%f  dis:%f \n",hdg,x_start,y_start,i,j,x,y,abs(v));
                    if ~(flag1&&flag2)
%                         fprintf(" x :%f  y:%f \n",x,y);
                        continue;
                    end
                    k = k + 1;
%                     disList(k,:) = [abs(v),x,y,i,j,rotateFlg,hdg,x_start,y_start,x_end,y_end];
                    disList(k,:) = [abs(v),x,y,currentRoadNum,j,rotateFlg,hdg,x_start,y_start,x_end,y_end,x_s,y_s,x_e,y_e,x_ref,y_ref];
                    
                end              
            end          
        end    
    end
    disList= sortrows(disList,1);  
    point.Roadx = disList(1,2);
    point.Roady = disList(1,3);
    point.RoadNum = disList(1,4);
    point.GeoNum = disList(1,5);
    point.LaneNum = disList(1,6);
    point.hdg = disList(1,7);
    point.x_start = disList(1,8);
    point.y_start = disList(1,9);
    point.x_end = disList(1,10);
    point.y_end = disList(1,11);
    point.x_s = disList(1,12);
    point.y_s = disList(1,13);
    point.x_e = disList(1,14);
    point.y_e = disList(1,15);
    point.x_ref = disList(1,16);
    point.y_ref = disList(1,17);
   
    cache(length(cache)+1) = line(ax,[pointX point.Roadx],[pointY point.Roady],'linestyle','--');
   
end


function [offset,rotateFlg] = getOffset(roadObj,roadNum,GeoNum,side)
    currentGeometryList = roadObj{1,roadNum}.planView.geometry;
    currentGeometry = getSingleObject(currentGeometryList,GeoNum)
    s1 =  str2double(currentGeometry.Attributes.s);
    currentlanes = roadObj{1,roadNum}.lanes.laneSection;
    tempLen2 = length(currentlanes);
    offset = 0.0;
    rotateFlg = 0 ;
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
                rotateFlg = -1;
                offset = str2double(curlane.width.Attributes.a);
            end
            
            if isfield(currentlaneSection,'left') && side ==1
                rotateFlg = 1;
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



% 令矢量的起点为A，终点为B，判断的点为C，
% 如果S（A，B，C）为正数，则C在矢量AB的左侧；
% 如果S（A，B，C）为负数，则C在矢量AB的右侧；
% 如果S（A，B，C）为0，则C在直线AB上
function s = sideJudge(x1,y1,x2,y2,x3,y3)
s = ((x1-x3)*(y2-y3)-(y1-y3)*(x2-x3))/2;
s = sign(s);
end


