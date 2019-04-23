%% for test offset lane
    clf;
    clc;
    clear;
    % s = 9.3345930335000006e+001;
    x_start= 9.3345930335000006e+001;
    y_start= 9.3345930335000006e+001;
    hdg=0.0000000000000000e+000;
    mlength=5.6049910000000001e+000;
    curvstart=0.0000000000000000e+000;
    curvEnd=-2.8024959999999999e-001;
    offset =2.0;

    n = 100;
    xs = zeros(1,n);
    ys = zeros(1,n);
    ss = zeros(1,n);
    
    ss_new = zeros(1,n);
    curvs = zeros(1,n);
    xs_off = zeros(1,n);
    ys_off = zeros(1,n);
    t = linspace(0,mlength,n);
    c = (curvEnd - curvstart)/mlength;   
    cosline = @(t)(cos(c/2.0*t.^2 + curvstart *t + hdg));
    sinline = @(t)(sin(c/2.0*t.^2 + curvstart *t + hdg));
    for i= 1:n
        xs(i) = integral(cosline,t(1),t(i)) + x_start;
        ys(i) = integral(sinline,t(1),t(i)) + y_start;
        ss(i) = i*mlength/n;
        
        ss_new(i) = ss(i)*(1+offset*(curvstart + (i-1)*mlength/n*c));
        ss_new_1(i) = ss(i)*(1-offset*(curvstart + (i-1)*mlength/n*c));
        curvs(i) = curvstart+c*mlength*i/n;
%         hdgs(i)/ss(i)
        fprintf("curvs(%d) : %f   ",i,curvs(i));
        if mod(i,4)==0
             fprintf("\n");
        end
    end 
    diff_curvs = diff(curvs);
    for i =1:n-1
        fprintf("diff_curvs(%d) : %f \n ",i,diff_curvs(i));
    end
    
        
        
        figure(2)
        plot(ss,curvs,'linestyle','--');
        hold on 
        plot(ss_new,curvs,'linestyle','-');
        hold on 
        plot(ss_new_1,curvs,'linestyle','-.');
        
        p1 = polyfit(ss,curvs,2);
        p2 = polyfit(ss_new,curvs,2);
        p3 = polyfit(ss_new_1,curvs,2);
%         
%         figure(3)
%         % 曲率变化率
%         plot(ss(1:end-1),diff(curvs),'linestyle','--');
%         hold on 
%         plot(ss_new(1:end-1),diff(curvs),'linestyle','-');
%         hold on 
%         plot(ss_new_1(1:end-1),diff(curvs),'linestyle','-.');

    for i= 1:n
        temp_s = i/n*mlength;
        xs_off(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        ys_off(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 +pi/2);
        xs_off_1(i) = xs(i) + offset*cos(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
        ys_off_1(i) = ys(i) + offset*sin(hdg + curvstart*temp_s + c * temp_s.^2/2.0 -pi/2);
    end
        figure(1)
        plot(xs,ys,'linestyle','--');
        hold on 
        plot(xs_off,ys_off,'linestyle','-');
        hold on 
        plot(xs_off_1,ys_off_1,'linestyle','-.');
