%% 判断点C是否落在线段AB上
function flag = CoorIsPointOnSeg(A_x,A_y,B_x,B_y,C_x,C_y)
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