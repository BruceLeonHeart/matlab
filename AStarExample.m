function AstarExample()
initMap2();
end

%% 绘制地图程序
function initMap()
figure(2);
format long; %16位有效数字
hold on;
axis equal; % x,y坐标轴比例尺保持一致
axis ([0 30 0 30]); %取值区间

% set(gcf,'position',[left,top,width,height]);
set(gca,'XTicklabel',0:1:30);%坐标轴标签刻度
set(gca,'YTicklabel',0:1:30);
set(gca,'XTick',0:1:30);%坐标轴位置刻度
set(gca,'YTick',0:1:30)
figure_x = [0 30 30 0 ];
figure_y = [0 0  30 30 ];
patch(figure_x,figure_y,'green');
grid on; %网格线
%% 障碍物 obstacle
end

function initMap2()
figure(3);
hold on;
map =[
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	.3	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	1	0	0	.6	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	1	1	1	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
];
pcolor(map)
colormap summer
[row,col] = size(map);
[start_px,start_py] = find(map == .3);
[end_px,end_py] = find(map == .6);

close = struct([]); 
closelen = 0;
open = struct([]); 
openlen = 1;

%% 将起点添加到open列表
open(1).row = start_px;
open(1).col = start_py;
open(1).g = 0;
open(1).h = (end_py - start_py) + (end_px - start_px);

%% 四种运动格式
sport = [0,1;0,-1;-1,0;1,0];

while openlen > 0
    %% 获取代价最小的值
    for i = 1:openlen
        f(i) = [i,open(i).g + open(i).h];       
    end
    mincost = min(f);
    for i = 1:openlen
        if mincost == open(i).g + open(i).h
            current = open(i);
        end
    end
    dimNormal = all([current.row,current.col]+sport(i,:)>0) ...
        && current.row+sport(i,1)<=row && current.col+sport(i,2)<=col
    if dimNormal
        if current.row == end_px && current.col == end_py
            map(end_px,end_py) = 0.5;
            return;
        end
        
        if  map(current.row+sport(i,1),current.col+sport(i,2))~=1 %不为障碍物
            openlen = openlen + 1;
            open(openlen).row = current.row+sport(i,1);
            open(openlen).col = current.col+sport(i,2);
            open(openlen).g = current.g + 1;
            open(openlen).h = (end_py - open(openlen).row) + (end_px - open(openlen).col);
        end
        for i = 1:4
            u = [current.row,current.col] + sport(i);
            for j = 1 : closelen
                if close(j).row == u(1) && close(j).col == u(2)
                    continue;
                end
            end
            flag = 0;
            
            for k = 1 : openlen
                if open(k).row == u(1) && open(k).col == u(2)
                    flag = 1;
                    break;
                end
            end
            
            if ~flag
                openlen = openlen + 1;
                open(openlen).row = u(1);
                open(openlen).col = u(2);
                open(openlen).g = current.g + 1;
                open(openlen).h = end_py-u(2) + end_px -u(1);
            end   
        end
    end 
end    
end

