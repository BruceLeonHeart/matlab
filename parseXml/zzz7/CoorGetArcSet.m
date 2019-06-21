function  arcmsg = CoorGetArcSet(x,y,hdg,mlength,curvature,offset,laneFlag,n)
    xs = zeros(1,n);
    ys = zeros(1,n);
    offsetlineS = zeros(1,n);
    t = linspace(0,mlength,n);  
    cosline = @(t)(cos(curvature *t + hdg));
    sinline = @(t)(sin(curvature *t + hdg));
    a = offset(1);
    b = offset(2);
    c = offset(3);
    d = offset(4);
    offsetline = @(t)(a + b*t + c*t.^2 + d*t.^3);
    for i= 1:n
        xs(i) = integral(cosline,t(1),t(i)) + x;
        ys(i) = integral(sinline,t(1),t(i)) + y;
%         offsetlineS(i) = integral(offsetline,t(1),t(i));
        offsetlineS(i) = a + b*t(i) + c*t(i).^2 + d*t(i).^3;
    end
    if laneFlag==0    
      
    %% 右侧
    elseif laneFlag == -1
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg + curvature*temp_s  -pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg + curvature*temp_s  -pi/2);
        end
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg + curvature*temp_s  +pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg + curvature*temp_s  +pi/2);
        end   
    end
    arcmsg.xs = xs;
    arcmsg.ys = ys;
end