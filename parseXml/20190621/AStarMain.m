%%　A星寻径算法主入口
% startPoint:起始点
% endPoint:终止点
% roadNet:　路网
function  mPath = AStarMain(startPoint,endPoint,roadNet)
    mPath = [];
    %%创建open与close的存储空间
    closedSet = struct('id',[],'direction',[],'gCost',[],'hCost',[],'fCost',[],'x',[],'y',[]);
    closelen = 0;
    openSet = struct('id',[],'direction',[],'gCost',[],'hCost',[],'fCost',[],'x',[],'y',[]);
    openlen = 0;
    
    
      %% 如果终点落在起点与第一个要去的点中间，则直接返回
        %包含两种情况：roadNum与GeoNum一致
        %roadNum与GeoNum不一致
        
    if startPoint.RoadNum == endPoint.RoadNum && startPoint.direction == endPoint.direction
        if startPoint.direction == -1  && startPoint.s_inGeo <=  endPoint.s_inGeo%右侧
            mPath = [startPoint.RoadNum startPoint.direction];
            return;
        end
        
        if startPoint.direction == 1  && startPoint.s_inGeo >  endPoint.s_inGeo%左侧
            mPath = [startPoint.RoadNum startPoint.direction];
            return;
        end               
    end
        
    %% 添加起点进入openSet
    openlen = openlen + 1;
    openSet(1).x = startPoint.x_e_offset; %final x
    openSet(1).y = startPoint.y_e_offset; %final y
    openSet(1).gCost = CoorGetDis(startPoint.x_e_offset,startPoint.y_e_offset,startPoint.x_offset,startPoint.y_offset);
    openSet(1).hCost = CoorGetDis(startPoint.x_e_offset,startPoint.y_e_offset,endPoint.x_offset,endPoint.y_offset);
    openSet(1).fCost = openSet(1).gCost + openSet(1).hCost;
    openSet(1).id = startPoint.RoadNum;
    openSet(1).direction = startPoint.direction;
    
    prev = []; %前后关系连接矩阵;col 1: road;col 2:direction
    
    
    while openlen >0
        postion = getCrtFromOpenSet(openSet,openlen);
        current = openSet(postion);       
        %% 如果终点所在road/direction已出现在OpenSet中，即便fCost当前不为最小，仍将该选择置为current，来结束搜索。
    
%         if isInSet(endPoint.roadNum,endPoint.direction,openSet)&&closelen~=0
%             current.id = endPoint.roadNum;
%             current.direction = endPoint.direction;
%         end
        
        %% 如果current　road/direction　与终点一致，则回溯路径，结束遍历
        if current.id == endPoint.RoadNum && current.direction == endPoint.direction && closelen~=0
            mPath = reconstruction(current,prev,mPath);
            mPath = [endPoint.RoadNum,endPoint.direction;mPath];%添加结束点的road/direction
            return;
        end
        
        %% 将current添加到closeSet中
        closelen = closelen + 1;
        closedSet(closelen).id = current.id;
        closedSet(closelen).direction = current.direction;
        openSet(postion) = []; % remove current 
        openlen = openlen -1; % remove current
        
        %% 遍历邻居
        NeighborSet = getNeighborSetFromRoadNet(current.id,current.direction,roadNet);
