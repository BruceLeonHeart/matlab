function  PlotMap(openDriveObj,ax0)
%PLOTMAP 绘制地图
% ax:坐标区对象
%　openDriveObj:地图对象
global ax;
ax = ax0;
roadObj = openDriveObj.road;

% for i =1:length(roadObj)
%     crtRoad = getSingleObject(roadObj,i);
%     fprintf("curRoad: %d \n",str2double(roadObj{1,i}.Attributes.id));
%     roadParse(crtRoad);  
% end
   crtRoad = getSingleObject(roadObj,2);
    fprintf("curRoad: %d \n",str2double(crtRoad.Attributes.id));
    roadParse(crtRoad); 
end

function roadParse(mRoadObj)  
    laneSectionList = mRoadObj.lanes.laneSection;
    [Geos,laneSections,laneSecMap] = OpenDriveUnitGeoLane(mRoadObj);
  
    %　绘制参考线
    plotGeo(Geos);
    %车道线基于参考线
    %laneSection中的每一个s至少对应一个geo
    %即对任意的一个laneSection，与geo的关系是一对一或者一对多
    %构建对应关系结构体
    
 
    %%lansection -- geo -lanesectionOffset对应关系
    %%整理新型数据机构关系，直接对接打印接口
    blocks = struct('laneSecIdx',[],'s',[],'id',[],'x',[],'y',[],'hdg',[],'mlength',[],'lineType',[],'curvature',[],'curvStart',[],'curvEnd',[],'offset',[],'sOffset',[]);
    %%遍历laneSections，新建blocks索引m
    m = 0;
    for i =1 :length(laneSections)
         crtLaneSec = laneSections(i);%当前laneSection
         if crtLaneSec.id ==0 || ~strcmp(crtLaneSec.type,'driving') %%去掉不符打印条件的路段
            continue;
         end
           
            crtLaneSectionId = crtLaneSec.laneSecIdx; %获取所属的laneSectionId
            startGeo = laneSecMap(crtLaneSectionId).startGeoNum;%获取起始的Geo
            endGeo = laneSecMap(crtLaneSectionId).endGeoNum;%获取终止的Geo
            if startGeo == endGeo %当前laneSection仅处于某一Geo
                m = m + 1;
                blocks(m).laneSecIdx =  crtLaneSec.laneSecIdx;
                blocks(m).s =  crtLaneSec.s;
                blocks(m).id =  crtLaneSec.id;
                tmpGeo = Geos(startGeo); %当前车道
                tmpLineType = tmpGeo.lineType; %当前车道线型
                if strcmp(tmpLineType,'line')
                    [x_f,y_f] = CoorGetFinalLine(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,0,0);%直线坐标
                    hdg_f = tmpGeo.hdg;

                elseif strcmp(tmpLineType,'arc')
                    [x_f,y_f] = CoorGetFinalArc(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,tmpGeo.curvature,0,0);%圆弧坐标
                    hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * tmpGeo.curvature;
                elseif strcmp(tmpLineType,'arc')
                    c = (tmpGeo.curvEnd - tmpGeo.curvStart) / tmpGeo.mlength;
                    cvstart = tmpGeo.curvStart;
                    cvend = tmpGeo.curvStart + c*(crtLaneSec.s - tmpGeo.s);
                    [x_f,y_f] = CoorGetFinalSpiral(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,cvstart,cvend,0,0);
                    hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * cvstart + c/2.0*(crtLaneSec.s - tmpGeo.s).^2;
                else
                    x_f = -9999;
                    y_f = -9999;
                end
                blocks(m).x = x_f;
                blocks(m).y = y_f;
                blocks(m).hdg = hdg_f;
                [sOffset,mlength] = getLanelength(crtLaneSec,tmpGeo,laneSectionList);
                blocks(m).mlength = mlength;
                blocks(m).lineType = tmpGeo.lineType;
                blocks(m).curvature = tmpGeo.curvature;
                blocks(m).curvStart = tmpGeo.curvStart;
                blocks(m).curvEnd = tmpGeo.curvEnd;
                blocks(m).offset = crtLaneSec.offset;
                blocks(m).sOffset = sOffset;           
            else
                    for j = 1:endGeo - startGeo+1
                        m = m + 1;
                        blocks(m).laneSecIdx =  crtLaneSec.laneSecIdx;
                        blocks(m).id =  crtLaneSec.id;
                        if j == 1
                            blocks(m).s =  crtLaneSec.s;
                            tmpGeo = Geos(startGeo); %当前车道
                            tmpLineType = tmpGeo.lineType; %当前车道线型
                            if strcmp(tmpLineType,'line')
                                [x_f,y_f] = CoorGetFinalLine(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,0,0);%直线坐标
                                hdg_f = tmpGeo.hdg;

                            elseif strcmp(tmpLineType,'arc')
                                [x_f,y_f] = CoorGetFinalArc(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,tmpGeo.curvature,0,0);%圆弧坐标
                                hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * tmpGeo.curvature;
                            elseif strcmp(tmpLineType,'arc')
                                c = (tmpGeo.curvEnd - tmpGeo.curvStart) / tmpGeo.mlength;
                                cvstart = tmpGeo.curvStart;
                                cvend = tmpGeo.curvStart + c*(crtLaneSec.s - tmpGeo.s);
                                [x_f,y_f] = CoorGetFinalSpiral(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,cvstart,cvend,0,0);
                                hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * cvstart + c/2.0*(crtLaneSec.s - tmpGeo.s).^2;
                            else
                                x_f = -9999;
                                y_f = -9999;
                            end
                            blocks(m).x = x_f;
                            blocks(m).y = y_f;
                            blocks(m).hdg = hdg_f;
                            [sOffset,mlength] = getLanelength(crtLaneSec,tmpGeo,laneSectionList);
                            blocks(m).mlength = mlength;
                            blocks(m).lineType = tmpGeo.lineType;
                            blocks(m).curvature = tmpGeo.curvature;
                            blocks(m).curvStart = tmpGeo.curvStart;
                            blocks(m).curvEnd = tmpGeo.curvEnd;
                            blocks(m).offset = crtLaneSec.offset;
                            blocks(m).sOffset = sOffset;       
                        else
                            blocks(m).s =  Geos(startGeo + j-1).s;
                            tmpGeo = Geos(startGeo + j-1); %当前车道
                            tmpLineType = tmpGeo.lineType; %当前车道线型
                            if strcmp(tmpLineType,'line')
                                [x_f,y_f] = CoorGetFinalLine(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,0,0);%直线坐标
                                hdg_f = tmpGeo.hdg;

                            elseif strcmp(tmpLineType,'arc')
                                [x_f,y_f] = CoorGetFinalArc(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,tmpGeo.curvature,0,0);%圆弧坐标
                                hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * tmpGeo.curvature;
                            elseif strcmp(tmpLineType,'arc')
                                c = (tmpGeo.curvEnd - tmpGeo.curvStart) / tmpGeo.mlength;
                                cvstart = tmpGeo.curvStart;
                                cvend = tmpGeo.curvStart + c*(crtLaneSec.s - tmpGeo.s);
                                [x_f,y_f] = CoorGetFinalSpiral(tmpGeo.x,tmpGeo.y,tmpGeo.hdg,crtLaneSec.s - tmpGeo.s,cvstart,cvend,0,0);
                                hdg_f = tmpGeo.hdg + (crtLaneSec.s - tmpGeo.s) * cvstart + c/2.0*(crtLaneSec.s - tmpGeo.s).^2;
                            else
                                x_f = -9999;
                                y_f = -9999;
                            end
                            blocks(m).x = x_f;
                            blocks(m).y = y_f;
                            blocks(m).hdg = hdg_f;
                            [sOffset,mlength] = getLanelength(crtLaneSec,tmpGeo,laneSectionList);
                            blocks(m).mlength = mlength;
                            blocks(m).lineType = tmpGeo.lineType;
                            blocks(m).curvature = tmpGeo.curvature;
                            blocks(m).curvStart = tmpGeo.curvStart;
                            blocks(m).curvEnd = tmpGeo.curvEnd;
                            blocks(m).offset = crtLaneSec.offset;
                            blocks(m).sOffset = sOffset;       
                        end
                 
                    end
        
                    
            end
    end
    
    
    
    
