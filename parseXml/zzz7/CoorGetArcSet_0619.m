function  arcmsg = CoorGetArcSet(x,y,hdg,mlength,curvature,offset,laneFlag,n)
    if laneFlag == 0
        t = linspace(0,mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + curvature *t ));
        sinline = @(t)(sin(hdg + curvature *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end
    
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
        t = linspace(0,cur_mlength,n);
        xs = zeros(1,n);
        ys = zeros(1,n);
        cosline = @(t)(cos(hdg + current_c* t ));
        sinline = @(t)(sin(hdg + current_c *t ));
        for i = 1:n
            xs(i) = integral(cosline,t(1),t(i)) + x;
            ys(i) = integral(sinline,t(1),t(i)) + y;
        end

    end
    arcmsg.xs = xs;
    arcmsg.ys = ys;
end