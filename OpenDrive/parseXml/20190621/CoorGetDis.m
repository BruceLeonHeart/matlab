%% 两点间欧氏距离
function dis = CoorGetDis(x1,y1,x2,y2)
    a = [x1 ,y1];
    b = [x2 ,y2];
    dis = norm(a-b);    
end