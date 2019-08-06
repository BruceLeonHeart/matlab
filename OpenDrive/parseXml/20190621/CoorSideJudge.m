% 令矢量的起点为A，终点为B，判断的点为C，
% 如果S（A，B，C）为正数，则C在矢量AB的左侧；
% 如果S（A，B，C）为负数，则C在矢量AB的右侧；
% 如果S（A，B，C）为0，则C在直线AB上
function s = CoorSideJudge(x1,y1,x2,y2,x3,y3)
s = ((x1-x3)*(y2-y3)-(y1-y3)*(x2-x3))/2;
s = sign(s);
end