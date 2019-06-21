function gCost = AStarGetGCost(current,neighbor,roadNet)  
    Dis = roadNet(neighbor.id).length; %邻居走完的length 
    gCost = current.gCost + Dis; %当前点已累积的gCost与邻居的消耗求和
end
