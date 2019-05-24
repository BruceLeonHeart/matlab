function path = pathPlan1(startPoint,endPoint,ax1,openDriveObj)
    global ax;
    ax = ax1;
    
    global roads;
    global junctions;          
    roads = openDriveObj.road;
    junctions = openDriveObj.junction;
    startPoint
    endPoint
    
    %% 解析　openDriveObj
%     roadStruct = struct([]);
%     roads = openDriveObj.road;
%     id = 1;
%     for i1 = 1 : length(roads)
%         currentRoad = roads{1,i1};
%         Geos = currentRoad.planView.geometry;       
%         laneSections = currentRoad.lanes.laneSection;
%         for i2 = 1 : length(Geos)
%             if length(Geos) ==1
%                 currentGeo = Geos(1);
%             else
%                 currentGeo = Geos{1,i2};
%             end
%             x_s = str2double(currentGeo.Attributes.x);
%             y_s = str2double(currentGeo.Attributes.y);
%             hdg_s = str2double(currentGeo.Attributes.hdg);
%             s_length = str2double(currentGeo.Attributes.length);
%            
%               
%             
%             for i3 = 1:length(laneSections)
%                 
%               
%             
%                 if length(laneSections) ==1
%                     currentlane = laneSections(1);
%                 else
%                     currentlane = laneSections{1,i3};
%                 end
%                 
%                 
%                 
%                 if isfield(currentGeo,'line')  %长度维持
%                     s = s_length;
%                     if isfield(currentlane,'left')
% 
%                     roadStruct
%                     end
%                 end
% 
%                 if isfield(currentGeo,'spiral') %考虑到openEd特性　直接赋值０
%                     s = 0;
%                 end
% 
%                 if isfield(currentGeo,'arc') %长度缩放
% 
%                     s = 
%                 end
%                 
%                 
%                 
%                 
%             end
%         end      
%     end
    
    
    
    
    
    
    
    
    
    
    
    
    
    %考虑到生成路线过程中，会不停的生成plot/line对象
%    可用属性    
%       Roadx: 1100
%       Roady: 303.7500
%     RoadNum: 2
%      GeoNum: 1
%     LaneNum: -1
%         hdg: 3.1416
%     x_start: 1150
%     y_start: 303.7500
%       x_end: 950
%       y_end: 303.7500
      path = [];  % record for final path
