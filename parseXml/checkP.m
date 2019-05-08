drawMap20190418;

flg = 0;
while ~flg
    f = warndlg('plz choose the start point and end point');
    waitfor(f);
    pause(1);
    
    [x,y] = ginput(1);
    pointS = whichpoint(x,y);
    [x,y] = ginput(1);
    pointE = whichpoint(x,y);
    
    if distanceMat(pointS,pointE) == 10000
        f = warndlg('sry, it''s  a path , choose points again');
        waitfor(f);
    else
        flg = 1;
    end
end