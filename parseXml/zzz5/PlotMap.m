function  PlotMap(openDriveObj,ax0)
%PLOTMAP 绘制地图
% ax:坐标区对象
%　openDriveObj:地图对象
global ax;
ax = ax0;
roadObj = openDriveObj.road;

for i =1:length(roadObj)
    crtRoad = getSingleObject(roadObj,i);
    fprintf("curRoad: %d \n",str2double(roadObj{1,i}.Attributes.id));
    roadParse(crtRoad);  
end
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
    for j =1:length(laneSecMap)
        crtLaneSec = getSingleObject(laneSectionList,j);
        startGeo = laneSecMap(j).startGeoNum;
        endGeo = laneSecMap(j).endGeoNum;
        for j1 = 1:length(laneSections)
            if laneSections(j1).s == str2double(crtLaneSec.Attributes.s)&& strcmp(laneSections(j1).type,'driving') && laneSections(j1).id~=0
                mLaneSection = laneSections(j1);
                for j2 = startGeo:endGeo
                    plotLane(mLaneSection,Geos(j2));
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
            linemsg = CoorGetLineSet(msg.x,msg.y,msg.hdg,msg.mlength,0,0);
            line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','--','color','k');  
            quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','--','color','r','maxHeadsize',0.5);
        end
        if msg.lineType == "arc"
            arcmsg = CoorGetArcSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvature,0,0,100);
            plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','--');
        end
        if msg.lineType == "spiral"
            spiralmsg = CoorGetSpiralSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvStart,msg.curvEnd,0,0,100);
            plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','--');
        end
    end
end
%% 绘制车道线
function plotLane(mLaneSection,mGeo)
    global ax;
    if mGeo.lineType == "line"
        linemsg = CoorGetLineSet(mGeo.x,mGeo.y,mGeo.hdg,mGeo.mlength,mLaneSection.offset,sign(mLaneSection.id));
        line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  
        if sign(mLaneSection.id) == 1
            quiver(ax,linemsg.x+linemsg.dx,linemsg.y+linemsg.dy,-linemsg.dx/2,-linemsg.dy/2);
        else
            quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
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