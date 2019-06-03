function pathList = pathPlan1(startPoint,endPoint,ax1,openDriveObj)
    global ax;
    ax = ax1;
    
    global roads;
    global junctions;          
    roads = openDriveObj.road;
    junctions = openDriveObj.junction;
    startPoint
    endPoint    
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
      pathList = [];  % record for final path
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
           open
           f1 = sortrows(f,2);
           current = open(f1(1,1));
            
           
           %% 回溯路径过程并将轨迹进行打印
           
           if isPointOnSegment(startPoint.Roadx,startPoint.Roady,startPoint.x_end,startPoint.y_end,endPoint.Roadx,endPoint.Roady)
               pathList(length(pathList) +1) = line(ax,[startPoint.Roadx,endPoint.Roadx],[startPoint.Roady,endPoint.Roady],'lineWidth',5,'color','b');
               return;
           end
           
           %% OR destination lane already in open
           for lmq = 1:length(open)
                openSingle = open(lmq);
                if openSingle.RoadNum == endPoint.RoadNum && openSingle.GeoNum == endPoint.GeoNum && openSingle.LaneNum == endPoint.LaneNum
                    current.RoadNum = endPoint.RoadNum;
                    current.GeoNum  = endPoint.GeoNum ;
                    current.LaneNum = endPoint.LaneNum ;
                    break;
                end
           end
           
           
           if current.RoadNum == endPoint.RoadNum && current.GeoNum == endPoint.GeoNum && current.LaneNum == endPoint.LaneNum 
               zzr =1;
               while(zzr <= size(prev,1))
                   if prev(zzr,4) == current.RoadNum && prev(zzr,5) == current.GeoNum && prev(zzr,6) ==  current.LaneNum
                       choose = choose +1;
                       chooseArr(choose,:) = prev(zzr,1:3);
                       current.RoadNum = prev(zzr,1);
                       current.GeoNum = prev(zzr,2);
                       current.LaneNum = prev(zzr,3);
                       zzr = 1;
                   else
                       zzr = zzr + 1;
                   end
               end
               
               pathList(length(pathList) +1) = line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',5,'color','b');
               for zzm = 1:size(chooseArr,1)-1
                   mLineMsg = getLineMsg(chooseArr(zzm,1),chooseArr(zzm,2),chooseArr(zzm,3));
                   if mLineMsg.linetype == "spiral"
                        pathList(length(pathList) +1) = spiralDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.curvStart,mLineMsg.curvEnd,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   elseif mLineMsg.linetype == "arc"
                        pathList(length(pathList) +1) = arcDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.curvature,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   elseif mLineMsg.linetype == "line"
                        pathList(length(pathList) +1) = lineDraw1(mLineMsg.x,mLineMsg.y,mLineMsg.hdg,mLineMsg.mlength,mLineMsg.offset,sign(chooseArr(zzm,3)));
                   end
               end
               pathList(length(pathList) +1) = line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',5,'color','b');
               return;
          end
               
           
           
           
           
           closelen = closelen + 1;
           close(closelen).RoadNum = current.RoadNum;
           close(closelen).GeoNum = current.GeoNum;
           close(closelen).LaneNum = current.LaneNum;
           open(f1(1,1)) =[];
           openlen = openlen -1;
           NeighborMsg = getNeighbor(current.RoadNum,current.GeoNum,current.LaneNum);
           for k = 1 : size(NeighborMsg,1)
%                currentNeighbor = NeighborMsg(k,:);
               neighbor.RoadNum =  NeighborMsg(k,1);
               neighbor.GeoNum =  NeighborMsg(k,2);
               neighbor.LaneNum =  NeighborMsg(k,3);
               LineMsg = getLineMsg(neighbor.RoadNum,neighbor.GeoNum,neighbor.LaneNum);
               neighbor.g = current.g + LineMsg.mlength;
               if LineMsg.linetype == "spiral"
                    [x_f,y_f] = getSpiralFinalXY(LineMsg.x,LineMsg.y,LineMsg.hdg,LineMsg.mlength,LineMsg.curvStart,LineMsg.curvEnd,LineMsg.offset,sign(neighbor.LaneNum));
               elseif LineMsg.linetype == "arc"
                    [x_f,y_f] = getArcFinalXY(LineMsg.x,LineMsg.y,LineMsg.hdg,LineMsg.mlength,LineMsg.curvature,LineMsg.offset,sign(neighbor.LaneNum));
               elseif LineMsg.linetype == "line"
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
                   if open(p).RoadNum == neighbor.RoadNum &&open(p).GeoNum == neighbor.GeoNum && open(p).LaneNum == neighbor.LaneNum
                           inOpenFlag = 1 ;
                           gscore = open(p).g;
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
               end
                   backNum = backNum+1;
                   prev(backNum,:) = [current.RoadNum,current.GeoNum,current.LaneNum,neighbor.RoadNum,neighbor.GeoNum,neighbor.LaneNum];
                   neighbor.g = temp_g;
                   neighbor.f = neighbor.g + neighbor.h;
               
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
    pathList
