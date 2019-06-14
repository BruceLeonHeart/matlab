function test(fileName)
FileObj = xml2struct(fileName);
openDriveObj = FileObj.OpenDRIVE;
roadObj = openDriveObj.road;
 crtRoad = getSingleObject(roadObj,3);
    roadParse(crtRoad); 
% for i =1:length(roadObj)
%     crtRoad = getSingleObject(roadObj,i);
%     fprintf("curRoad: %d \n",str2double(roadObj{1,i}.Attributes.id));
%     roadParse(crtRoad);  
% end
end

function roadParse(mRoadObj)
    %%将geo与laneSection分别做成结构体进行记录
    
    %　参考线部分
    tempGeoList = mRoadObj.planView.geometry;
    tempGeoListSize = length(tempGeoList);
    Geos = struct('s',[],'x',[],'y',[],'hdg',[],'mlength',[],'lineType',[],'curvature',[],'curvStart',[],'curvEnd',[]);
    for m = 1:tempGeoListSize     
        crtmsg = OpenDriveGetGeoMsg(getSingleObject(tempGeoList,m));
        Geos(m) = crtmsg;
        
%         Geos(m).s = crtmsg.s;
%         Geos(m).x = crtmsg.x;
%         Geos(m).y = crtmsg.y;
%         Geos(m).hdg = crtmsg.hdg;
%         Geos(m).mlength = crtmsg.mlength;
%         Geos(m).lineType = crtmsg.lineType;
%         if strcmp(crtmsg.lineType,"line")
%         elseif strcmp(crtmsg.lineType,"arc")
%             Geos(m).curvature = crtmsg.curvature;
%         elseif strcmp(crtmsg.lineType,"spiral")
%             Geos(m).curvStart = crtmsg.curvStart ;
%             Geos(m).curvEnd = crtmsg.curvEnd ;
%         end
    end
    

    %　车道部分
    laneSectionList = mRoadObj.lanes.laneSection;
    laneSectionListSize = length(laneSectionList);
    laneSections = struct('s',[],'id',[],'type',[],'offset',[],'speed',[]);
    k = 1;
    for n = 1:laneSectionListSize
        laneSectionsMsg = OpenDriveGetLaneSecMsg1(getSingleObject(laneSectionList,n));
        for n1 = 1 :length(laneSectionsMsg)
            laneSections(k) = laneSectionsMsg(n1);
            k = k + 1;
        end
        
    end
    
    
    %　绘制参考线
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


    %车道线基于参考线
    for n = 1:length(laneSections)
        if strcmp(laneSections(n).type,'driving')&& laneSections(n).id~=0
            belongGeo = getUnitMsg(laneSections(n).s,Geos);
                if belongGeo.lineType == "line"
                    linemsg = CoorGetLineSet(belongGeo.x,belongGeo.y,belongGeo.hdg,belongGeo.mlength,laneSections(n).offset,sign(laneSections(n).id));
                    line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  

                    if sign(laneSections(n).id) == 1
                        quiver(ax,linemsg.x+linemsg.dx,linemsg.y+linemsg.dy,-linemsg.dx/2,-linemsg.dy/2);
                    else
                        quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
                    end
                        
                end
                if belongGeo.lineType == "arc"
                    arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId),100);
                    plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
                end
                if belongGeo.lineType == "spiral"
                    spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId),100);
                    plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
                end
        end
    end
    
%     % 　绘制车道线
%     % 找到laneSection与Geo的对应关系
%     laneGeoMap = OpenDriveUnitGeoLane(mRoadObj);
%     
%     %以laneSection为基准绘制下属的Geo区域
%     for i0 = 1:length(laneGeoMap)
%         crtlaneSection = laneGeoMap(i0).id;
%         crtGeos = laneGeoMap(i0).geo;
%         temp_laneSection = getSingleObject(laneSectionList,crtlaneSection);
%         lanemsg = OpenDriveGetLaneSecMsg(temp_laneSection);%车道信息
%         for i1 = 1:length(crtGeos)
%             crtgeo = getSingleObject(tempGeoList,crtGeos(i1));
%             geomsg = OpenDriveGetGeoMsg(crtgeo);
%                 for i2 = 1:size(lanemsg,1)
%                 laneId = lanemsg(i2,1);
%                 offset = lanemsg(i2,2);
%                 if geomsg.lineType == "line"
%                     linemsg = CoorGetLineSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,offset,sign(laneId));
%                     line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  
%                     
%                     if sign(laneId) == 1
%                         quiver(ax,linemsg.x+linemsg.dx,linemsg.y+linemsg.dy,-linemsg.dx/2,-linemsg.dy/2);
%                     else
%                         quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
%                     end
%                         
%                 end
%                 if geomsg.lineType == "arc"
%                     arcmsg = CoorGetArcSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId),100);
%                     plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
%                 end
%                 if geomsg.lineType == "spiral"
%                     spiralmsg = CoorGetSpiralSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId),100);
%                     plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
%                 end
%                 end
%         
%         end
%         
%     end
    
end   

%当前的laneSection从geos中寻找参考信息
function unitMsg = getUnitMsg(s,Geos)
    for i = 1:length(Geos)
        tempS_end = Geos(i).s + Geos(i).mlength;
        if Geos(i).s <= s && tempS_end > s
            unitMsg = Geos(i);
            break;
        end
    end
end