%         if isempty(NeighborSet)
%             continue;
%         end
        for j = 1 :size(NeighborSet,1)
            neighbor.id = NeighborSet(j,1);
            neighbor.direction = NeighborSet(j,2);
                    
               %% 如果current　road/direction　与终点一致，则回溯路径，结束遍历
            if neighbor.id == endPoint.RoadNum && neighbor.direction == endPoint.direction&&closelen~=0
                mPath = reconstruction(current,prev,mPath);
                mPath = [current.id,current.direction;mPath];
                mPath = [endPoint.RoadNum,endPoint.direction;mPath];%添加结束点的road/direction
                return;
            end
            
                       
            if isInSet(neighbor.id,neighbor.direction,closedSet)
                continue;
            end
            
            temp_gCost = AStarGetGCost(current,neighbor,roadNet); %本次的预计gCost
            
            if ~isInSet(neighbor.id,neighbor.direction,openSet) %不在OpenSet中，加入
               openlen = openlen + 1;
               openSet(openlen).id = neighbor.id;
               openSet(openlen).direction = neighbor.direction;
               openSet(openlen).x = roadNet(neighbor.id).end_x;
               openSet(openlen).y = roadNet(neighbor.id).end_y;
               openSet(openlen).gCost = AStarGetGCost(current,neighbor,roadNet); 
               openSet(openlen).hCost = AStarGetHCost(endPoint,neighbor,roadNet);
               openSet(openlen).fCost = openSet(openlen).gCost + openSet(openlen).hCost;
            elseif isInSet(neighbor.id,neighbor.direction,openSet) %在OpenSet中，判断与原来的gCost对比判断是否需要更新
                originMsg = getMsgFromSet(neighbor.id,neighbor.direction,openSet);
                gScore = originMsg.gCost;
                if temp_gCost >= gScore %比原来大，不可以更新
                    continue;
                end
            end
            
            prev = [prev;current.id,current.direction,neighbor.id,neighbor.direction];
            %更新OpenSet
            openSet = updateOpenSet(openSet,neighbor.id,neighbor.direction,temp_gCost);
            
        end
        
    end %end for while openlen>0
    
end


%% 判断某Road的某direction是否已处于Set中
function mFlag = isInSet(roadNum,direction,mSet)
    mFlag = 0;
    for i = 1:length(mSet)
        if mSet(i).id == roadNum && mSet(i).direction == direction
            mFlag = 1;
            break;
        end
    end
end

%% 通过路网获取邻居集合
function NeighborSet = getNeighborSetFromRoadNet(id,direction,roadNet)
    NeighborSet = [];
    crtRoad = roadNet(id);   
    if direction == -1 %右侧
        roadSet = crtRoad.right_successor_road_id;
        directionSet = crtRoad.right_successor_road_lane;
    elseif direction ==1 % 左侧
        roadSet = crtRoad.left_successor_road_id;
        directionSet = crtRoad.left_successor_road_lane;
    end
    
    if length(roadSet) == length(directionSet)
        for i = 1:length(roadSet)
            NeighborSet(i,:) = [roadSet(i),directionSet(i)];
        end
    else
        fprintf("邻居道路数目与方向数目不匹配，请检查数据源");
        fprintf("邻居道路数目与方向数目不匹配，请检查数据源1");
    end
end

%% 通过 min(fCost)获取current
function position = getCrtFromOpenSet(openSet,openlen)
f = []; 
for i = 1:openlen
   f(i,:) = [i , openSet(i).fCost];
end
f1 = sortrows(f,2);
position = f1(1,1)
end

%% 回溯矩阵获得路径
function mPath = reconstruction(current,prev,mPath)
    i = 1;
    while(i<=size(prev,1))
        if prev(i,3) == current.id && prev(i,4) == current.direction
            mPath = [mPath;prev(i,1:2)];
            current.id = prev(i,1);
            current.direction = prev(i,2);
            i = 1;
        else
            i = i+1;
        end
    end
end

%% 获取Set中的详细信息
function msg = getMsgFromSet(id,direction,mSet)
    msg = struct();
    for i = 1 :length(mSet)
        if mSet(i).id == id && mSet(i).direction == direction
           msg = mSet(i);
        end
    end
end

%% 更新OpenSet
function OpenSet = updateOpenSet(OpenSet,id,direction,temp_gCost)
    for i = 1:length(OpenSet)
        if OpenSet(i).id == id && OpenSet(i).direction == direction
            OpenSet(i).gCost = temp_gCost;
            OpenSet(i).fCost = OpenSet(i).gCost + OpenSet(i).hCost;
            break;
        end
    end  
end
