clc;
close all;
clear;
fileObj = xml2struct('demo_prescan.xml');
% fileObj = xml2struct('Crossing8Course.xml');
% fileObj = xml2struct('MAP.xml');
openDriveObj = fileObj.OpenDRIVE;
roadObj = openDriveObj.road;
roadNum = length(roadObj);
linkedRoad = zeros(roadNum); 
for i = 1:roadNum
     q = str2double(roadObj{1,i}.link.successor.Attributes.elementId);
     linkedRoad(i,q) = 1;
end
format long;
map = figure('Name','mapViwer','color','green');
figure(map);
hold on
axis([-180 180 -50 150]);
axis equal;

roadDrawFlag = zeros(1,roadNum);
k = 1;
while ~all(roadDrawFlag)
    tempGeoList = roadObj{1,k}.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    laneSectionList = roadObj{1,k}.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    if isstruct(laneSectionList)
            temp_laneSection = laneSectionList(1);
    end
    if iscell(laneSectionList)
            temp_laneSection = laneSectionList{1};
    end 
    for m = 1:tempGeoListSize
        %工具里面的tempGeoList只有一种属性时，显示为结构体，其余属于cell
        if isstruct(tempGeoList)
            temp_tempGeo = tempGeoList(m);
        end
        if iscell(tempGeoList)
            temp_tempGeo = tempGeoList{m};
        end 
               
        if isfield(temp_tempGeo,'line')
            line_x = str2double (temp_tempGeo.Attributes.x);
            line_y = str2double (temp_tempGeo.Attributes.y);
            temp_length = str2double (temp_tempGeo.Attributes.length);
            line_hdg = str2double(temp_tempGeo.Attributes.hdg);
            lineDraw(line_x,line_y,line_hdg,temp_length,0.0,0);
            if isfield(temp_laneSection,'left')
                offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                lineDraw(line_x,line_y,line_hdg,temp_length,offset,1);
            else
                offset = str2double(temp_laneSection.right.lane(1).width.Attributes.a);
                lineDraw(line_x,line_y,line_hdg,temp_length,offset,-1);    
            end
        end
               
        if isfield(temp_tempGeo,'arc')
            temp_c = str2double (temp_tempGeo.arc.Attributes.curvature);
            temp_hdg = str2double(temp_tempGeo.Attributes.hdg);
            temp_x = str2double (temp_tempGeo.Attributes.x);
            temp_y = str2double (temp_tempGeo.Attributes.y);
            temp_length = str2double (temp_tempGeo.Attributes.length);
            arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,0.0,0)
            if isfield(temp_laneSection,'left')
                offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,1);
            else
                offset = str2double(temp_laneSection.right.lane(1).width.Attributes.a);
                arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,-1);   
            end                
        end
        
        if isfield(temp_tempGeo,'spiral')
            spiral_x = str2double (temp_tempGeo.Attributes.x);
            spiral_y = str2double (temp_tempGeo.Attributes.y);
            temp_hdg = str2double(temp_tempGeo.Attributes.hdg);
            temp_length = str2double (temp_tempGeo.Attributes.length);
            curv_start = str2double (temp_tempGeo.spiral.Attributes.curvStart);
            curv_end = str2double (temp_tempGeo.spiral.Attributes.curvEnd);            
            spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,0.0,0);
            if isfield(temp_laneSection,'left')
                offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,1);
            else
                offset = str2double(temp_laneSection.right.lane(1).width.Attributes.a);
                spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,-1);
            end
             
        end       
    end    
    roadDrawFlag(k) = 1;
    k = k+1;
end