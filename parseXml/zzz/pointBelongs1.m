% function  [RoadNum,Roadx,Roady,GeoNum,LaneNum] = pointBelongs1(openDriveObj,pointX,pointY,ax)
function  point = pointBelongs1(openDriveObj,pointX,pointY,ax)
    format short;
    plot(ax,pointX,pointY,'+');
    point = struct;
    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    k = 0;
%             disList =[];
    for i = 1:roadNum

        if roadObj{1,i}.Attributes.junction == "-1"
            tempGeometryList = roadObj{1,i}.planView.geometry;
            f = length(tempGeometryList);
            for j = 1:f
                if f == 1 
                    tempGeometry = tempGeometryList(j);
                else
                    tempGeometry = tempGeometryList{1,j};
                end
                if isfield (tempGeometry,'line')
                    x_s = str2double(tempGeometry.Attributes.x); %参考线的起点x
                    y_s = str2double(tempGeometry.Attributes.y); %参考线的起点y
                    s_length = str2double(tempGeometry.Attributes.length); %参考线长度
                    hdg = str2double(tempGeometry.Attributes.hdg);%参考线延伸角度
                    [offset,rotateFlg] = getOffset(roadObj,i,j);
                    x_start = x_s + offset * cos(hdg + rotateFlg*pi/2); %偏移后的起点x
                    y_start = y_s + offset * sin(hdg + rotateFlg*pi/2); %偏移后的终点y
                    x_end = x_start + s_length*cos(hdg); %偏移后的终点x
                    y_end = y_start + s_length*sin(hdg); %偏移后的终点y
                    
                   
                    if abs(cos(hdg))<1.00e-15
                        B = 0;
                        A = 1;
                        C = -x_start;
                    else
                        B = 1;
                        A = - tan(hdg);
                        C = tan(hdg) * x_start - y_start;
                    end
                    % 距离
                    v = (A*pointX + B*pointY + C)/sqrt(A^2 + B^2);
                    %　求垂足
                    x = (B*B*pointX - A*B*pointY - A*C)/(A^2 + B^2);
                    y = (-B*A*pointX + A*A*pointY - B*C)/(A^2 + B^2);
                    % 不落在线段上应该舍弃
                    flag1= (x<=max(x_start,x_end))&&(x>=min(x_start,x_end));
                    flag2= (y<=max(y_end,y_start))&&(y>=min(y_start,y_end));
%                     fprintf("hdg:%f  x_start:%f y_start:%f  RoadNum :%f  GeoNum:%f  x :%f  y:%f  dis:%f \n",hdg,x_start,y_start,i,j,x,y,abs(v));
                    if ~(flag1&&flag2)
%                         fprintf(" x :%f  y:%f \n",x,y);
                        continue;
                    end
                    k = k + 1;
                    disList(k,:) = [abs(v),x,y,i,j,rotateFlg,hdg,x_start,y_start,x_end,y_end];
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
   
    
%     fprintf(" THE ONE  RoadNum :%f  GeoNum:%f  LaneNum:%f\n",roadNum,GeoNum,LaneNum);
    line(ax,[pointX point.Roadx],[pointY point.Roady],'linestyle','--');
    
%% 从Road级别开始检索，并限制Road的Junction为-1，意为不能检索联结    
%     figure('Name','mapViwer','color','green');
%     hold on
%     f = warndlg('plz choose the start point'); %警告对话框
%     uicontrol('parent',f,'Style','text','String','plz choose start point',[50 40 210 30],'fontSize',10);
%     waitfor(f);
%     pause(1);
end


function [offset,rotateFlg] = getOffset(roadObj,roadNum,GeoNum)
    currentGeometryList = roadObj{1,roadNum}.planView.geometry;
    tempLen = length(currentGeometryList);
    if tempLen == 1 
        currentGeometry = currentGeometryList(GeoNum);
    else
        currentGeometry = currentGeometryList{1,GeoNum};
    end
    s1 =  str2double(currentGeometry.Attributes.s);
    currentlanes = roadObj{1,roadNum}.lanes.laneSection;
    tempLen2 = length(currentlanes);
    offset = 0.0;
    rotateFlg = 0 ;
    for m =1:tempLen2
        if tempLen2 == 1 
            currentlaneSection = currentlanes(m);
        else
            currentlaneSection = currentlanes{1,m};
        end
        if abs(str2double(currentlaneSection.Attributes.s) - s1)<1e-004
            if isfield(currentlaneSection,'right')
                rotateFlg = -1;
                offset = str2double(currentlaneSection.right.lane.width.Attributes.a);
            end
            if isfield(currentlaneSection,'left')
                rotateFlg = 1;
                offset = str2double(currentlaneSection.right.lane.width.Attributes.a);
            end
            break;
        end      
    end

end