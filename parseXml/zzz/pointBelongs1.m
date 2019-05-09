function  [roadNum,Roadx,Roady] = pointBelongs(openDriveObj,pointX,pointY,ax)
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
                    flag1= (x<=x_end)&&(x>=x_start);
                    flag2= (y<=y_end)&&(y>=y_start);
                    if ~(flag1&&flag2)
                        continue;
                    end
                    
%                     a = [cos(hdg) sin(hdg)];
%                     b = [x-x_start   y-y_start];
%                     b1 = [(x_start - pointX)   (y_start -pointY)];
%                     flag1 = (dot(a,b1) <0) ;
%                     theta = acos(dot(a,b)/(norm(a)*norm(b)));
%                     flag2 =  ((abs (theta) - pi) <0.001);
% %                     delta = acos(dot(a,b)/(norm(a)*norm(a)));
%                     fprintf("hdg:%f  x_start:%f y_start:%f  RoadNum :%f  GeoNum:%f  x :%f  y:%f  dis:%f \n",hdg,x_start,y_start,i,j,x,y,abs(v));
%                     if (~flag1&&flag2) ||(flag1&& (abs (theta) <0.001))
%                          fprintf(" x :%f  y:%f \n",x,y);
%                         continue;
%                     end
%                     n = 10000;
%                     t = linspace(0,s_length,n);
%                     x_list = x_start + t*cos(hdg);
%                     y_list = y_start + t*sin(hdg);
%                     [v,idx] = min(sqrt((x_list - pointX).^2 + (y_list - pointY).^2 ));
                    k = k + 1;
                    disList(k,:) = [abs(v),x,y,i,j];
%                     disList(k,:) = [v,x_list(idx),y_list(idx),i];
                end
                
            end          
        end
        
    end
    disList= sortrows(disList,1);
%      a = abs(pointX - disList(1,2));
%      b = abs(pointY - disList(1,3));
%      if a == min(a,b)
% %              line(ax,[pointX disList(1,2)],[pointY (disList(1,3) + sign(pointY - disList(1,3))*3)],'linestyle','--');
%              line(ax,[pointX disList(1,2)],[pointY (disList(1,3) + sign(pointY - disList(1,3))*3)],'linestyle','--');
%      else
% %              line(ax,[pointX (disList(1,2) + sign(pointX - disList(1,2))*3)],[pointY disList(1,3)],'linestyle','--');
%              line(ax,[pointX (disList(1,2) + sign(pointX - disList(1,2))*3)],[pointY disList(1,3)],'linestyle','--');
%      end    

    roadNum = disList(1,4);
    GeoNum = disList(1,5);
    Roadx = disList(1,2);
    Roady = disList(1,3);
    fprintf(" THE ONE  RoadNum :%f  GeoNum:%f \n",roadNum,GeoNum);
    line(ax,[pointX Roadx],[pointY Roady],'linestyle','--');
%     offset
    
%% 从Road级别开始检索，并限制Road的Junction为-1，意为不能检索联结    
%     figure('Name','mapViwer','color','green');
%     hold on
%     f = warndlg('plz choose the start point'); %警告对话框
%     uicontrol('parent',f,'Style','text','String','plz choose start point',[50 40 210 30],'fontSize',10);
%     waitfor(f);
%     pause(1);
end