%       path(length(path) +1) = line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',15,'color','g');  
%       path(length(path) +1) = line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',10,'color','r');  
%       

       %% A star Algo

       closelen = 0 ;
       close = struct([]);
       openlen = 0;
       open = struct([]);
       
       
       % add 1st item
       openlen = openlen + 1;
       open(1).x = startPoint.x_end; %final x
       open(1).y = startPoint.y_end; %final y
       open(1).g = getDis(startPoint.x_end,startPoint.y_end,startPoint.Roadx,startPoint.Roady);
       open(1).h = getDis(startPoint.x_end,startPoint.y_end,endPoint.Roadx,endPoint.Roady);
       open(1).f = open(1).g + open(1).h;
       open(1).RoadNum = startPoint.RoadNum;
       open(1).GeoNum = startPoint.GeoNum;
       open(1).LaneNum = startPoint.LaneNum;
       
       backNum = 0;
       prev = [];
       choose = 0;
       chooseArr = [];
       while openlen > 0
           for i = 1:openlen
               f(i,:) = [i , open(i).f];
           end
           f = sortrows(f,2);
           current = open(f(1,1));
           %% 回溯路径过程并将轨迹进行打印
           
           if isPointOnSegment(startPoint.Roadx,startPoint.Roady,startPoint.x_end,startPoint.y_end,endPoint.Roadx,endPoint.Roady)
               path(length(path) +1) = line(ax,[startPoint.Roadx,endPoint.Roadx],[startPoint.Roady,endPoint.Roady],'lineWidth',5,'color','b');
               return;
           end
           if current.RoadNum == endPoint.RoadNum && current.GeoNum == endPoint.GeoNum && current.LaneNum == endPoint.LaneNum 
               zzr =1;
               while(zzr <= size(prev,1))
                   if prev(zzr,4) == current.RoadNum && prev(zzr,5) == current.RoadNum && prev(zzr,6) ==  current.RoadNum
                       choose = choose +1;
                       chooseArr(choose,:) = prev(zzr,1:3);
                       current.RoadNum = prev(zzr,1);
                       current.RoadNum = prev(zzr,2);
                       current.RoadNum = prev(zzr,3);
                   else
                       i = i + 1;
                   end
               end
               
               path(length(path) +1) = line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',5,'color','b');
               for zzm = 2:size(chooseArr,1)-1
                   mLineMsg = getLineMsg(chooseArr(zzm,1),chooseArr(zzm,2),chooseArr(zzm,3));
                   if mLineMsg.type == "spiral"
                        path(length(path) +1) = spiralDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.curvStart,mLineMsg.curvEnd,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   elseif mLineMsg.type == "arc"
                        path(length(path) +1) = arcDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.curvature,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   elseif mLineMsg.type == "line"
                        path(length(path) +1) = lineDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   end
               end
               path(length(path) +1) = line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',5,'color','b');
               return;
          end
               
           
           
           
           
           closelen = closelen + 1;
           close(closelen).RoadNum = current.RoadNum;
           close(closelen).GeoNum = current.GeoNum;
           close(closelen).LaneNum = current.LaneNum;
           open(f(1,1)) =[];
           openlen = openlen -1;
           NeighborMsg = getNeighbor(current.RoadNum,current.GeoNum,current.LaneNum);
           for k = 1 : length(NeighborMsg)
               currentNeighbor = NeighborMsg(k,:);
               neighbor.RoadNum =  currentNeighbor(1);
               neighbor.GeoNum =  currentNeighbor(2);
               neighbor.LaneNum =  currentNeighbor(3);
               LineMsg = getLineMsg(neighbor.RoadNum,neighbor.GeoNum,neighbor.LaneNum);
               neighbor.g = current.g + LineMsg.mlength;
               if LineMsg.type == "spiral"
                    [x_f,y_f] = getSpiralFinalXY(LineMsg.x,LineMsg.y,LineMsg.hdg,LineMsg.mlength,LineMsg.curvStart,LineMsg.curvEnd,LineMsg.offset,sign(neighbor.LaneNum));
               elseif LineMsg.type == "arc"
                    [x_f,y_f] = getArcFinalXY(LineMsg.x,LineMsg.y,LineMsg.hdg,LineMsg.mlength,LineMsg.curvature,LineMsg.offset,sign(neighbor.LaneNum));
               elseif LineMsg.type == "line"
                    [x_f,y_f] = getLineFinalXY(LineMsg.x,LineMsg.y,LineMsg.hdg,LineMsg.mlength,LineMsg.offset,sign(neighbor.LaneNum));
               end
               neighbor.h = getDis(x_f,y_f,endPoint.Roadx,endPoint.Roady);
               neighbor.f = neighbor.g + neighbor.h;
               
               inCloseFlag =0 ;
               
               if closelen ==0
               else
                   for m = 1 :closelen
                       if close(m).RoadNum == neighbor.RoadNum &&close(m).GeoNum == neighbor.GeoNum && close(m).LaneNum == neighbor.LaneNum
                           inCloseFlag = 1 ;
                           break;
                       end
                   end
               end
               
               if inCloseFlag
                   continue;
               end
               
               temp_g =  current.g  + LineMsg.mlength;
               inOpenFlag = 0;
               for p = 1:openlen
                   if open(m).RoadNum == neighbor.RoadNum &&open(m).GeoNum == neighbor.GeoNum && open(m).LaneNum == neighbor.LaneNum
                           inOpenFlag = 1 ;
                           gscore = open(m).g;
                           break;
                   end   
               end
                
               if ~inOpenFlag
                   openlen = openlen + 1;
                   open(openlen).RoadNum = neighbor.RoadNum;
                   open(openlen).GeoNum = neighbor.GeoNum;
                   open(openlen).LaneNum = neighbor.LaneNum;
                   open(openlen).x = x_f;
                   open(openlen).y = y_f;
                   open(openlen).g = neighbor.g;
                   open(openlen).h = neighbor.h;
                   open(openlen).f = neighbor.f;
               elseif temp_g >= gscore
                   continue;
               else
                   backNum = backNum+1;
                   prev(backNum,:) = [current.RoadNum,current.GeoNum,current.LaneNum,neighbor.RoadNum,neighbor.GeoNum,neighbor.LaneNum];
                   neighbor.g = temp_g;
                   neighbor.f = neighbor.g + neighbor.h;
               end
           end          
       end
