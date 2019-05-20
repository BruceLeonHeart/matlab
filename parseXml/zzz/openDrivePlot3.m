
function  openDrivePlot3(openDriveObj,ax1)
global ax;
ax = ax1;

roadObj = openDriveObj.road;
roadNum = length(roadObj);
if roadNum == 1
    roadParse(roadObj);
else
    for i=1:roadNum
%         for i=1:1
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
    
        for m = 1:tempGeoListSize
            %工具里面的tempGeoList只有一种属性时，显示为结构体，其余属于cell
            if isstruct(tempGeoList)
                temp_tempGeo = tempGeoList(1);
            end
            if iscell(tempGeoList)
                temp_tempGeo = tempGeoList{1,m};
            end 

            for i0 = 1:laneSectionListSize
                if isstruct(laneSectionList)
                        temp_laneSection = laneSectionList(1);
                end
                if iscell(laneSectionList)
                        temp_laneSection = laneSectionList{1,i0};
                end 
        
            if isfield(temp_tempGeo,'line')
                line_x = str2double (temp_tempGeo.Attributes.x);
                line_y = str2double (temp_tempGeo.Attributes.y);
                temp_length = str2double (temp_tempGeo.Attributes.length);
                line_hdg = str2double(temp_tempGeo.Attributes.hdg);
                lineDraw(line_x,line_y,line_hdg,temp_length,0.0,0);
                if isfield(temp_laneSection,'left')
                    lanes = temp_laneSection.left.lane;
                    if isstruct(lanes)
                        offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                        lineDraw(line_x,line_y,line_hdg,temp_length,offset,1);                
                    else
                        for zz1 = 1:length(lanes)
                            if temp_laneSection.left.lane{1,zz1}.Attributes.type == "driving"
                                curLane = lanes{1,zz1};
                                break;
                            end
                        end
                        offset = str2double(curLane.width.Attributes.a);
                        lineDraw(line_x,line_y,line_hdg,temp_length,offset,1);
                    end
                end
               if isfield(temp_laneSection,'right')
                    lanes = temp_laneSection.right.lane;

                    if isstruct(lanes)
                        offset = str2double(lanes(1).width.Attributes.a);
                        lineDraw(line_x,line_y,line_hdg,temp_length,offset,-1);                
                    else
                        for zz1 = 1:length(lanes)
                            if temp_laneSection.right.lane{1,zz1}.Attributes.type == "driving"
                                curLane = lanes{1,zz1};
                                break;
                            end
                        end
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
                 lanes = temp_laneSection.left.lane;
                if isstruct(lanes)
                    offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                    arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,1);              
                else
                    for zz1 = 1:length(lanes)
                        if temp_laneSection.left.lane{1,zz1}.Attributes.type == "driving"
                            curLane = lanes{1,zz1};
                            break;
                        end
                    end
                    offset = str2double(curLane.width.Attributes.a);
                    arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,1);
                end
                 end
           if isfield(temp_laneSection,'right')
                lanes = temp_laneSection.right.lane;
                
                if isstruct(lanes)
                    offset = str2double(lanes(1).width.Attributes.a);
                    arcDraw(temp_x,temp_y,temp_hdg,temp_length,temp_c,offset,-1);                
                else
                    for zz1 = 1:length(lanes)
                        if temp_laneSection.right.lane{1,zz1}.Attributes.type == "driving"
                            curLane = lanes{1,zz1};
                            break;
                        end
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
                
                lanes = temp_laneSection.left.lane;
                if isstruct(lanes)
                    offset = str2double(temp_laneSection.left.lane(1).width.Attributes.a);
                    spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,1);           
                else
                    for zz1 = 1:length(lanes)
                        if temp_laneSection.left.lane{1,zz1}.Attributes.type == "driving"
                            curLane = lanes{1,zz1};
                            break;
                        end
                    end
                    offset = str2double(curLane.width.Attributes.a);
                    spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,1);
                end
                    end
                
            if isfield(temp_laneSection,'right')
                 lanes = temp_laneSection.right.lane;
                
                if isstruct(lanes)
                    offset = str2double(lanes(1).width.Attributes.a);
                   spiralDraw(spiral_x,spiral_y,temp_hdg,temp_length,curv_start,curv_end,offset,-1);             
                else
                    for zz1 = 1:length(lanes)
                        if temp_laneSection.right.lane{1,zz1}.Attributes.type == "driving"
                            curLane = lanes{1,zz1};
                            break;
                        end
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
         global fig;
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
            line(ax,[x,x+dx],[y,y+dy]);

            quiver(ax,x,y,dx/2,dy/2);

        %% 左侧 基于s方向逆时针旋转
         else 
            x = x + offset*cos(hdg+pi/2);
            y = y + offset*sin(hdg+pi/2);
            line(ax,[x,x+dx],[y,y+dy]);
            quiver(ax,x+dx,y+dy,-dx/2,-dy/2);

         end
