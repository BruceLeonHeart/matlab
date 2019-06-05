function ROADS = roadNetParse(openDriveObj)

%% constant Def.--------------------------------------------------------
default_speed_limit = 30;                                                   % default speed 30 km/h
default_speed_limit = default_speed_limit / 3.6;                            % change to m/s

%% data Input --------------------------------------------------------
% MAP = xml2struct( 'demomap.xml' );                          % read OpenDRIVE File
% MAP = MAP.OpenDRIVE;    
MAP = openDriveObj;

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

%% Definition for RoadNet---------------------------------------------------
ROADS = struct('id', [], 'length', [], 'left_min_time', [], 'right_min_time', [], 'start_x', [], 'start_y', [], 'end_x', [], 'end_y', [], 'left_successor_road_id', [], 'left_successor_road_lane', [], 'right_successor_road_id', [], 'right_successor_road_lane', []);
  
  %                            id: []  road index
  %                        length: []  road length
  %                 left_min_time: []  based on speed . min time cost
  %                right_min_time: []  based on speed . min time cost
  %                       start_x: []  road start x 
  %                       start_y: []  road start y
  %                         end_x: []  road end x
  %                         end_y: []  road end y
  %        left_successor_road_id: []  
  %      left_successor_road_lane: []  
  %       right_successor_road_id: []  
  %     right_successor_road_lane: []  