%     for j =1:length(laneSecMap)
%         crtLaneSec = getSingleObject(laneSectionList,j);
%         startGeo = laneSecMap(j).startGeoNum;
%         endGeo = laneSecMap(j).endGeoNum;
%         for j1 = 1:length(laneSections)
%             if laneSections(j1).s == str2double(crtLaneSec.Attributes.s)&& strcmp(laneSections(j1).type,'driving') && laneSections(j1).id~=0
%                 mLaneSection = laneSections(j1);
%                 for j2 = startGeo:endGeo
%                     plotLane(mLaneSection,Geos(j2));
%                 end
%             end
%         end
%     end  
%     for j =1:length(laneSections)
%         crtLaneSec =  laneSections(j);
%         crtLaneSec_S = crtLaneSec.s;
%         
%         if crtLaneSec.id~=0 && strcmp(crtLaneSec.type,'driving')
%             for j1 = 1:length(laneSecMap)
%                 crtSecMap =  laneSecMap(j1);
%                 if crtLaneSec.laneSecIdx == crtSecMap.laneSecIdx
%                      startGeo = crtSecMap.startGeoNum;
%                      endGeo = crtSecMap.endGeoNum;
%                      for j2 = startGeo:endGeo
%                           plotLane(crtLaneSec,Geos(j2));
%                      end
%                 end
%             end
%         end
%     end

    
    

     for j =1:length(laneSections)
        crtLaneSec =  laneSections(j);
        if crtLaneSec.id~=0 && strcmp(crtLaneSec.type,'driving')        
            msg = getlaneNearestGeo(crtLaneSec,Geos,laneSectionList);
            plotLane(crtLaneSec,msg);
            for j1 = 1:length(laneSecMap)
                if laneSecMap(j1).laneSecIdx == crtLaneSec.laneSecIdx
                    if laneSecMap(j1).startGeoNum ~= laneSecMap(j1).endGeoNum
                        startGeoNum = laneSecMap(j1).startGeoNum;
                        endGeoNum = laneSecMap(j1).endGeoNum;
                        for j2 = startGeoNum+1:endGeoNum
                            if ~isempty(crtLaneSec.s_end) && crtLaneSec.s_end > crtLaneSec.s + msg.mlength
                                crtLaneSec.s = crtLaneSec.s + msg.mlength;
                                
                            else
                                crtLaneSec.s = Geos(j2).s;
                            end
                            msg = getlaneNearestGeo(crtLaneSec,Geos,laneSectionList);
                            plotLane(crtLaneSec,msg);
                        end
                    end
                end
            end
        end
    end
