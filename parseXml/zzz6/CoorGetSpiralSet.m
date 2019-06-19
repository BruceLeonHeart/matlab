 function spiralmsg = CoorGetSpiralSet(x_start,y_start,hdg,mlength,curvstart,curvEnd,offset,laneFlag,n)  

    xs = zeros(1,n);
    ys = zeros(1,n);
    offsetlineS = zeros(1,n);
    t = linspace(0,mlength,n);
    c = (curvEnd - curvstart)/mlength;    
    cosline = @(t)(cos(c/2.0*t.^2 + curvstart *t + hdg));
    sinline = @(t)(sin(c/2.0*t.^2 + curvstart *t + hdg));
    a = offset(1);
    b = offset(2);
    c = offset(3);
    d = offset(4);
    offsetline = @(t)(a + b*t + c*t.^2 + d*t.^3);
    for i= 1:n
        xs(i) = integral(cosline,t(1),t(i)) + x_start;
        ys(i) = integral(sinline,t(1),t(i)) + y_start;
%         offsetlineS(i) = integral(offsetline,t(1),t(i));
        offsetlineS(i) = a + b*t(i) + c*t(i).^2 + d*t(i).^3;
    end
    if laneFlag==0    
       
%          arrowPlot1(ax,xs,ys,'linestyle','--','number',5);
    %% 右侧
    elseif laneFlag == -1
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
        end

%          arrowPlot1(ax,xs,ys,'number',5);
    %% 左侧 
    else
        for i= 1:n
            temp_s = i/n*mlength;
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        end

%          arrowPlot1(ax,xs,ys,'number',5);

    end
    spiralmsg.xs = xs;
    spiralmsg.ys = ys;
 end