%% Init RoadNet----------------------------------------------------
road_num = size(MAP.road);
road_num = road_num(1,2);                                                   
for i = 1:1:road_num
    % road id--------------------------------------------------------------
    id = MAP.road{1,i}.Attributes.id;
    id = str2double(id);                                                      
    ROADS(i).id = id;                                                  
    
    % road length----------------------------------------------------------
    ROADS(i).length = str2double(MAP.road{1,i}.Attributes.length);          
    
    % Start_x, Start_y-----------------------------------------------------
    geometry_num = size(MAP.road{1,i}.planView.geometry);
    geometry_num = geometry_num(1,2);
    finalGeo = getSingleObject(MAP.road{1,i}.planView.geometry,geometry_num);
    finalGeoMsg = getMsgFromGeo(finalGeo);
    if strcmp(finalGeoMsg.lineType,'line')
        [ROADS(i).end_x,ROADS(i).end_y] = getLineFinalXY(finalGeoMsg.x,finalGeoMsg.y,finalGeoMsg.hdg,finalGeoMsg.mlength,0,0);
    elseif strcmp(finalGeoMsg.lineType,'arc')
        [ROADS(i).end_x,ROADS(i).end_y] = getArcFinalXY(finalGeoMsg.x,finalGeoMsg.y,finalGeoMsg.hdg,finalGeoMsg.mlength,finalGeoMsg.curvature,0,0);   
    elseif strcmp(finalGeoMsg.lineType,'spiral')
        [ROADS(i).end_x,ROADS(i).end_y] = getSpiralFinalXY(finalGeoMsg.x,finalGeoMsg.y,finalGeoMsg.hdg,finalGeoMsg.mlength,finalGeoMsg.curvStart,finalGeoMsg.curvEnd,offset,laneFlag);
    end
    
    if geometry_num ==1
        ROADS(i).start_x = str2double(MAP.road{1,i}.planView.geometry.Attributes.x);  
        ROADS(i).start_y = str2double(MAP.road{1,i}.planView.geometry.Attributes.y);   
    elseif geometry_num > 1
        ROADS(i).start_x = str2double(MAP.road{1,i}.planView.geometry{1,1}.Attributes.x);  
        ROADS(i).start_y = str2double(MAP.road{1,i}.planView.geometry{1,1}.Attributes.y);    
    end
 
    % right successor------------------------------------------------------------
    if strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'road')
        ROADS(i).right_successor_road_id = str2double(MAP.road{1,i}.link.successor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.successor.Attributes.contactPoint, 'start')
            ROADS(i).right_successor_road_lane = -1;
        else
            ROADS(i).right_successor_road_lane = 1;   
        end    
    elseif strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.successor.Attributes.elementId)==0
                continue;
            end
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                          
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= i
                    continue;
                end
                ROADS(i).right_successor_road_id(p) = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(i).right_successor_road_lane(p) = -1;
                else
                   ROADS(i).right_successor_road_lane(p) = 1;                
                end
                p = p + 1;
            end
        end
    end

    % left successor------------------------------------------------------------
    if strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'road')
        ROADS(i).left_successor_road_id = str2double(MAP.road{1,i}.link.predecessor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.predecessor.Attributes.contactPoint, 'start')
            ROADS(i).left_successor_road_lane = -1;
        else
            ROADS(i).left_successor_road_lane = 1;   
        end     
    elseif strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   % ��ǰ��ͼ��junction������
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.predecessor.Attributes.elementId)==0
                continue;
            end
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                           % ��ǰjunction��connection������
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= i
                    continue;
                end
                ROADS(i).left_successor_road_id(p) = str2double(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(i).left_successor_road_lane(p) = -1;
                else
                   ROADS(i).left_successor_road_lane(p) = 1;                
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
    lane_section_num = lane_section_num(1,2);                               % lane_section_num����ǰroad��lane section������
    left_lane_time = 0;
    right_lane_time = 0;
    for j = 1:1:lane_section_num-1
        section_length = str2num(MAP.road{1,i}.lanes.laneSection{1,j+1}.Attributes.s) - str2num(MAP.road{1,i}.lanes.laneSection{1}.Attributes.s);
        left_speed_limit = default_speed_limit;                             % ȱʡ�ٶ�����
        right_speed_limit = default_speed_limit;                            % ȱʡ�ٶ�����
        left_lane_num = size(MAP.road{1,i}.lanes.laneSection{1,j+1}.left.lane);
        left_lane_num = left_lane_num(1,2);                                 % ��ǰsection��೵����
        right_lane_num = size(MAP.road{1,i}.lanes.laneSection{1,j+1}.right.lane);
        right_lane_num = right_lane_num(1,2);                               % ��ǰsection�Ҳ೵����        
        
        for k = 1:1:left_lane_num

            left_speed_limit = max(left_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1,k}.speed.Attributes.max);  % ��ǰsection������г������������                                    
            left_lane_time = left_lane_time + (section_length / left_speed_limit);      % ���lane�ۼ�ͨ��ʱ��
            
            if (MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1.1}.speed.Attributes.max)
              right_speed_limit = max(right_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1,k}.speed.Attributes.max);
            end;                                                            % ��ǰsection������г������������
            right_lane_time = right_lane_time + (section_length / right_speed_limit);      % �Ҳ�lane�ۼ�ͨ��ʱ��           
            
        end;
    section_length = ROADS(id).length - str2num(MAP.road{1,i}.lanes.laneSection{1}.Atributes.s);
    if (MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1.1}.speed.Attributes.max)
      left_speed_limit = max(left_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.left.lane{1,k}.speed.Attributes.max);
    end;                                                                    % ��ǰsection������г������������
    left_lane_time = left_lane_time + (section_length / left_speed_limit);  % ���lane�ۼ�ͨ��ʱ��
            
    if (MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1.1}.speed.Attributes.max)
      right_speed_limit = max(right_speed_limit, MAP.road{1,i}.lanes.laneSection{1,j}.right.lane{1,k}.speed.Attributes.max);
    end;                                                                    % ��ǰsection������г������������
    right_lane_time = right_lane_time + (section_length / right_speed_limit);  % �Ҳ�lane�ۼ�ͨ��ʱ��       
       
    if (left_lane_time)
        ROADS(id).left_min_time = left_lane_time;                           % ��ǰroad�����Сͨ��ʱ��
    end;                                                            
    if (right_lane_time)
        ROADS(id).right_min_time = right_lane_time;                         % ��ǰroad�Ҳ���Сͨ��ʱ�� 
    end;                                                                       
            
            
    end;
%} 
    
    
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
