function ROADS = OpenDriveGetRoadNet(fileName)

%% 常量定义--------------------------------------------------------
default_speed_limit = 30;                                                   % 缺省限速 30 km/h
default_speed_limit = default_speed_limit / 3.6;                            % 换算成 m/s
%% 数据读入--------------------------------------------------------
MAP = xml2struct(fileName);                          % 读取 OpenDRIVE 文件（xml格式）
MAP = MAP.OpenDRIVE;                                                        % 结构体简化
  
  % MAP.header: <1x1 struct>
  % MAP.road: <1x? cell>
  %  |- MAP.road{1,1}:   link: [1x1 struct] - MAP.road{1,1}.link.predecessor.{elementId, elementType, contactPoint}
  %                                        |- MAP.road{1,1}.link.successor.{elementId, elementType, contactPoint}
  %                       planView: [1x1 struct]
  %               elevationProfile: [1x1 struct]
  %                 lateralProfile: [1x1 struct]
  %                          lanes: [1x1 struct]
  %                        objects: [1x1 struct]
  %                        signals: [1x1 struct]
  %                        surface: [1x1 struct]
  %                     Attributes: [1x1 struct] - MAP.road{1,1}.Attributes.{id, junction, length, name}
  % MAP.junction: <1x? cell>
  %  |- MAP.junction{1,1}:    connection: {[1x1 struct]  [1x1 struct] - MAP.junction{1,1}.connection{1,1}.laneLink{1,1}.Attributes.{from, to}
  %                                                                  |- MAP.junction{1,1}.connection{1,1}.Attributes.{connectingRoad, contactPoint, id, incomingRoad}                                                                      
  %                           Attributes: [1x1 struct] - MAP.junction{1,1}.Attributes.{id, name}

%% 路网结构体定义---------------------------------------------------
ROADS = struct('id', [], 'length', [], 'left_min_time', [], 'right_min_time', [], 'start_x', [], 'start_y', [], 'end_x', [], 'end_y', [], 'left_successor_road_id', [], 'left_successor_road_lane', [], 'right_successor_road_id', [], 'right_successor_road_lane', []);
  
  %                            id: []  road编号
  %                        length: []  road长度
  %                 left_min_time: []  考虑限速，left lane（road反向）最短通行时间
  %                right_min_time: []  考虑限速，right lane（road同向）最短通行时间
  %                       start_x: []  road起点 x 坐标
  %                       start_y: []  road起点 y 坐标
  %                         end_x: []  road终点 x 坐标
  %                         end_y: []  road终点 y 坐标
  %        left_successor_road_id: []  左侧lane（road反向）的后序road编号
  %      left_successor_road_lane: []  左侧lane（road反向）的后序lane方向（右侧-1同向, 左侧+1反向）
  %       right_successor_road_id: []  右侧lane（road反向）的后序road编号
  %     right_successor_road_lane: []  右侧lane（road反向）的后序lane方向（右侧-1同向, 左侧+1反向）

%% 路网信息录入----------------------------------------------------
road_num = size(MAP.road);
road_num = road_num(1,2);                                                   % road_num: 全地图中road数量
for i = 1:1:road_num
    % road id--------------------------------------------------------------
    id = MAP.road{1,i}.Attributes.id;
    id = str2double(id);                                                       % 读取road id
    ROADS(id).id = id;                                                      % 写入road id
    
    % road length----------------------------------------------------------
    ROADS(id).length = str2double(MAP.road{1,i}.Attributes.length);            % 写入road length
    
    % Start_x, Start_y-----------------------------------------------------
    geometry_num = size(MAP.road{1,i}.planView.geometry);
    geometry_num = geometry_num(1,2);
    
    finalGeo = getSingleObject(MAP.road{1,i}.planView.geometry,geometry_num);
    finalGeoMsg = OpenDriveGetGeoMsg(finalGeo);
    if strcmp(finalGeoMsg.lineType,'line')
        [ROADS(id).end_x,ROADS(id).end_y,~] = CoorGetFinalLine(finalGeoMsg,finalGeoMsg.mlength);
    elseif strcmp(finalGeoMsg.lineType,'arc')
        [ROADS(id).end_x,ROADS(id).end_y,~] = CoorGetFinalArc(finalGeoMsg,finalGeoMsg.mlength);   
    elseif strcmp(finalGeoMsg.lineType,'spiral')
        [ROADS(id).end_x,ROADS(id).end_y,~] = CoorGetFinalSpiral(finalGeoMsg,finalGeoMsg.mlength);
    end
    
    if geometry_num ==1
        ROADS(id).start_x = str2double(MAP.road{1,i}.planView.geometry.Attributes.x);  % road起点的 x 坐标
        ROADS(id).start_y = str2double(MAP.road{1,i}.planView.geometry.Attributes.y);  % road起点的 y 坐标 
    elseif geometry_num > 1
        ROADS(id).start_x = str2double(MAP.road{1,i}.planView.geometry{1,1}.Attributes.x);  % road起点的 x 坐标
        ROADS(id).start_y = str2double(MAP.road{1,i}.planView.geometry{1,1}.Attributes.y);  % road起点的 y 坐标  
    end
    hasRightSuc = 0;
    if isfield(MAP.road{1,i}.link,'successor')
        hasRightSuc = 1;
    end
    hasLeftSuc = 0;
    if isfield(MAP.road{1,i}.link,'predecessor')
        hasLeftSuc = 1;
    end
    
    % right successor------------------------------------------------------------
    if hasRightSuc&&strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'road')
        ROADS(id).right_successor_road_id = str2double(MAP.road{1,i}.link.successor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.successor.Attributes.contactPoint, 'start')
            ROADS(id).right_successor_road_lane = -1;
        else
            ROADS(id).right_successor_road_lane = 1;   
        end     
    elseif hasRightSuc&&strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   % 当前地图中junction的数量
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.successor.Attributes.elementId)==0
                continue;
            end
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                           % 当前junction中connection的数量
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= id
                    continue;
                end
                ROADS(id).right_successor_road_id(p) = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(id).right_successor_road_lane(p) = -1;
                else
                   ROADS(id).right_successor_road_lane(p) = 1;                
                end
                p = p + 1;
            end
        end
    end

    % left successor------------------------------------------------------------
    if hasLeftSuc&&strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'road')
        ROADS(id).left_successor_road_id = str2double(MAP.road{1,i}.link.predecessor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.predecessor.Attributes.contactPoint, 'start')
            ROADS(id).left_successor_road_lane = -1;
        else
            ROADS(id).left_successor_road_lane = 1;   
        end    
    elseif hasLeftSuc&&strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   % 当前地图中junction的数量
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.predecessor.Attributes.elementId)==0
                continue;
            end
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                           % 当前junction中connection的数量
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= id
                    continue;
                end
                ROADS(id).left_successor_road_id(p) = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(id).left_successor_road_lane(p) = -1;
                else
                   ROADS(id).left_successor_road_lane(p) = 1;                
                end
                p = p + 1;
            end
        end
    end
                

        
    