end


%% 归一化
function [x1,y1] = normOne(x,y)
    global ax;
    a = axis(ax);
    x1 = (x - a(1))/(a(2) - a(1));
    y1 = (y - a(3))/(a(4) - a(3));
end




%%  绘制带有向的线段
%
%
function H = arrowPlot1(X, Y, varargin)
    global ax;
%ARROWPLOT Plot with arrow on the curve.
%   ARROWPLOT(X, Y) plots X, Y vectors with 2 arrows directing the trend of data.
%
%   You can use some options to edit the properties of arrow or curve.
%   The options that you can change are as follow:
%       number:		The number of arrows, default number is 2;
%       color:		The color of arrows and curve, default color is [0, 0.447, 0.741];
%       LineWidth:	The line width of curve, default LineWidth is 0.5;
%       scale:		To scale the size of arrows, default scale is 1;
%       limit:		The range to plot, default limit is determined by X, Y data;
%       ratio:		The ratio of X-axis and Y-axis, default ratio is determined by X, Y data;
%             		You can use 'equal' for 'ratio', that means 'ratio' value is [1, 1, 1].
%       LineStyle : added by lmq 2019-05-14
%
%   Example 1:
%   ---------
%      t = [0:0.01:20];
%      x = t.*cos(t);
%      y = t.*sin(t);
%      arrowPlot(x, y, 'number', 3)
%
%   Example 2:
%   ---------
%      t = [0:0.01:20];
%      x = t.*cos(t);
%      y = t.*sin(t);
%      arrowPlot(x, y, 'number', 5, 'color', 'r', 'LineWidth', 1, 'scale', 0.8, 'ratio', 'equal')

%   Copyright 2017 TimeCoder.

%     h = plot(X, Y);
    h = plot(ax,X, Y);
    ax = gca;
    hold on;
    if nargout == 1
        H = h;
    end

    ratio = get(gca, 'DataAspectRatio')
    limit = axis(ax);
    d = max(limit(2)-limit(1), limit(4)-limit(3));
    
    default_options.number = 2;
    default_options.color = [0 0.447 0.741];
    default_options.LineWidth = 0.5;
    default_options.size = d;
    default_options.scale = 1;
    default_options.limit = axis;
    default_options.ratio = ratio;
    default_options.LineStyle = '-';
    Options = creat_options(varargin, default_options);
    
    useroptions = creat_useroptions(varargin);
    if ~isfield(useroptions, 'size')
        Options.size = max(Options.limit(2)-Options.limit(1), Options.limit(4)-Options.limit(3));
    end
    if ~isfield(useroptions, 'ratio')
        axis(Options.limit);
        Options.ratio = get(ax, 'DataAspectRatio');
    end
    set(h, 'color', Options.color);
    set(h, 'LineWidth', Options.LineWidth);
    set(h, 'LineStyle',Options.LineStyle);
    if isa(Options.ratio, 'char') && strcmp(Options.ratio, 'equal')
        r = 1;
    else
        r = Options.ratio(2) / Options.ratio(1);
    end
    
    n_X = length(X);
    journey = 0;
    for i = 1 : n_X-1
        journey = journey + sqrt( (X(i+1)-X(i))^2 + (Y(i+1)-Y(i))^2 );
    end
    journey_part = journey / Options.number;

    if 10*journey<Options.size
        Options.size = 10*journey;
    end
    
    
    [X_arrow, Y_arrow] = arrow_shape(50, 25);
    [X_arrow1, Y_arrow1] = Scale(X_arrow, Y_arrow, 0.015*Options.scale*Options.size);

    k=0.5;
    journey_now = 0;

    for i = 1 : n_X-1
        journey_step = sqrt( (X(i+1)-X(i))^2 + (Y(i+1)-Y(i))^2 );
        journey_next = journey_now + journey_step;
        if journey_now<=k*journey_part && journey_next>k*journey_part
            s = (k*journey_part - journey_now) / journey_step;
            x0 = X(i) + s * (X(i+1)-X(i));
            y0 = Y(i) + s * (Y(i+1)-Y(i));
            [X_arrow2, Y_arrow2] = Rotate(X_arrow1, Y_arrow1, arg(X(i+1)-X(i), (Y(i+1)-Y(i))/r) );
            [X_arrow3, Y_arrow3] = Translation(X_arrow2, r*Y_arrow2, [x0, y0]);
            g = fill(X_arrow3, Y_arrow3, Options.color);
            set(g, 'EdgeColor', Options.color);
            k=k+1;
        end
        journey_now = journey_next;
    end
    axis(Options.limit);
    if isequal(Options.ratio, 'equal')
        axis equal;
    end
    hold off;