%       open = {};
%       i = 1;
%       open{1} = startPoint;
%       while(i <= length(open)  &&  ~isempty(open{i}) )          
%           if isPointOnSegment(startPoint.Roadx,startPoint.Roady,startPoint.x_end,startPoint.y_end,endPoint.Roadx,endPoint.Roady)
%               fprintf("jack...");
%               path(length(path) +1) = line(ax,[startPoint.Roadx,endPoint.Roadx],[startPoint.Roady,endPoint.Roady],'lineWidth',5,'color','b');
%               open{i} = [];
%               i = i -1;
%               break;
%           end
%           i = i + 1;
%       end
%       path
% fprintf("%f \n",startPoint.Roadx);
% fprintf("%f",endPoint.Roadx);
% function  pathPlan() 
% fileObj = xml2struct('demo_prescan.xml');
% openDriveObj = fileObj.OpenDRIVE;
% roadObj = openDriveObj.road;
% roadNum = length(roadObj);
% junctionObj = openDriveObj.junction;
% junctionNum = length(junctionObj);
% linkedRoad = zeros(roadNum);
% for i =1:junctionNum
%     tempJunc = junctionObj{1,i};
%     tempConns = tempJunc.connection;
%     for j = 1:length(tempConns)
%         from = str2double(tempConns{1,j}.Attributes.incomingRoad);
%         to = str2double(tempConns{1,j}.Attributes.connectingRoad);
%         linkedRoad(from,to) = 1;
%     end
% end
% 
% 
%  
% for i = 1:roadNum    
%     if str2double(roadObj{1,i}.Attributes.junction) ~= -1
%          q = str2double(roadObj{1,i}.link.successor.Attributes.elementId);
%          linkedRoad(i,q) = 1;
%      end
% end
end
% end

%% 绘制螺旋线
 function spiralDraw1(x_start,y_start,hdg,mlength,curvstart,curvEnd,offset,laneFlag)  
    global ax;
    n = 100;
    xs = zeros(1,n);
    ys = zeros(1,n);
    t = linspace(0,mlength,n);
    c = (curvEnd - curvstart)/mlength;    
    cosline = @(t)(cos(c/2.0*t.^2 + curvstart *t + hdg));
    sinline = @(t)(sin(c/2.0*t.^2 + curvstart *t + hdg));
    for i= 1:n
        xs(i) = integral(cosline,t(1),t(i)) + x_start;
        ys(i) = integral(sinline,t(1),t(i)) + y_start;
    end
    if laneFlag==0    
        plot(ax,xs,ys,'linestyle','--');
%          arrowPlot1(ax,xs,ys,'linestyle','--','number',5);
    %% 右侧
    elseif laneFlag == -1
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
        end
        plot(ax,xs,ys,'lineWidth',5,'color','b');
%          arrowPlot1(ax,xs,ys,'number',5);
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        end
        plot(ax,xs,ys,'lineWidth',5,'color','b');
%          arrowPlot1(ax,xs,ys,'number',5);

    end
 end
 
%% 绘制直线
function  lineDraw1(x,y,hdg,mlength,offset,laneFlag) 
     global ax;
     % 沿着s方向的偏移量
     dx = mlength * cos(hdg);
     dy = mlength * sin(hdg);
    %% 原始参考线
     if laneFlag == 0
        line(ax,[x,x+dx],[y,y+dy],'linestyle','--','color','k');  
        quiver(ax,x,y,dx/2,dy/2,'linestyle','--');

    %% 右侧 基于s方向顺时针旋转
     elseif laneFlag == -1 
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        line(ax,[x,x+dx],[y,y+dy],'lineWidth',5,'color','b');

        quiver(ax,x,y,dx/2,dy/2);

    %% 左侧 基于s方向逆时针旋转
     else 
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        line(ax,[x,x+dx],[y,y+dy],'lineWidth',5,'color','b');
        quiver(ax,x,y,dx/2,dy/2);

     end