%{    
    % min_time-------------------------------------------------------------
    ROADS(id).left_min_time = inf;
    ROADS(id).right_min_time = inf;
    lane_section_num = size(MAP.road{1,i}.lanes.laneSection);
    lane_section_num = lane_section_num(1,2);                               % lane_section_num：当前road中lane section的数量
    left_lane_time = 0;
    right_lane_time = 0;
    for j = 1:1:lane_section_num-1
        section_length = str2num(MAP.road{1,i}.lanes.laneSection{1,j+1}.Attributes.s) - str2num(MAP.road{1,i}.lanes.laneSection{1}.Attributes.s);
        left_speed_limit = default_speed_limit;                             % 缺省速度限制
        right_speed_limit = default_speed_limit;                            % 缺省速度限制
        left_lane_num = size(MAP.road{1,i}.lanes.laneSection{1,j+1}.left.lane);
        left_lane_num = left_lane_num(1,2);                                 % 当前section左侧车道数
        right_lane_num = size(MAP.road{1,i}.lanes.laneSection{1,j+1}.right.lane);
        right_lane_num = right_lane_num(1,2);                               % 当前section右侧车道数        
        
        for k = 1:1:left_lane_num

            left_speed_limit = max(left_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1,k}.speed.Attributes.max);  % 当前section左侧所有车道的最大限速                                    
            left_lane_time = left_lane_time + (section_length / left_speed_limit);      % 左侧lane累计通行时间
            
            if (MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1.1}.speed.Attributes.max)
              right_speed_limit = max(right_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1,k}.speed.Attributes.max);
            end;                                                            % 当前section左侧所有车道的最大限速
            right_lane_time = right_lane_time + (section_length / right_speed_limit);      % 右侧lane累计通行时间           
            
        end;
    section_length = ROADS(id).length - str2num(MAP.road{1,i}.lanes.laneSection{1}.Atributes.s);
    if (MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1.1}.speed.Attributes.max)
      left_speed_limit = max(left_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1,k}.speed.Attributes.max);
    end;                                                                    % 当前section左侧所有车道的最大限速
    left_lane_time = left_lane_time + (section_length / left_speed_limit);  % 左侧lane累计通行时间
            
    if (MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1.1}.speed.Attributes.max)
      right_speed_limit = max(right_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1,k}.speed.Attributes.max);
    end;                                                                    % 当前section左侧所有车道的最大限速
    right_lane_time = right_lane_time + (section_length / right_speed_limit);  % 右侧lane累计通行时间       
       
    if (left_lane_time)
        ROADS(id).left_min_time = left_lane_time;                           % 当前road左侧最小通行时间
    end;                                                            
    if (right_lane_time)
        ROADS(id).right_min_time = right_lane_time;                         % 当前road右侧最小通行时间 
    end;                                                                       
            
            
    end;
%} 
    
    
end  
fprintf("RoadNet Created OK !");
end