end   

    

%%　绘制参考线
function plotGeo(Geos)
    global ax;
    for m = 1:length(Geos)
        msg = Geos(m);
        if msg.lineType == "line"
            linemsg = CoorGetLineSet(msg.x,msg.y,msg.hdg,msg.mlength,zeros(1,4),0,100);
            plot(ax,linemsg.xs,linemsg.ys,'linestyle','--','color','k');
            quiverX = linemsg.xs(1);
            quiverY = linemsg.ys(1);
            quiverX_add = (linemsg.xs(end)-linemsg.xs(1))/2;
            quiverY_add = (linemsg.ys(end)-linemsg.ys(1))/2;
            quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add,'linestyle','--','color','r','maxHeadsize',0.5);
        end
        if msg.lineType == "arc"
            arcmsg = CoorGetArcSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvature,zeros(1,4),0,100);
            plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','--');
        end
        if msg.lineType == "spiral"
            spiralmsg = CoorGetSpiralSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvStart,msg.curvEnd,zeros(1,4),0,100);
            plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','--');
        end
    end
end
%% 绘制车道线
function plotLane(mLaneSection,mGeo)
    global ax;
    if mGeo.lineType == "line"
        linemsg = CoorGetLineSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mLaneSection.offset,sign(mLaneSection.id),100);
        plot(ax,linemsg.xs,linemsg.ys,'linestyle','-');
        if sign(mLaneSection.id) == 1
            quiverX = linemsg.xs(end);
            quiverY = linemsg.ys(end);
            quiverX_add = (linemsg.xs(1)-linemsg.xs(end))/2;
            quiverY_add = (linemsg.ys(1)-linemsg.ys(end))/2;
            quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add);
        else
            quiverX = linemsg.xs(1);
            quiverY = linemsg.ys(1);
            quiverX_add = (linemsg.xs(end)-linemsg.xs(1))/2;
            quiverY_add = (linemsg.ys(end)-linemsg.ys(1))/2;
            quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add,'linestyle','--','color','g','maxHeadsize',0.5);
        end                       
    end
                
    if mGeo.lineType == "arc"
        arcmsg = CoorGetArcSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvature,mLaneSection.offset,sign(mLaneSection.id),100);
        plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
    end

    if mGeo.lineType == "spiral"
        spiralmsg = CoorGetSpiralSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mGeo.curvStart,mGeo.curvEnd,mLaneSection.offset,sign(mLaneSection.id),100);
        plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
    end
end

