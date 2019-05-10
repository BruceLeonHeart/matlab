function  [roadNum,Roadx,Roady] = pointBelongs1(openDriveObj,pointX,pointY,ax)
    format short;
    plot(ax,pointX,pointY,'+');

    roadObj = openDriveObj.road;
    roadNum = length(roadObj);
    k = 0;
    for i = 1:roadNum
%         disList =[];
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
                    x_start = str2double(tempGeometry.Attributes.x);
                    y_start = str2double(tempGeometry.Attributes.y);
                    s_length = str2double(tempGeometry.Attributes.length);
                    hdg = str2double(tempGeometry.Attributes.hdg);
                    [offset,rotateFlg] = getOffset(roadObj,i,j);
                    x_start = x_start + offset * cos(hdg + rotateFlg*pi/2);
                    y_start = y_start + offset * sin(hdg + rotateFlg*pi/2);
                    x_end = x_start + s_length*cos(hdg);
                    y_end = y_start + s_length*sin(hdg);
                    
                    
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
                    disList(k,:) = [abs(v),x,y,i,j];
                end
                
            end          
        end
        
    end
    disList= sortrows(disList,1);   
    roadNum = disList(1,4);
    GeoNum = disList(1,5);
    Roadx = disList(1,2);
    Roady = disList(1,3);
   
    
%     fprintf(" THE ONE  RoadNum :%f  GeoNum:%f \n",roadNum,GeoNum);
    line(ax,[pointX Roadx],[pointY Roady],'linestyle','--');
    
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