end

function Options = creat_options(user_choice, default_choice_struct)
    n = length(user_choice);
    if ~ispair(n)
        error('varargin is not an options''s struct.');
    end
    
    Options = default_choice_struct;
    i = 1;
    while i <= n
        if isfield(default_choice_struct, user_choice{i})
            Options = setfield(Options, user_choice{i}, user_choice{i+1});
        end
        i = i + 2;
    end
end

function Options = creat_useroptions(VARARGIN)
    if ~isa(VARARGIN, 'cell')
        error('VARARGIN is not of class cell!');
    end
    n = length(VARARGIN);
    if ~ispair(n)
        error('length of VARARGIN is not pair!');
    end
    i = 1;
    Options = struct();
    while i < n
        Options = setfield(Options, VARARGIN{i}, VARARGIN{i+1});
        i = i+2;
    end
end



function check = ispair(x)
    check = ( isint(x) && isint( 1.0*x / 2.0 ) );
end

function check = isint(x)
    check = ( floor(x) == x );
end

function theta = arg(x, y)
    if nargin == 2
        [m, n] = size(x);
        theta = zeros(m, n);
        for i = 1 : m
            for j = 1 : n
                if x(i, j) > 0 || y(i, j) ~= 0
                    theta(i, j) = 2 * atan( y(i, j) ./ ( x(i, j) + sqrt(x(i, j).^2+y(i, j).^2) ) );
                elseif x(i, j) < 0 && y(i, j) == 0
                    theta(i, j) = pi;
                elseif x(i, j) == 0 && y(i, j) == 0
                    theta(i, j) = 0;
                end
            end
        end
    elseif nargin==1
        theta = arg(real(x), imag(x));
    end
end

function [X, Y] = arrow_shape(theta1, theta2)
    theta1 = theta1/180*pi;
    theta2 = theta2/180*pi;
    x0 = tan(theta2) / ( tan(theta2) - tan(theta1) );
    y0 = tan(theta1) * tan(theta2) / ( tan(theta2) - tan(theta1) );
    X = [0, x0, 1, x0, 0];
    Y = [0, y0, 0, -y0, 0];
end

function [X_new, Y_new] = Rotate( X, Y, varargin )
    if length(varargin)==1
        center = [0, 0];
        theta = varargin{1};
    elseif length(varargin)==2
        center = varargin{1};
        theta = varargin{2};
    end

    [m1, n1] = size(X);
    [m2, n2] = size(Y);
    
    if min(m1, n1) ~= 1
        error('The size of X is wrong!');
    end
    
    if min(m2, n2) ~= 1
        error('The size of Y is wrong!');
    end
    
    if n1 == 1
        X = X';
    end
    
    if n2 == 1
        Y = Y';
    end
    
    if length(X) ~= length(Y)
        error('length(X) and length(Y) must be equal!');
    end
    XY_new = [cos(theta), -sin(theta); sin(theta), cos(theta)] * [X-center(1); Y-center(2)];
    X_new = XY_new(1, :)+center(1);
    Y_new = XY_new(2, :)+center(2);
end

function [X_new, Y_new] = Scale( X, Y, varargin )
    if length(varargin)==1
        center = [0, 0];
        s = varargin{1};
    elseif length(varargin)==2
        center = varargin{1};
        s = varargin{2};
    end
    
    X_new = s * ( X - center(1) ) + center(1);
    Y_new = s * ( Y - center(2) ) + center(2);
end

function [X_new, Y_new] = Translation( X, Y, increasement )
    X_new = X + increasement(1);
    Y_new = Y + increasement(2);
end


