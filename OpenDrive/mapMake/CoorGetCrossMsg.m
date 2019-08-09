function [v,x,y] = CoorGetCrossMsg(x_start,y_start,x_end,y_end,pointX,pointY)

    COS_hdg = (x_end - x_start)/distance(x_start,y_start,x_end,y_end);
    if abs(COS_hdg)<1.00e-15
        B = 0;
        A = 1;
        C = -x_start;
    else
        TAN_hdg = (y_end - y_start) / (x_end - x_start);
        B = 1;
        A = - TAN_hdg;
        C = TAN_hdg * x_start - y_start;
    end
    % 距离
    v = (A*pointX + B*pointY + C)/sqrt(A^2 + B^2);
    %　求垂足
    x = (B*B*pointX - A*B*pointY - A*C)/(A^2 + B^2);
    y = (-B*A*pointX + A*A*pointY - B*C)/(A^2 + B^2);
end

function dis = distance(x1,y1,x2,y2)

    delta_x = abs(x2 - x1);
    delta_y = abs(y2 - y1);
    dis = sqrt(delta_x^2 + delta_y^2 );
end