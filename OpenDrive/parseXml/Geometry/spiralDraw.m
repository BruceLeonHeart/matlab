function spiralDraw(x_start,y_start,hdg,mlength,curvstart,curvEnd,offset,laneFlag)  
   
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
        plot(xs,ys,'linestyle','--');
    %% 右侧
    elseif laneFlag == -1
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
        end
        plot(xs,ys);
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
            ys(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        end
        plot(xs,ys);
    end   
end