function  [roadNum,Roadx,Roady] = pointBelongs(pointX,pointY)
    drawMap20190418;
    hold on;
    plot(pointX,pointY,'+');
%     roadObj
%     roadObj{1,1}.Attributes.junction
%     roadObj{1,1}.planView.geometry{1,1}
%     length(roadObj{1,1}.planView.geometry)
    k = 0;
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
                    x_start = str2double(tempGeometry.Attributes.x);
                    y_start = str2double(tempGeometry.Attributes.y);
                    s_length = str2double(tempGeometry.Attributes.length);
                    hdg = str2double(tempGeometry.Attributes.hdg);
                    n = 10000;
                    t = linspace(0,s_length,n);
                    x_list = x_start + t*cos(hdg);
                    y_list = y_start + t*sin(hdg);
                    [v,idx] = min(sqrt((x_list - pointX).^2 + (y_list - pointY).^2 ));
                    k = k + 1;
                    disList(k,:) = [v,x_list(idx),y_list(idx),i];
                end
                
            end          
        end
    end
    disList= sortrows(disList,1);
     a = abs(pointX - disList(1,2));
     b = abs(pointY - disList(1,3));
     if a == min(a,b)
             line([pointX disList(1,2)],[pointY (disList(1,3) + sign(pointY - disList(1,3))*1.5)],'linestyle','--');
     else
             line([pointX (disList(1,2) + sign(pointX - disList(1,2))*1.5)],[pointY disList(1,3)],'linestyle','--');
     end    
    roadNum = disList(1,4);
    Roadx = disList(1,2);
    Roady = disList(1,3);
%     offset
    
%% 从Road级别开始检索，并限制Road的Junction为-1，意为不能检索联结    
%     figure('Name','mapViwer','color','green');
%     hold on
%     f = warndlg('plz choose the start point'); %警告对话框
%     uicontrol('parent',f,'Style','text','String','plz choose start point',[50 40 210 30],'fontSize',10);
%     waitfor(f);
%     pause(1);
end

