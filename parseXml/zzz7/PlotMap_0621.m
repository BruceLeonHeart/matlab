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

