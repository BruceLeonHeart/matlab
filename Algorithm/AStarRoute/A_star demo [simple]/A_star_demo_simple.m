%% Demo of ASTAR algorithm
% by carry-xz 20170325
clc;
clear;
%% initialize constant
n=20;
% starNum = randi(n*n,[1,1]);
starNum = 1;
goalNum = randi(n*n,[1,1]);
% goalNum=172;
banper=0.25;
%% initialize the map
figure('name','A*','NumberTitle','off','MenuBar','none');
global point
for ii=1:n*n
    point(ii).num = ii;
    point(ii).father=[];
    point(ii).Gcost=[];
    point(ii).Hcost=[];
end
%% set up barriers
banList=[randi(n*n,[1,floor(banper*n*n)])];
banList(banList==goalNum)=[];
for jj = 1:length(banList)
    if banList(jj)~=goalNum || banList(jj)~=starNum
        point(banList(jj)).Gcost = Inf;
    end
end
point(starNum).Gcost=0;
point(starNum).father = point(starNum).num;
point(starNum).Hcost=getHcost(point(starNum),point(goalNum),n);

%% main loop
openList = [];
closeList = [];
closeListNum=[];
openListNum=[];
openList = [openList,point(starNum)];
while ~isempty(openList)
    % get the cost of opneList,find costs and heuristic of moving to neighbor spaces to goal
    costList = getCost(openList,point(goalNum),n);
    currentPoint = openList(find(costList==min(costList),1));
    openList(find(min(costList)==costList,1))=[];
    closeList = [closeList,currentPoint];
    neighbourNum = getNeighbour(currentPoint,n);
    closeListNum = cat(1,closeList.num);
    openListNum = cat(1,openList.num);
    for ii = 1:length(neighbourNum)
        if neighbourNum(ii)==point(goalNum).num
            point(neighbourNum(ii)).father = currentPoint.num;
            point(goalNum).father = currentPoint.num;
            disp('ok')
            routPlot(goalNum,n);
            return;
        end
        testc = 0;
        try
            if point(neighbourNum(ii)).Gcost == Inf
                testc=1;
            end
        catch
            testc = 0;
        end
        %if cost infinite or the point in closeListNum,ignore
        if testc ||  ismember(neighbourNum(ii),closeListNum)
            continue;
            
        elseif ismember(neighbourNum(ii),openListNum)
            %if the point in openList,try to change the father point to
            % current point,compare the old cost and new cost.if new cost
            % biger then old cost,change the father point to the old one.
            oldGcost = getGcost(point(neighbourNum(ii)),n);
            father = point(neighbourNum(ii)).father;
            point(neighbourNum(ii)).father = currentPoint.num;
            newGcost = getGcost(point(neighbourNum(ii)),n);
            if newGcost>oldGcost
                point(neighbourNum(ii)).father = father;
            end
            continue;
        elseif ~ismember(neighbourNum(ii),closeListNum)
            %else put the point into the openList.
            point(neighbourNum(ii)).father = currentPoint.num;
            point(neighbourNum(ii)).Gcost = getGcost(point(neighbourNum(ii)),n);
            point(neighbourNum(ii)).Hcost = getHcost(point(neighbourNum(ii)),point(goalNum),n);
            openList = [openList,point(neighbourNum(ii))];
        end
    end
    closeListNum = cat(1,closeList.num);
    openListNum = cat(1,openList.num);
    pause(0.25);
    mydrawnow(starNum,goalNum,banList,closeListNum,openListNum,n);
end