end
% end

%% 绘制螺旋线
 function handle = spiralDraw1(x_start,y_start,hdg,mlength,curvstart,curvEnd,offset,laneFlag)  
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
       handle = plot(ax,xs,ys,'linestyle','--');
%          arrowPlot1(ax,xs,ys,'linestyle','--','number',5);
    %% 右侧
    elseif laneFlag == -1
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
        end
        handle = plot(ax,xs,ys,'lineWidth',5,'color','b');
%          arrowPlot1(ax,xs,ys,'number',5);
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        end
       handle = plot(ax,xs,ys,'lineWidth',5,'color','b');
%          arrowPlot1(ax,xs,ys,'number',5);

    end
 end
 
%% 绘制直线
function  handle = lineDraw1(x,y,hdg,mlength,offset,laneFlag) 
     global ax;
     % 沿着s方向的偏移量
     dx = mlength * cos(hdg);
     dy = mlength * sin(hdg);
    %% 原始参考线
     if laneFlag == 0
        handle = line(ax,[x,x+dx],[y,y+dy],'linestyle','--','color','k');  
        quiver(ax,x,y,dx/2,dy/2,'linestyle','--');

    %% 右侧 基于s方向顺时针旋转
     elseif laneFlag == -1 
        x = x + offset*cos(hdg-pi/2);
        y = y + offset*sin(hdg-pi/2);
        handle = line(ax,[x,x+dx],[y,y+dy],'lineWidth',5,'color','b');

        quiver(ax,x,y,dx/2,dy/2);

    %% 左侧 基于s方向逆时针旋转
     else 
        x = x + offset*cos(hdg+pi/2);
        y = y + offset*sin(hdg+pi/2);
        handle = line(ax,[x,x+dx],[y,y+dy],'lineWidth',5,'color','b');
        quiver(ax,x,y,dx/2,dy/2);

     end
end

