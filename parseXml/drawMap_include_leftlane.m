clc;
close all;
clear;
fileObj = xml2struct('MAP.xml');
% fileObj = xml2struct('Crossing8Course.xml');
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
axis([-200 500 -250 250]);

roadDrawFlag = zeros(1,roadNum);
k = 1;
while ~all(roadDrawFlag)
    tempGeoList = roadObj{1,k}.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    laneSectionList = roadObj{1,k}.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    line_x = 0.0;
    line_y = 0.0;
    line_dx = 0.0;
    line_dy = 0.0;
    line_hdg = 0.0;
    arc_x = [];
    arc_y = [];
    arc_x_left = [];
    arc_y_left = [];
    arc_x_right = [];
    arc_y_right = [];
    arc_hdg = 0.0;
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
            line_dx = temp_length*cos(line_hdg);
            line_dy = temp_length*sin(line_hdg);
            line([line_x,line_x+line_dx],[line_y,line_y+line_dy],'linestyle','--','color','k');
            
            offset = str2double(laneSectionList(1).left.lane(1).width.Attributes.a);
            offset_line_dx = offset*cos(line_hdg + pi/2);
            offset_line_dy = offset*sin(line_hdg + pi/2);
            x1 = [line_x + offset_line_dx,line_x + line_dx + offset_line_dx];
            y1 = [line_y + offset_line_dy,line_y + line_dy + offset_line_dy];
            line(x1,y1,'linestyle','--','color','k');
            offset = str2double(laneSectionList(1).right.lane(1).width.Attributes.a);
            offset_line_dx = offset*cos(line_hdg - pi/2);
            offset_line_dy = offset*sin(line_hdg - pi/2);
            x1 = [line_x + offset_line_dx,line_x + line_dx + offset_line_dx];
            y1 = [line_y + offset_line_dy,line_y + line_dy + offset_line_dy];
            line(x1,y1,'linestyle','--','color','k');
%             line([line_x + offset_line_dx,line_x+line_dx +offset_line_dx],[line_y + offset_line_dy,line_y + line_dy + offset_line_dy], ...
%             'linestyle','--','color','k');
        end
        if isfield(temp_tempGeo,'arc')
            temp_c = str2double (temp_tempGeo.arc.Attributes.curvature);
            arc_hdg = str2double(temp_tempGeo.Attributes.hdg);
            temp_hdg = arc_hdg - sign(temp_c) * pi/2;
            temp_x = str2double (temp_tempGeo.Attributes.x);
            temp_y = str2double (temp_tempGeo.Attributes.y);
            temp_length = str2double (temp_tempGeo.Attributes.length);
            
%             for n = 0 :0.05:temp_length
%                 arc_x = [arc_x temp_x + 1/temp_c*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg))];
%                 arc_y = [arc_y temp_y + 1/temp_c*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg))];
%                 offset_left = str2double(laneSectionList(1).left.lane(1).width.Attributes.a);
%                 offset_arc_left_dx = offset_left*cos(arc_hdg + pi/2);
%                 offset_arc_left_dy = offset_left*sin(arc_hdg + pi/2);
%                 arc_x_left = [arc_x_left temp_x + (1/temp_c + sign(temp_c) * offset_left)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_left_dx];
%                 arc_y_left = [arc_y_left temp_y + (1/temp_c + sign(temp_c) * offset_left)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_left_dy];
%                 offset_right = str2double(laneSectionList(1).right.lane(1).width.Attributes.a);
%                 offset_arc_right_dx = offset_right*cos(arc_hdg - pi/2);
%                 offset_arc_right_dy = offset_right*sin(arc_hdg - pi/2);
%                 arc_x_right = [arc_x_right temp_x + (1/temp_c + sign(temp_c) *offset_right)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_right_dx];
%                 arc_y_right = [arc_y_right temp_y + (1/temp_c + sign(temp_c) *offset_right)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_right_dy];
%             end
            offset_left = str2double(laneSectionList(1).left.lane(1).width.Attributes.a);
            offset_right = str2double(laneSectionList(1).right.lane(1).width.Attributes.a);
            for n = 0 :0.05:temp_length
                 arc_x = [arc_x temp_x + 1/abs(temp_c)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg))];
                 arc_y = [arc_y temp_y + 1/abs(temp_c)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg))];
                 if temp_c > 0 
                    offset_arc_left_dx = -offset_left*cos(temp_hdg);
                    offset_arc_left_dy = -offset_left*sin(temp_hdg);
                    arc_x_left = [arc_x_left temp_x + (1/abs(temp_c) - offset_left)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_left_dx];
                    arc_y_left = [arc_y_left temp_y + (1/abs(temp_c) - offset_left)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_left_dy];
                    offset_arc_right_dx = offset_right*cos(temp_hdg);
                    offset_arc_right_dy = offset_right*sin(temp_hdg);
                    arc_x_right = [arc_x_right temp_x + (1/abs(temp_c) + offset_right)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_right_dx];
                    arc_y_right = [arc_y_right temp_y + (1/abs(temp_c) + offset_right)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_right_dy];        
                 else
                    offset_arc_left_dx = offset_left*cos(temp_hdg);
                    offset_arc_left_dy = offset_left*sin(temp_hdg);
                    arc_x_left = [arc_x_left temp_x + (1/abs(temp_c) + offset_left)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_left_dx];
                    arc_y_left = [arc_y_left temp_y + (1/abs(temp_c) + offset_left)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_left_dy];
                    offset_arc_right_dx = -offset_right*cos(temp_hdg);
                    offset_arc_right_dy = -offset_right*sin(temp_hdg);
                    arc_x_right = [arc_x_right temp_x + (1/abs(temp_c) - offset_right)*(cos(temp_hdg +n*temp_c ) - cos(temp_hdg)) + offset_arc_right_dx];
                    arc_y_right = [arc_y_right temp_y + (1/abs(temp_c) - offset_right)*(sin(temp_hdg +n*temp_c ) - sin(temp_hdg)) + offset_arc_right_dy];        
                 end                   
            end
            
            
            plot(arc_x,arc_y,'--');
            plot(arc_x_left,arc_y_left,'--');
            plot(arc_x_right,arc_y_right,'--');
            