%%获取该段参考线长度
function [sOffset,mlength] = getLanelength(crtLaneSec,geo,laneSectionList)

    %sOffset与mlength大多数情况一致，但soffset存在多个值时，长度不一致
    mlength = geo.s + geo.mlength - crtLaneSec.s; %当前位置距离Geo尾部距离
    %存在后续laneSection的时候，需要取下一个laneSection的起始值与mlength中最小值
    if crtLaneSec.laneSecIdx < length(laneSectionList)
            nextLanesec = getSingleObject(laneSectionList,crtLaneSec.laneSecIdx +1);
            mlength1 = str2double(nextLanesec.Attributes.s) - crtLaneSec.s;
            mlength = min(mlength,mlength1);
    end
    sOffset = mlength;
    %当前段有后续的sOffset时，则还需要进一步比较
    if ~isempty(crtLaneSec.s_end)
        mlength2 = crtLaneSec.s_end - crtLaneSec.s ;
        mlength = min(mlength,mlength2);
        sOffset = crtLaneSec.s_end - crtLaneSec.s;
    end 
end

%%基于laneSections中最近的s值获取所属的Geo对应关系
function msg = getlaneNearestGeo(crtLaneSec,Geos,laneSectionList)
    msg = struct();

    laneSec_S = crtLaneSec.s;
    
    [idx,~] = CoorGetUnitMsg(laneSec_S,Geos);   
    if strcmp(Geos(idx).lineType,'line')
        [x_f,y_f] = CoorGetFinalLine(Geos(idx).x,Geos(idx).y,Geos(idx).hdg,laneSec_S - Geos(idx).s ,0,sign(crtLaneSec.id));
        msg.lineType = 'line';
        msg.x = x_f;
        msg.y = y_f;
        msg.hdg = Geos(idx).hdg;
        mlength1 = Geos(idx).s + Geos(idx).mlength - laneSec_S;
        msg.mlength = mlength1;
        if crtLaneSec.laneSecIdx < length(laneSectionList)
            nextLanesec = getSingleObject(laneSectionList,crtLaneSec.laneSecIdx +1);
            mlength2 = str2double(nextLanesec.Attributes.s) - laneSec_S;
            msg.mlength = min(mlength1,mlength2);
        end
        
        
        
        
    elseif strcmp(Geos(idx).lineType,'arc')
        [x_f,y_f] = CoorGetFinalArc(Geos(idx).x,Geos(idx).y,Geos(idx).hdg,laneSec_S - Geos(idx).s,Geos(idx).curvature,0,sign(crtLaneSec.id));
        msg.lineType = 'arc';
        msg.x = x_f;
        msg.y = y_f;
        msg.hdg = Geos(idx).hdg + (laneSec_S - Geos(idx).s) * Geos(idx).curvature;
        mlength1 = Geos(idx).s + Geos(idx).mlength - laneSec_S;
        msg.mlength = mlength1;
        if crtLaneSec.laneSecIdx < length(laneSectionList)
            nextLanesec = getSingleObject(laneSectionList,crtLaneSec.laneSecIdx +1);
             mlength2 = str2double(nextLanesec.Attributes.s) - laneSec_S;
            msg.mlength = min(mlength1,mlength2);
        end
        msg.curvature = Geos(idx).curvature;
    elseif strcmp(Geos(idx).lineType,'spiral')
        c = (Geos(idx).curvEnd - Geos(idx).curvStart) / Geos(idx).mlength;
        cvstart = Geos(idx).curvStart + c*(laneSec_S - Geos(idx).s);
        cvend = Geos(idx).curvStart +  c*(Geos(idx).s + Geos(idx).mlength - laneSec_S);
        [x_f,y_f] = CoorGetFinalSpiral(Geos(idx).x,Geos(idx).y,Geos(idx).hdg,laneSec_S - Geos(idx).s,cvstart,cvend,0,sign(crtLaneSec.id));
        msg.lineType = 'spiral';
        msg.x = x_f;
        msg.y = y_f;
        msg.hdg = Geos(idx).hdg + (laneSec_S - Geos(idx).s) * cvstart + c/2.0*(laneSec_S - Geos(idx).s).^2;
        mlength1 = Geos(idx).s + Geos(idx).mlength - laneSec_S;
        msg.mlength = mlength1;
        if crtLaneSec.laneSecIdx < length(laneSectionList)
            nextLanesec = getSingleObject(laneSectionList,crtLaneSec.laneSecIdx +1);
             mlength2 = str2double(nextLanesec.Attributes.s) - laneSec_S;
            msg.mlength = min(mlength1,mlength2);
        end
        msg.curvStart = cvstart;
        msg.curvEnd = cvend;
    end
    
    if ~isempty(crtLaneSec.s_end)
        mlength3 = crtLaneSec.s_end - laneSec_S ;
        msg.mlength = min(msg.mlength,mlength3);
    end
end

