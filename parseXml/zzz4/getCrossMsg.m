function [v,x,y] = getCrossMsg(x_start,y_start,hdg,pointX,pointY)
    if abs(cos(hdg))<1.00e-15
        B = 0;
        A = 1;
        C = -x_start;
    else
        B = 1;
        A = - tan(hdg);
        C = tan(hdg) * x_start - y_start;
    end
    % 距离
    v = (A*pointX + B*pointY + C)/sqrt(A^2 + B^2);
    %　求垂足
    x = (B*B*pointX - A*B*pointY - A*C)/(A^2 + B^2);
    y = (-B*A*pointX + A*A*pointY - B*C)/(A^2 + B^2);
end

