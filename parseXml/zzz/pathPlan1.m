function path = pathPlan1(startPoint,endPoint,ax1)
    global ax;
    ax = ax1;
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
      path = [];
%       path(length(path) +1) = line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',15,'color','g');  
%       path(length(path) +1) = line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',10,'color','r');  
%       
      open = {};
      open{1} = start;
      while(~isempty(open))
          if isPointOnSegment(startPoint.Roadx,startPoint.Roady,startPoint.x_end,startPoint.y_end,endPoint.Roadx,endPoint.Roady)
              path(length(path) +1) = line(ax,[startPoint.Roadx,endPoint.Roadx],[endPoint.Roadx,endPoint.Roady],'lineWidth',10,'color','b');
          end       
      end
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
        quiver(ax,x,y,dx/2,dy/2);

     end
end

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