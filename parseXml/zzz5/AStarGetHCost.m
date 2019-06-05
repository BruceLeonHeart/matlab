function hCost = AStarGetHCost(endPoint,neighbor,roadNet)
    %获取neighbor的终点坐标
    endx = roadNet(neighbor.id).end_x;
    endy = roadNet(neighbor.id).end_y;  
    %欧氏距离返回
    hCost = CoorGetDis(endx,endy,endPoint.x,endPoint.y);
end