%             offset = str2double(laneSectionList(1).left.lane(1).width.Attributes.a);
%             offset_line_dx = offset*cos(line_hdg + pi/2);
%             offset_line_dy = offset*sin(line_hdg + pi/2);
%             plot(arc_x + offset_line_dx,arc_y + offset_line_dy,'--');
%         
%         
%             offset = str2double(laneSectionList(1).right.lane(1).width.Attributes.a);
%             offset_line_dx = offset*cos(line_hdg - pi/2);
%             offset_line_dy = offset*sin(line_hdg - pi/2);
%             plot(arc_x + offset_line_dx,arc_y+offset_line_dy,'--');
%      
            
        end
        if isfield(temp_tempGeo,'spiral')
%             spiral_x = str2double (temp_tempGeo.Attributes.x);
%             spiral_y = str2double (temp_tempGeo.Attributes.y);
%             temp_hdg = str2double(temp_tempGeo.Attributes.hdg);
%             temp_length = str2double (temp_tempGeo.Attributes.length);
%             curv_start = str2double (temp_tempGeo.spiral.Attributes.curvStart);
%             curv_end = str2double (temp_tempGeo.spiral.Attributes.curvEnd);
%             delta =  curv_end - curv_start;
%             curve_flag = sign(curv_start)&&sign(curv_end);
%             temp_hdg_circle = temp_hdg - curve_flag * pi/2;
%             cDot = delta/temp_length;
%             offset_left = str2double(laneSectionList(1).left.lane(1).width.Attributes.a);
% %             offset_right = str2double(laneSectionList(1).right.lane(1).width.Attributes.a);
%             temp_x =[];
%             temp_y =[];
%             temp_x_right = [];
%             temp_y_right = [];
%             x = 0.0;
%             y = 0.0;
%             t = 0.0;
%             for i = 0:0.001:temp_length                
%                 format long e;
%                 [x,y,~] = mspiral( i, cDot, x, y, t );
%                 r  = sqrt(x^2 + y^2);
%                 x_new = x*cos(hdg) - y*sin(hdg);
%                 y_new = y*cos(hdg) + x*sin(hdg);               
%                 temp_x = [temp_x spiral_x+x_new];
%                 temp_y = [temp_y spiral_y+y_new];
%                 temp_x_right =  [temp_x_right spiral_x+x_new + offset_left*cos(temp_hdg_circle)];
%                 temp_y_right =  [temp_y_right spiral_x+x_new + offset_left*sin(temp_hdg_circle)];
%             end
%             plot(temp_x,temp_y);
%             plot(temp_x_right,temp_y_right);
            
            
            
            
        end       
    end
%     for a = 1:laneSectionListSize
%         curleft = laneSectionList(a).left;
%         curcenter = laneSectionList(a).center;
%         curright = laneSectionList(a).right;
%         for a_left = 1 :length(curleft.lane)
%             offset = str2double(curleft.lane(a_left).width.Attributes.a);
%             offset_line_dx = offset*cos(line_hdg + pi/2);
%             offset_line_dy = offset*sin(line_hdg + pi/2);
%             line([line_x + offset_line_dx,line_x+line_dx +offset_line_dx],[line_y + offset_line_dy,line_y + line_dy + offset_line_dy], ...
%             'linestyle','--','color','k');
%             offset_arc_dx = offset*cos(arc_hdg + pi/2);
%             offset_arc_dy = offset*sin(arc_hdg + pi/2);
%             plot(arc_x + offset_arc_dx,arc_y + offset_arc_dy,'--');
%         end
%         
%         for a_center = 1:length(curcenter.lane)
%         end
%         
%         for a_right = 1:length(curright.lane)
%             offset = str2double(curleft.lane(a_right).width.Attributes.a);
%             offset_line_dx = offset*cos(line_hdg - pi/2);
%             offset_line_dy = offset*sin(line_hdg - pi/2);
%             line([line_x + offset_line_dx,line_x+line_dx +offset_line_dx],[line_y + offset_line_dy,line_y+line_dy + offset_line_dy], ...
%             'linestyle','--','color','k');
%             offset_arc_dx = offset*cos(arc_hdg - pi/2);
%             offset_arc_dy = offset*sin(arc_hdg - pi/2);
%             plot(arc_x + offset_arc_dx,arc_y + offset_arc_dy,'--');
%         end
%     end
    
    roadDrawFlag(k) = 1;
    k = k+1;
end



% 
% function [dx,dy] = lineAction(s,hdg)
%     dx = s*cos(hdg);
%     dy = s*sin(hdg);
% end
% 
% function [dx,dy] = arcAction(s,curvature,hdg)
%     c = curvature;
%     hdg = hdg -pi/2;
%     a = 2/c*sin(s*c/2);
%     alpha = (pi -s*c)/2 - hdg;
%     dx = -1*a*cos(alpha);
%     dy = a*sin(alpha);
% end
% 
% function [dx,dy] = spiral(s,x,y)
%     dx = 0;
%     dy = 0;
% end