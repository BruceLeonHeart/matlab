clear;
clc;
clf;
figure(1);
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
0	0	0	0	0	0	0	0	1	0	0	.7	0	0	0	0	0
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
[end_px,end_py] = find(map == .7);

close = struct([]); 
closelen = 0;
open = struct([]); 
openlen = 0;

%% 将起点添加到open列表
open(1).row = start_px;
open(1).col = start_py;
open(1).g = 0;
open(1).h = abs(end_py - start_py) + abs(end_px - start_px);
openlen = openlen + 1;
%% 四种运动格式
sport = [0,1;0,-1;-1,0;1,0];
backNum = 0;
prev = [];
while openlen > 0
    %% 获取代价最小的值
    for i = 1:openlen
        f(i,:) = [i,open(i).g + open(i).h];       
    end
    f1 = sortrows(f,2);
    current = open(f1(1));
    choose = 0;
    chooseArr = [];
    %% 回溯将走过的点标记出来
     if current.row == end_px && current.col == end_py
         i = 1;
         while(i<=size(prev,1))
             if prev(i,3) == current.row && prev(i,4) == current.col
                 choose = choose +1;
                 chooseArr(choose,1) = prev(i,1);
                 chooseArr(choose,2) = prev(i,2);
                 current.row =  prev(i,1);
                 current.col =  prev(i,2);
                 i = 1;
             else
                 i = i + 1;
             end
         end      
         for j = 1: size(chooseArr,1)
                map(chooseArr(j,1),chooseArr(j,2)) = 0.5;
         end
         figure(2);
         pcolor(map);
         colormap spring;
         return;         
     end
     closelen = closelen + 1;
     close(closelen).row = open(f1(1)).row;
     close(closelen).col = open(f1(1)).col;
     close(closelen).g = open(f1(1)).g;
     close(closelen).h = open(f1(1)).h;   
     open(f1(1)) = [];
     openlen = openlen -1;     
    for i = 1:4
        dimNormal = all([current.row,current.col]+sport(i,:)>0) ...
            && current.row+sport(i,1)<=row && current.col+sport(i,2)<=col;
        neighbor.row = current.row + sport(i,1);
        neighbor.col = current.col + sport(i,2);
        neighbor.g = abs(start_px - neighbor.row) + abs(start_py - neighbor.col);
        neighbor.h = abs(end_px - neighbor.row) + abs(end_py - neighbor.col);
    
       
        if dimNormal
            inCloseFlag = 0; 
            if closelen ==0
            else
                for j = 1:closelen
                    if close(j).row == neighbor.row && close(j).col ==neighbor.col
                        inCloseFlag = 1;
                        break;
                    end
                end
            end
        
            if inCloseFlag
                continue;
            end
            
            temp_g = current.g + abs(current.row - neighbor.row) + abs(current.col - neighbor.col);
            inOpenFlag = 0;
            for j =1:openlen
                if open(j).row == neighbor.row && open(j).col ==neighbor.col
                    inOpenFlag = 1;
                    break;
                end
            end        
            if ~inOpenFlag && map(neighbor.row,neighbor.col) ~= 1
                openlen = openlen + 1;
                open(openlen).row = neighbor.row;
                open(openlen).col = neighbor.col;
                open(openlen).g = abs(start_px - neighbor.row) + abs(start_py - neighbor.col);
                open(openlen).h = abs(end_px - neighbor.row) + abs(end_py - neighbor.col);               
            elseif temp_g >= neighbor.g
                continue;
            end
                backNum = backNum +1;
                prev(backNum,:) = [current.row ,current.col,neighbor.row ,neighbor.col];
                neighbor.g = temp_g;            
        else
            continue;
        end
    end     
end



