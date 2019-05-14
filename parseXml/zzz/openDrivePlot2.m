
function  openDrivePlot2(openDriveObj,ax1)
global ax;
ax = ax1;

roadObj = openDriveObj.road;
roadNum = length(roadObj);
if roadNum == 1
    roadParse(roadObj);
else
    for i=1:roadNum
        fprintf("curRoad: %d \n",i);
        roadParse(roadObj{1,i});
    end
end
end

function roadParse(mRoadObj)
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    
    
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    for i0 = 1:laneSectionListSize
        if isstruct(laneSectionList)
                temp_laneSection = laneSectionList(1);
        end
        if iscell(laneSectionList)
                temp_laneSection = laneSectionList{1,i0};
        end 
        for m = 1:tempGeoListSize
            %工具里面的tempGeoList只有一种属性时，显示为结构体，其余属于cell
            if isstruct(tempGeoList)
                temp_tempGeo = tempGeoList(1);
                fprintf("hhaha \n");
            end
            if iscell(tempGeoList)
                temp_tempGeo = tempGeoList{1,m};
                fprintf("hello \n");
            end 

            if isfield(temp_tempGeo,'line')
                line_x = str2double (temp_tempGeo.Attributes.x);
                line_y = str2double (temp_tempGeo.Attributes.y);
                temp_length = str2double (temp_tempGeo.Attributes.length);
                line_hdg = str2double(temp_tempGeo.Attributes.hdg);
                lineDraw(line_x,line_y,line_hdg,temp_length,0.0,0);
                if isfield(temp_laneSection,'left')
                    leftLineList = temp_laneSection.left.lane;
                    for i =1:length(leftLineList)
                        if length(leftLineList) ==1
                            curLane = leftLineList(1);
                        else
                            curLane = leftLineList{1,i};
                        end
                        
                        offset = str2double(curLane.width.Attributes.a);
                        lineDraw(line_x,line_y,line_hdg,temp_length,offset,1);
                    end
                else
                    rightLineList = temp_laneSection.right.lane;
                    for i =1:length(rightLineList)
                        if length(rightLineList) ==1
                            curLane = rightLineList(1);
                        else
                            curLane = rightLineList{1,i};
                        end
                        fprintf("line No:%f \n",i);
                        offset = str2double(curLane.width.Attributes.a);
                        lineDraw(line_x,line_y,line_hdg,temp_length,offset,-1);    
                    end
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
                     leftLineList = temp_laneSection.left.lane;
                      for i =1:length(leftLineList)
                        if length(leftLineList) ==1
                            curLane = leftLineList(1);
                        else
                            curLane = leftLineList{1,i};
                        end
                        offset = str2double(curLane.width.Attributes.a);
                        arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,1);
                      end
                else
                    rightLineList = temp_laneSection.right.lane;
                    for i =1:length(rightLineList)
                        if length(rightLineList) ==1
                            curLane = rightLineList(1);
                        else
                            curLane = rightLineList{1,i};
                        end
                        offset = str2double(curLane.width.Attributes.a);
                        arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,-1);   
                    end
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
                     leftLineList = temp_laneSection.left.lane;
                      for i =1:length(leftLineList)
                        if length(leftLineList) ==1
                            curLane = leftLineList(1);
                        else
                            curLane = leftLineList{1,i};
                        end
                        offset = str2double(curLane.width.Attributes.a);
                        spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,1);
                      end
                else
                    rightLineList = temp_laneSection.right.lane;
                    for i =1:length(rightLineList)
                        if length(rightLineList) ==1
                            curLane = rightLineList(1);
                        else
                            curLane = rightLineList{1,i};
                        end
                        offset = str2double(curLane.width.Attributes.a);
                        spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,-1);
                    end
                end

            end 
        end
    end   
   
end

%% 解析参考线
% function parseRoadGeo()
%     
% 
% end


%% 绘制圆弧
function  arcDraw(x,y,hdg,mlength,curvature,offset,laneFlag)
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
        plot(ax,xs,ys);

        
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
        plot(ax,xs,ys);
%         arrowPlot1(ax,xs,ys,'number',5);

    end
end
  
%% 绘制螺旋线
 function spiralDraw(x_start,y_start,hdg,mlength,curvstart,curvEnd,offset,laneFlag)  
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
        plot(ax,xs,ys);
%          arrowPlot1(ax,xs,ys,'number',5);
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        end
        plot(ax,xs,ys);
%          arrowPlot1(ax,xs,ys,'number',5);

    end
 end
 
%% 绘制直线
function  lineDraw(x,y,hdg,mlength,offset,laneFlag) 
         global ax;
         % 沿着s方向的偏移量
         dx = mlength * cos(hdg);
         dy = mlength * sin(hdg);
        %% 原始参考线
         if laneFlag == 0
%             line(ax,[x,x+dx],[y,y+dy],'linestyle','--','color','k','marker','>');   
             arrowPlot1(ax,[x,x+dx],[y,y+dy],'linestyle','--','color','k','number',5);
        %% 右侧 基于s方向顺时针旋转
         elseif laneFlag == -1 
            x = x + offset*cos(hdg-pi/2);
            y = y + offset*sin(hdg-pi/2);
            line(ax,[x,x+dx],[y,y+dy]);
%              arrowPlot1(ax,[x,x+dx],[y,y+dy],'number',5);
        %% 左侧 基于s方向逆时针旋转
         else 
            x = x + offset*cos(hdg+pi/2);
            y = y + offset*sin(hdg+pi/2);
            line(ax,[x,x+dx],[y,y+dy]);
%              arrowPlot1(ax,[x,x+dx],[y,y+dy],'number',5);
         end
end






