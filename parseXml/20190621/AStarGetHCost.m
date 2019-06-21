function hCost = AStarGetHCost(endPoint,neighbor,roadNet)
    %获取neighbor的终点坐标
    if neighbor.direction == -1
        endx = roadNet(neighbor.id).end_x;
        endy = roadNet(neighbor.id).end_y;  
    end
    if neighbor.direction == 1
        endx = roadNet(neighbor.id).start_x;
        endy = roadNet(neighbor.id).start_y;  
    end
    %欧氏距离返回
    hCost = CoorGetDis(endx,endy,endPoint.x_ref,endPoint.y_ref);
end