%% 绘制圆弧
function  handle = arcDraw1(x,y,hdg,mlength,curvature,offset,laneFlag)
    global ax;
    if laneFlag == 0
        n = 100;
        t = linspace(0,mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + curvature *t ));
        sinline = @(t)(sin(hdg + curvature *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end
       handle =  plot(ax,xs,ys,'linestyle','--');
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
        handle = plot(ax,xs,ys,'lineWidth',5,'color','b');      
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
        handle = plot(ax,xs,ys,'lineWidth',5,'color','b');
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
        
    currentRoad = getCrtRoadByNum(RoadNum);

    if isfield(currentRoad,'link')
        mlink = currentRoad.link;
        %　获取前继节点
        if isfield(mlink,'predecessor')
            mpredecessor = mlink.predecessor;
        end
 
        %  获取后续节点       
        if isfield(mlink,'successor')
            msuccessor = mlink.successor;
        end
     end
   %% 当前车道
    currentGeo = currentRoad.planView.geometry;
        if length(currentGeo) == 1
            if sign(LaneNum) == -1 
                %LaneNum为负，参考线右侧，但与参考线同向，下一车道处于下一Road
                if msuccessor.Attributes.elementType == "junction"
                    junctionId = str2double(msuccessor.Attributes.elementId);
                    for i = 1:length(junctions)
                        mjunction = getSingleObject(junctions,i);
                        if str2double(mjunction.Attributes.id) == junctionId
                            connections = mjunction.connection;
                            for i1 = 1 :length(connections)
                                mconnection = getSingleObject(connections,i1);
                                if str2double(mconnection.Attributes.incomingRoad) == RoadNum
                                    mlaneLinks = mconnection.laneLink;
                                    resRoadNum = str2double(mconnection.Attributes.connectingRoad);                           
                                    if mconnection.Attributes.contactPoint == "start"
                                        resGeoNum = 1;
                                    else
                                        resRoad = getCrtRoadByNum(resRoadNum);
                                        resGeoNum = length(resRoad.planView.geometry);
                                    end 
                                    
                                    for i2 = 1:length(mlaneLinks)
                                        mlaneLink = getSingleObject(mlaneLinks,i2);
                                        if str2double(mlaneLink.Attributes.from)==LaneNum
                                            resLaneNum = str2double(mlaneLink.Attributes.to);
                                            NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                                            break;
                                        end
                                    end
                                    continue;
                                end     
                            end
                            break;
                        end 
                    end 
                end
                
                if msuccessor.Attributes.elementType == "road"
                    resRoadNum = str2double(msuccessor.Attributes.elementId);
                    resRoad = getCrtRoadByNum(resRoadNum);
                    if msuccessor.Attributes.contactPoint == "start"
                        resGeoNum = 1;
                        resLaneNum = -1;
                    else
                        resGeoNum = length(resRoad.planView.geometry);
                        resLaneNum = 1;
                    end
                    NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                end
                               
            end
            
            if sign(LaneNum) == 1
                if mpredecessor.Attributes.elementType == "junction"
                    junctionId = str2double(mpredecessor.Attributes.elementId);
                    for i = 1:length(junctions)
                        mjunction = getSingleObject(junctions,i);
                        if str2double(mjunction.Attributes.id) == junctionId
                            connections = mjunction.connection;
                            for i1 = 1 :length(connections)
                                mconnection = getSingleObject(connections,i1);
                                if str2double(mconnection.Attributes.incomingRoad) == RoadNum
                                    mlaneLinks = mconnection.laneLink;
                                    resRoadNum = str2double(mconnection.Attributes.connectingRoad);                           
                                    if mconnection.Attributes.contactPoint == "start"
                                        resGeoNum = 1;
                                    else
                                        resRoad = getCrtRoadByNum(resRoadNum);
                                        resGeoNum = length(resRoad.planView.geometry);
                                    end 
 
                                    for i2 = 1:length(mlaneLinks)
                                        mlaneLink = getSingleObject(mlaneLinks,i2);
                                        if str2double(mlaneLink.Attributes.from)==LaneNum
                                            resLaneNum = str2double(mlaneLink.Attributes.to);
                                            NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                                            break;
                                        end
                                    end
                                    continue;
                                end     
                            end
                            break;
                        end 
                    end 
                end
                
               if mpredecessor.Attributes.elementType == "road"
                    resRoadNum = str2double(mpredecessor.Attributes.elementId);
                    resRoad = getCrtRoadByNum(resRoadNum);
                    if mpredecessor.Attributes.contactPoint == "start"
                        resGeoNum = 1;
                        resLaneNum = -1;
                    else
                        resGeoNum = length(resRoad.planView.geometry);
                        resLaneNum = 1;
                    end
                    NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum];                  
                end
                
            end
            
        end
        
        if length(currentGeo) >1 && sign(LaneNum) == -1 
            if GeoNum == length(currentGeo)
               %LaneNum为负，参考线右侧，但与参考线同向，下一车道处于下一Road
                if msuccessor.Attributes.elementType == "junction"
                    junctionId = str2double(msuccessor.Attributes.elementId);
                    for i = 1:length(junctions)
                        mjunction = getSingleObject(junctions,i);
                        if str2double(mjunction.Attributes.id) == junctionId
                            connections = mjunction.connection;
                            for i1 = 1 :length(connections)
                                mconnection = getSingleObject(connections,i1);
                                if str2double(mconnection.Attributes.incomingRoad) == RoadNum
                                    mlaneLinks = mconnection.laneLink;
                                    resRoadNum = str2double(mconnection.Attributes.connectingRoad);                           
                                    if mconnection.Attributes.contactPoint == "start"
                                        resGeoNum = 1;
                                    else
                                        resRoad = getCrtRoadByNum(resRoadNum);
                                        resGeoNum = length(resRoad.planView.geometry);
                                    end 
                                    
                                    for i2 = 1:length(mlaneLinks)
                                        mlaneLink = getSingleObject(mlaneLinks,i2);
                                        if str2double(mlaneLink.Attributes.from)==LaneNum
                                            resLaneNum = str2double(mlaneLink.Attributes.to);
                                            NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                                            break;
                                        end
                                    end
                                    continue;
                                end     
                            end
                            break;
                        end 
                    end 
                end
                
                if msuccessor.Attributes.elementType == "road"
                    resRoadNum = str2double(msuccessor.Attributes.elementId);
                    resRoad = getCrtRoadByNum(resRoadNum);
                    if msuccessor.Attributes.contactPoint == "start"
                        resGeoNum = 1;
                        resLaneNum = -1;
                    else
                        resGeoNum = length(resRoad.planView.geometry);
                        resLaneNum = 1;
                    end
                    NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                end
               
               
            end
            
            if GeoNum < length(currentGeo)
               resRoadNum = RoadNum;
               resGeoNum = GeoNum +1;
               resLaneNum = LaneNum;
               NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum];               
            end
            
        end
        
        if length(currentGeo) >1 && sign(LaneNum) == 1 
            if GeoNum == 1
                if mpredecessor.Attributes.elementType == "junction"
                    junctionId = str2double(mpredecessor.Attributes.elementId);
                    for i = 1:length(junctions)
                        mjunction = getSingleObject(junctions,i);
                        if str2double(mjunction.Attributes.id) == junctionId
                            connections = mjunction.connection;
                            for i1 = 1 :length(connections)
                                mconnection = getSingleObject(connections,i1);
                                if str2double(mconnection.Attributes.incomingRoad) == RoadNum
                                    mlaneLinks = mconnection.laneLink;
                                    resRoadNum = str2double(mconnection.Attributes.connectingRoad);                           
                                    if mconnection.Attributes.contactPoint == "start"
                                        resGeoNum = 1;
                                    else
                                        resRoad = getCrtRoadByNum(resRoadNum);
                                        resGeoNum = length(resRoad.planView.geometry);
                                    end 
 
                                    for i2 = 1:length(mlaneLinks)
                                        mlaneLink = getSingleObject(mlaneLinks,i2);
                                        if str2double(mlaneLink.Attributes.from)==LaneNum
                                            resLaneNum = str2double(mlaneLink.Attributes.to);
                                            NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum]; 
                                            break;
                                        end
                                    end
                                    continue;
                                end     
                            end
                            break;
                        end 
                    end 
                end
                
               if mpredecessor.Attributes.elementType == "road"
                    resRoadNum = str2double(mpredecessor.Attributes.elementId);
                    resRoad = getCrtRoadByNum(resRoadNum);
                    if mpredecessor.Attributes.contactPoint == "start"
                        resGeoNum = 1;
                        resLaneNum = -1;
                    else
                        resGeoNum = length(resRoad.planView.geometry);
                        resLaneNum = 1;
                    end
                    NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum];                  
                end
                
            end
                
            
            if GeoNum > 1
               resRoadNum = RoadNum;
               resGeoNum = GeoNum -1;
               resLaneNum = LaneNum;
               NeighborMsg = [NeighborMsg;resRoadNum,resGeoNum,resLaneNum];
            end
        end