end

%% 绘制圆弧
function  arcDraw1(x,y,hdg,mlength,curvature,offset,laneFlag)
    global ax;
    if laneFlag == 0
        n = 100;
        t = linspace(0,mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + curvature*t ));
        sinline = @(t)(sin(hdg + curvature *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end
        plot(ax,xs,ys,'linestyle','--');
%         arrowPlot1(ax,xs,ys,'linestyle','--','number',5);

    %% 右侧
    elseif laneFlag == -1
        % 修改起始位置
        origin_r = abs(1/curvature); %起始圆半径 
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        %顺时针时，右侧的圆半径减小;逆时针时，右侧的圆半径增大
        if curvature <= 0
            current_r = origin_r -offset;
            current_c = - 1/current_r;
        else
            current_r = origin_r +offset;
            current_c = 1/current_r;
        end
        cur_mlength = mlength * current_r/origin_r;
        n = 100;
        t = linspace(0,cur_mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + current_c* t ));
        sinline = @(t)(sin(hdg + current_c *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end
%         arrowPlot1(ax,xs,ys,'number',5);
        plot(ax,xs,ys,'lineWidth',5,'color','b');      
    %% 左侧
    else
        % 修改起始位置
        origin_r = abs(1/curvature); %起始圆半径 
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        %顺时针时，左侧的圆半径增大;逆时针时，左侧的圆半径减小
        if curvature <= 0
            current_r = origin_r + offset;
            current_c = - 1/current_r;
        else
            current_r = origin_r - offset;
            current_c = 1/current_r;
        end
        cur_mlength = mlength * current_r/origin_r;
        n = 100;
        t = linspace(0,cur_mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + current_c* t ));
        sinline = @(t)(sin(hdg + current_c *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end
        plot(ax,xs,ys,'lineWidth',5,'color','b');
%         arrowPlot1(ax,xs,ys,'number',5);

    end
end

%% 判断点C是否落在线段AB上
function flag = isPointOnSegment(A_x,A_y,B_x,B_y,C_x,C_y)
    flag = 0;
    if (A_x - C_x) * (B_y - C_y) == (A_y - C_y) * (B_x - C_x) %在直线上
        min_x = min(A_x,B_x);
        max_x = max(A_x,B_x);
        min_y = min(A_y,B_y);
        max_y = max(A_y,B_y);
        if C_x >= min_x && C_x <= max_x && C_y >= min_y && C_y <= max_y
            flag = 1;
        end
    end
    
end

%% 两点间欧氏距离
function dis = getDis(x1,y1,x2,y2)
    a = [x1 ,y1];
    b = [x2 ,y2];
    dis = norm(a-b);    
end

%% 邻居捕捉
function NeighborMsg = getNeighbor(RoadNum,GeoNum,LaneNum)
    %　邻居信息矩阵
    NeighborMsg = []; %三列，分别记录Road,Geo,Num
    global roads;
    global junctions; 
    currentRoad = roads{1,RoadNum};
    
    %当前车道的下一段

    if isfield(currentRoad,'link')
        mlink = currentRoad.link;
        %　暂时不做前继节点的操作
        if isfield(mlink,'predecessor')
            mpredecessor = mlink.predecessor;
        end
%         if isfield(mlink,'predecessor')
%             mpredecessor = mlink.predecessor;
%             if mpredecessor.Attributes.elementType == "junction"
%                 junctionId = str2double(mpredecessor.Attributes.elementId);
%                 for i = 1:length(junctions)
%                     if length(junctions) ==1
%                         mjunction = junctions(1);
%                     else
%                         mjunction = junctions{1,i};
%                     end
%                     if str2double(mjuntion.Attributes.id) == junctionId
%                         %...                       
%                         break;
%                     end
%                     
%                 end
%                 
%             else  %road
%             end
%         end
        
        %关注后续节点       
        if isfield(mlink,'successor')
            msuccessor = mlink.successor;
            if msuccessor.Attributes.elementType == "junction"
                junctionId = str2double(msuccessor.Attributes.elementId);
                for i = 1:length(junctions)
                    if length(junctions) ==1
                        mjunction = junctions(1);
                    else
                        mjunction = junctions{1,i};
                    end
                    if str2double(mjuntion.Attributes.id) == junctionId
                        connections = mjunction.connection;
                        for i1 = 1 :length(connections)
                            if length(connections) ==1
                                mconnection = connections(1);
                            else
                                mconnection = connections{1,i};
                            end
                            if str2double(mconnection.Attributes.incomingRoad) == RoadNum
                                mlaneLinks = mconnection.laneLink;
                                for i2 = 1:length(mlaneLinks)
                                    if length(mlaneLinks) ==1 
                                        mlaneLink = mlaneLinks(1);
                                    else
                                        mlaneLink = mlaneLinks{1,i2};
                                    end
                                    if str2double(mlaneLink.Attributes.from)==LaneNum
                                        resLaneNum = str2double(mlaneLink.Attributes.to);
                                        break;
                                    end
                                end
                                resRoadNum = str2double(mconnection.Attributes.connectingRoad);                           
                                if mconnection.Attributes.incomingRoad == "start"
                                    resGeoNum = 1;
                                else
                                    resGeoNum = length(roads{1,resRoadNum}.planView.geometry);
                                end  
                                NeighborMsg(length(NeighborMsg)+1,:) = [resRoadNum,resGeoNum,resLaneNum];                               
                                continue;
                            end     
                        end
                        break;
                    end 
                end  
            else  %road
                currentGeo = currentRoad.planView.geometry;
                if GeoNum == length(currentGeo)
                    %处于最后一段LaneSection（包含仅有一段Geo的情况）
                    if sign(LaneNum) == -1
                    %LaneNum为负，参考线右侧，但与参考线同向，下一车道处于下一Road
                        resRoadNum = str2double(msuccessor.Attributes.elementId);
                        if msuccessor.Attributes.contactPoint == "start"
                            resGeoNum = 1;
                            resLaneNum = -1;
                        else
                            resGeoNum = length(roads{1,resRoadNum}.planView.geometry);
                            resLaneNum = 1;
                        end
                        NeighborMsg(length(NeighborMsg)+1,:) = [resRoadNum,resGeoNum,resLaneNum]; 
                    else
                    %LaneNum为正，参考线左侧，与参考线反向，下一车道处于上一Road
                        resRoadNum = str2double(mpredecessor.Attributes.elementId);
                        if msuccessor.Attributes.contactPoint == "start"
                            resGeoNum = 1;
                            resLaneNum = 1;
                        else
                            resGeoNum = length(roads{1,resRoadNum}.planView.geometry);
                            resLaneNum = -1;
                        end
                        NeighborMsg(length(NeighborMsg)+1,:) = [resRoadNum,resGeoNum,resLaneNum]; 
                    end
                    
                                       
                else 
                    %　处于中间时的处理方式
                    resRoadNum = RoadNum;
                    resGeoNum = GeoNum +1;
                    resLaneNum = LaneNum;
                    NeighborMsg(length(NeighborMsg)+1,:) = [resRoadNum,resGeoNum,resLaneNum]; 
                end  
            end
        end       
    end

end
%%　通过 Road,Geo,Lane获取相关信息
function LineMsg = getLineMsg(RoadNum,GeoNum,LaneNum)
    global roads;
    for i =1:length(roads)
        if str2double(roads{1,i}.Attributes.id) == RoadNum
            Geos = roads{1,i}.planView.geometry;
            for j = 1:length(Geos)
                if length(Geos) == 1
                    currentGeo = Geos(1);
                else
                    currentGeo = Geos{1,j};
                end  
                if j == GeoNum
                LineMsg.s = str2double(currentGeo.Attributes.s);
                LineMsg.x = str2double(currentGeo.Attributes.x);
                LineMsg.y = str2double(currentGeo.Attributes.y);
                LineMsg.hdg = str2double(currentGeo.Attributes.hdg);
                LineMsg.mlength = str2double(currentGeo.Attributes.length);
                if isfield(currentGeo,'line')
                    LineMsg.linetype = 'line';
                end
                
                if isfield(currentGeo,'spiral')
                    LineMsg.linetype = 'spiral';
                    LineMsg.curvStart = str2double(currentGeo.spiral.Attributes.curvStart);
                    LineMsg.curvEnd = str2double(currentGeo.spiral.Attributes.curvEnd);
                end
                if isfield(currentGeo,'arc')
                    LineMsg.linetype = 'arc';
                    LineMsg.curvature = str2double(currentGeo.spiral.Attributes.curvEnd);
                end
                    break;
                end
            end
            
            LaneSections = roads{1,i}.lanes.laneSection;
            if sign(LaneNum) == -1
                lanes = LaneSections.right.lane;
            end
            if sign(LaneNum) == 1
                lanes = LaneSections.left.lane;
            end
            for k = 1:length(lanes)
                if length(lanes) == 1
                    crtlane = lanes(1);
                else
                    crtlane = lanes{1,k};
                end
                
                if str2double(crtlane.Attributes.id) == LaneNum
                    LineMsg.offset = str2double(crtlane.width.Attributes.a);
                    break;
                end
            end
            
            
            
            
            
            break;
        end
    end
    
end
%% 直线通过起点计算终点坐标
function [x_f,y_f] = getLineFinalXY(x,y,hdg,mlength,offset,laneFlag)
     dx = mlength * cos(hdg);
     dy = mlength * sin(hdg);
    %% 原始参考线
     if laneFlag == 0
        x_f = x + dx;
        y_f = y + dy;

    %% 右侧 基于s方向顺时针旋转
     elseif laneFlag == -1 
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        x_f = x + dx;
        y_f = y + dy;
    %% 左侧 基于s方向逆时针旋转
     else 
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        x_f = x + dx;
        y_f = y + dy;

     end


end
%% 圆弧通过起点计算终点坐标
function [x_f,y_f] = getArcFinalXY(x,y,hdg,mlength,curvature,offset,laneFlag)
    origin_r = abs(1/curvature); %起始圆半径
    if laneFlag == 0 %原始
        if curvature <= 0
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + origin_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + origin_r*(sin(theta-delta_theta) - sin(theta));
        else
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + origin_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + origin_r*(sin(theta+delta_theta) - sin(theta));
        end
    elseif laneFlag == -1% right
        % 修改起始位置
         
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        %顺时针时，右侧的圆半径减小;逆时针时，右侧的圆半径增大
        if curvature <= 0
            current_r = origin_r -offset;
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta-delta_theta) - sin(theta));
            
        else
            current_r = origin_r +offset;
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta+delta_theta) - sin(theta));
        end
       
    else %left
         % 修改起始位置
 
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        %顺时针时，左侧的圆半径增大;逆时针时，左侧的圆半径减小
        if curvature <= 0
            current_r = origin_r + offset;
            theta = hdg + pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta-delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta-delta_theta) - sin(theta));
        else
            current_r = origin_r - offset;
            theta = hdg - pi/2;
            delta_theta = mlength/origin_r;
            x_f = x + current_r*(cos(theta+delta_theta) - cos(theta));
            y_f = y + current_r*(sin(theta+delta_theta) - sin(theta));
        end
        
    end
end

%% 螺旋线通过起点计算终点坐标
function [x_f,y_f] = getSpiralFinalXY(x,y,hdg,mlength,cvstart,cvend,offset,laneFlag)
%     n = 100;
%     xs = zeros(1,n);
%     ys = zeros(1,n);
%     t = linspace(0,mlength,n);
    c = (cvend - cvstart)/mlength;
    cosline = @(mlength)(cos(hdg + cvstart * mlength + c/2.0*mlength.^2));
    sinline = @(mlength)(sin(hdg + cvstart * mlength + c/2.0*mlength.^2));
    x_f = x + integral(cosline,0,mlength);
    y_f = y + integral(sinline,0,mlength);
    if laneFlag == 0
      
    elseif laneFlag == -1
        x_f = x_f + offset*cos(hdg + cvstart * mlength + c/2.0*mlength.^2 -pi/2);
        y_f = y_f + offset*sin(hdg + cvstart * mlength + c/2.0*mlength.^2 -pi/2);
    else
        x_f = x_f + offset*cos(hdg + cvstart * mlength + c/2.0*mlength.^2 +pi/2);
        y_f = y_f + offset*sin(hdg + cvstart * mlength + c/2.0*mlength.^2 +pi/2);
    end
    
end


