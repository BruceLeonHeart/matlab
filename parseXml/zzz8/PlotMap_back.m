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
global ax;
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    
    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    
    %　绘制参考线
    for m = 1:tempGeoListSize
        temp_tempGeo = getSingleObject(tempGeoList,m);
        msg = OpenDriveGetGeoMsg(temp_tempGeo);
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


    % 　绘制车道线
    % 找到laneSection与Geo的对应关系
    laneGeoMap = OpenDriveUnitGeoLane(mRoadObj);
    
    %以laneSection为基准绘制下属的Geo区域
    for i0 = 1:length(laneGeoMap)
        crtlaneSection = laneGeoMap(i0).id;
        crtGeos = laneGeoMap(i0).geo;
        temp_laneSection = getSingleObject(laneSectionList,crtlaneSection);
        lanemsg = OpenDriveGetLaneSecMsg(temp_laneSection);%车道信息
        for i1 = 1:length(crtGeos)
            crtgeo = getSingleObject(tempGeoList,crtGeos(i1));
            geomsg = OpenDriveGetGeoMsg(crtgeo);
                for i2 = 1:size(lanemsg,1)
                laneId = lanemsg(i2,1);
                offset = lanemsg(i2,2);
                if geomsg.lineType == "line"
                    linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,offset,sign(laneId));
                    line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  
                    
                    if sign(laneId) == 1
                        quiver(ax,linemsg.x+linemsg.dx,linemsg.y+linemsg.dy,-linemsg.dx/2,-linemsg.dy/2);
                    else
                        quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
                    end
                        
                end
                if geomsg.lineType == "arc"
                    arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId),100);
                    plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
                end
                if geomsg.lineType == "spiral"
                    spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId),100);
                    plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
                end
                end
        
        end
        
    end
    
end      
