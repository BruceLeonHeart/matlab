clear;
clc;

%% ��������--------------------------------------------------------
default_speed_limit = 30;                                                   % ȱʡ���� 30 km/h
default_speed_limit = default_speed_limit / 3.6;                            % ����� m/s

%% ���ݶ���--------------------------------------------------------
MAP = xml2struct( 'opendrive_demo_20190516.xml' );                          % ��ȡ OpenDRIVE �ļ���xml��ʽ��
MAP = MAP.OpenDRIVE;                                                        % �ṹ���
  
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

%% ·���ṹ�嶨��---------------------------------------------------
ROADS = struct('id', [], 'length', [], 'left_min_time', [], 'right_min_time', [], 'start_x', [], 'start_y', [], 'end_x', [], 'end_y', [], 'left_successor_road_id', [], 'left_successor_road_lane', [], 'right_successor_road_id', [], 'right_successor_road_lane', []);
  
  %                            id: []  road���
  %                        length: []  road����
  %                 left_min_time: []  �������٣�left lane��road�������ͨ��ʱ��
  %                right_min_time: []  �������٣�right lane��roadͬ�����ͨ��ʱ��
  %                       start_x: []  road��� x ����
  %                       start_y: []  road��� y ����
  %                         end_x: []  road�յ� x ����
  %                         end_y: []  road�յ� y ����
  %        left_successor_road_id: []  ���lane��road���򣩵ĺ���road���
  %      left_successor_road_lane: []  ���lane��road���򣩵ĺ���lane�����Ҳ�-1ͬ��, ���+1����
  %       right_successor_road_id: []  �Ҳ�lane��road���򣩵ĺ���road���
  %     right_successor_road_lane: []  �Ҳ�lane��road���򣩵ĺ���lane�����Ҳ�-1ͬ��, ���+1����

%% ·����Ϣ¼��----------------------------------------------------
road_num = size(MAP.road);
road_num = road_num(1,2);                                                   % road_num: ȫ��ͼ��road����
for i = 1:1:road_num
    % road id--------------------------------------------------------------
    id = MAP.road{1,i}.Attributes.id;
    id = str2num(id);                                                       % ��ȡroad id
    ROADS(id).id = id;                                                      % д��road id
    
    % road length----------------------------------------------------------
    ROADS(id).length = str2num(MAP.road{1,i}.Attributes.length);            % д��road length
    
    % Start_x, Start_y-----------------------------------------------------
    geometry_num = size(MAP.road{1,i}.planView.geometry);
    geometry_num = geometry_num(1,2);
    if geometry_num ==1
        ROADS(id).start_x = str2num(MAP.road{1,i}.planView.geometry.Attributes.x);  % road���� x ����
        ROADS(id).start_y = str2num(MAP.road{1,i}.planView.geometry.Attributes.y);  % road���� y ���� 
    elseif geometry_num > 1
        ROADS(id).start_x = str2num(MAP.road{1,i}.planView.geometry{1,1}.Attributes.x);  % road���� x ����
        ROADS(id).start_y = str2num(MAP.road{1,i}.planView.geometry{1,1}.Attributes.y);  % road���� y ����  
    end;
 
    % right successor------------------------------------------------------------
    if strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'road')
        ROADS(id).right_successor_road_id = str2num(MAP.road{1,i}.link.successor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.successor.Attributes.contactPoint, 'start')
            ROADS(id).right_successor_road_lane = -1;
        else
            ROADS(id).right_successor_road_lane = 1;   
        end;     
    elseif strcmp(MAP.road{1,i}.link.successor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   % ��ǰ��ͼ��junction������
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.successor.Attributes.elementId)==0
                continue;
            end;
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                           % ��ǰjunction��connection������
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2num(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= i
                    continue;
                end;
                ROADS(id).right_successor_road_id(p) = str2num(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(id).right_successor_road_lane(p) = -1;
                else
                   ROADS(id).right_successor_road_lane(p) = 1;                
                end;
                p = p + 1;
            end;
        end;
    end;

    % left successor------------------------------------------------------------
    if strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'road')
        ROADS(id).left_successor_road_id = str2num(MAP.road{1,i}.link.predecessor.Attributes.elementId);
        if strcmp(MAP.road{1,i}.link.predecessor.Attributes.contactPoint, 'start')
            ROADS(id).left_successor_road_lane = -1;
        else
            ROADS(id).left_successor_road_lane = 1;   
        end;     
    elseif strcmp(MAP.road{1,i}.link.predecessor.Attributes.elementType, 'junction')
        junction_num = size(MAP.junction);
        junction_num = junction_num(1,2);                                   % ��ǰ��ͼ��junction������
        for m = 1:1:junction_num
            if strcmp(MAP.junction{1,m}.Attributes.id, MAP.road{1,i}.link.predecessor.Attributes.elementId)==0
                continue;
            end;
            connection_num = size(MAP.junction{1,m}.connection);
            connection_num = connection_num(1,2);                           % ��ǰjunction��connection������
            p = 1;
            for n = 1:1:connection_num
                incomingRoad = str2num(MAP.junction{1,m}.connection{1,n}.Attributes.incomingRoad);
                if incomingRoad ~= i
                    continue;
                end;
                ROADS(id).left_successor_road_id(p) = str2num(MAP.junction{1,m}.connection{1,n}.Attributes.connectingRoad);
                if strcmp(MAP.junction{1,m}.connection{1,n}.Attributes.contactPoint, 'start')
                   ROADS(id).left_successor_road_lane(p) = -1;
                else
                   ROADS(id).left_successor_road_lane(p) = 1;                
                end;
                p = p + 1;
            end;
        end;
    end;
                

        
    
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
    
    
end;

  
  
  