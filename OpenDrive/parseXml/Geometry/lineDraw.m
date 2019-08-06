function  lineDraw(x,y,hdg,mlength,offset,laneFlag)         
         % 沿着s方向的偏移量
         dx = mlength * cos(hdg);
         dy = mlength * sin(hdg);
        %% 原始参考线
         if laneFlag == 0
            line([x,x+dx],[y,y+dy],'linestyle','--','color','k');          
        %% 右侧 基于s方向顺时针旋转
         elseif laneFlag == -1 
            x = x + offset*cos(hdg-pi/2);
            y = y + offset*sin(hdg-pi/2);
            line([x,x+dx],[y,y+dy]);
        %% 左侧 基于s方向逆时针旋转
         else 
            x = x + offset*cos(hdg+pi/2);
            y = y + offset*sin(hdg+pi/2);
            line([x,x+dx],[y,y+dy]);
         end

end