end
            

%%　通过 Road,Geo,Lane获取相关信息
function LineMsg1 = getLineMsg(RoadNum,GeoNum,LaneNum)
    global roads;
    LineMsg1 = struct();
    for i =1:length(roads)
        if str2double(roads{1,i}.Attributes.id) == RoadNum
            Geos = roads{1,i}.planView.geometry;
            for j = 1:length(Geos)
                currentGeo = getSingleObject(Geos,j); 
                if j == GeoNum
                LineMsg1.s = str2double(currentGeo.Attributes.s);
                LineMsg1.x = str2double(currentGeo.Attributes.x);
                LineMsg1.y = str2double(currentGeo.Attributes.y);
                LineMsg1.hdg = str2double(currentGeo.Attributes.hdg);
                LineMsg1.mlength = str2double(currentGeo.Attributes.length);
                if isfield(currentGeo,'line')
                    LineMsg1.linetype = 'line';
                    LineMsg1.curvStart = NaN;
                    LineMsg1.curvEnd =   NaN;
                    LineMsg1.curvature = NaN;
                end
                
                if isfield(currentGeo,'spiral')
                    LineMsg1.linetype = 'spiral';
                    LineMsg1.curvStart = str2double(currentGeo.spiral.Attributes.curvStart);
                    LineMsg1.curvEnd = str2double(currentGeo.spiral.Attributes.curvEnd);
                    LineMsg1.curvature = NaN;
                end
                if isfield(currentGeo,'arc')
                    LineMsg1.linetype = 'arc';
                    LineMsg1.curvStart = NaN;
                    LineMsg1.curvEnd =   NaN;
                    LineMsg1.curvature = str2double(currentGeo.arc.Attributes.curvature);
                end
                    break;
                end
            end
            
            LaneSections = roads{1,i}.lanes.laneSection;
%             crtLaneSection = getSingleObject(LaneSections,1)
            if length(LaneSections) == 1
                crtLaneSection = LaneSections(1);
            else
                crtLaneSection = LaneSections{1,1};
            end
            if sign(LaneNum) == -1
                lanes = crtLaneSection.right.lane;
            end
            if sign(LaneNum) == 1
                lanes = crtLaneSection.left.lane;
            end
            for k = 1:length(lanes)
                crtlane = getSingleObject(lanes,k);
                if str2double(crtlane.Attributes.id) == LaneNum
                    LineMsg1.offset = str2double(crtlane.width.Attributes.a);
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

% get Road obj by Number
function target =  getCrtRoadByNum(num)
    global roads;
    for z = 1:length(roads)
        if str2double(roads{1,z}.Attributes.id) == num
        target = roads{1,z};
        break;
        end
    end
    
end

