function path = pathPlan1(startPoint,endPoint,ax1)
    global ax;
    ax = ax1;
    startPoint
    endPoint
    %考虑到生成路线过程中，会不停的生成plot/line对象
      path = [];
      path(length(path) +1) = line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',15,'color','g');  
      path(length(path) +1) = line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',10,'color','r');  
      
    % 如果终点落在起点的前方，则将快速结束路径搜索过程
    if (startPoint.RoadNum == endPoint.RoadNum) && (startPoint.GeoNum == endPoint.GeoNum) && (startPoint.LaneNum == endPoint.LaneNum)
        dis =  sqrt ( (endPoint.Roadx  - startPoint.Roadx).^2 + (endPoint.Roady - startPoint.Roady).^2 );
        flg1 = ( (endPoint.Roadx - startPoint.Roadx) == dis*cos(startPoint.hdg*startPoint.LaneNum));
        flg2 = ( (endPoint.Roady - startPoint.Roady) == dis*sin(startPoint.hdg*startPoint.LaneNum));
        if flg1&&flg2
%             lineDraw(startPoint.x_start,startPoint.y_start,startPoint.hdg,abs(dis),1.5,startPoint.LaneNum);
            %起点绘制至所在Lane终点处
               line(ax,[startPoint.Roadx,startPoint.x_end],[startPoint.Roady,startPoint.y_end],'lineWidth',15,'color','g');  
               quiver(ax,startPoint.Roadx,startPoint.Roady,(startPoint.x_end - startPoint.Roadx)/2,(startPoint.y_end - startPoint.Roady)/2,'linestyle','--');
%             lineDraw(startPoint.x_start,startPoint.y_start,startPoint.hdg,abs(dis),1.5,startPoint.LaneNum);
        %Lane起点绘制至终点处
            line(ax,[endPoint.x_start,endPoint.Roadx],[endPoint.y_start,endPoint.Roady],'lineWidth',10,'color','r');  
            quiver(ax,endPoint.x_start,endPoint.y_start,(endPoint.Roadx - endPoint.x_start)/2,(endPoint.Roady - endPoint.y_start)/2,'linestyle','--');
        end      
    end

fprintf("%f \n",startPoint.Roadx);
fprintf("%f",endPoint.Roadx);
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