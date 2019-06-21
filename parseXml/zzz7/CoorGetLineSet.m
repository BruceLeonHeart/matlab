function  linemsg = CoorGetLineSet(x,y,hdg,mlength,offset,laneFlag,n) 
        
         xs = zeros(1,n);
         ys = zeros(1,n);
         offsetlineS = zeros(1,n);
         t = linspace(0,mlength,n);
         a = offset(1);
         b = offset(2);
         c = offset(3);
         d = offset(4);
         offsetline = @(t)(a + b*t + c*t.^2 + d*t.^3);
         for i= 1:n
            xs(i) = t(i)*cos(hdg) + x;
            ys(i) = t(i)*sin(hdg) + y;
%             offsetlineS(i) = integral(offsetline,t(1),t(i));
            offsetlineS(i) = a + b*t(i) + c*t(i).^2 + d*t(i).^3;
         end
        %% 原始参考线
         if laneFlag == 0
            

        %% 右侧 基于s方向顺时针旋转
         elseif laneFlag == -1 
         for i= 1:n
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg - pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg - pi/2);
         end

        %% 左侧 基于s方向逆时针旋转
         else 
         for i= 1:n
            xs(i) = xs(i) + offsetlineS(i)*cos(hdg + pi/2);
            ys(i) = ys(i) + offsetlineS(i)*sin(hdg + pi/2);
         end
         end
         linemsg.xs = xs;
         linemsg.ys = ys;
   
end
