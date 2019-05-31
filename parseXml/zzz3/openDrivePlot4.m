function  openDrivePlot4(openDriveObj,ax1)
global ax;
ax = ax1;
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
        msg = getMsgFromGeo(temp_tempGeo);
        if msg.lineType == "line"
            linemsg = linePointSet(msg.x,msg.y,msg.hdg,msg.mlength,0,0);
            line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','--','color','k');  
            quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','--','color','r','maxHeadsize',0.5);
        end
        if msg.lineType == "arc"
            arcmsg = arcPointSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvature,0,0);
            plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','--');
        end
        if msg.lineType == "spiral"
            spiralmsg = spiralPointSet(msg.x,msg.y,msg.hdg,msg.mlength,msg.curvStart,msg.curvEnd,0,0);
            plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','--');
        end
    end


    % 　绘制车道线
    % 找到laneSection与Geo的对应关系
    laneSectionRange = [];
    for n = 1:laneSectionListSize
        temp_laneSection = getSingleObject(laneSectionList,n);
        temp_laneSection_S = str2double(temp_laneSection.Attributes.s);
        msgResult = getGeoByLaneSection(mRoadObj,temp_laneSection_S);%车道的对应参考线信息
        laneSectionRange = [laneSectionRange,msgResult.id];
    end 
    if ~ismember(tempGeoListSize,laneSectionRange)
        laneSectionRange = [laneSectionRange,tempGeoListSize];
    end
   laneGeoMap = struct();
    if laneSectionRange(end) == 1
        laneGeoMap.id =1;
        laneGeoMap.geo = 1;
    else
        lsrSize = size(laneSectionRange,2);
        for k = 1:lsrSize            
            laneGeoMap(k).id = laneSectionRange(k);
            if k < lsrSize
                laneGeoMap(k).geo = laneSectionRange(k):laneSectionRange(k+1)-1;
            else
                laneGeoMap(k).geo = laneSectionRange(k):laneSectionRange(end);
            end
        end

    end
    %以laneSection为基准绘制下属的Geo区域
    for i0 = 1:length(laneGeoMap)
        crtlaneSection = laneGeoMap(i0).id;
        crtGeos = laneGeoMap(i0).geo;
        temp_laneSection = getSingleObject(laneSectionList,crtlaneSection);
        lanemsg = getMsgFromLaneSection(temp_laneSection);%车道信息
        for i1 = 1:length(crtGeos)
            crtgeo = getSingleObject(tempGeoList,crtGeos(i1));
            geomsg = getMsgFromGeo(crtgeo);
                for i2 = 1:size(lanemsg,1)
                laneId = lanemsg(i2,1);
                offset = lanemsg(i2,2);
                if geomsg.lineType == "line"
                    linemsg = linePointSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,offset,sign(laneId));
                    line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  
                    
                    if sign(laneId) == 1
                        quiver(ax,linemsg.x+linemsg.dx,linemsg.y+linemsg.dy,-linemsg.dx/2,-linemsg.dy/2);
                    else
                        quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
                    end
                        
                end
                if geomsg.lineType == "arc"
                    arcmsg = arcPointSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvature,offset,sign(laneId));
                    plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
                end
                if geomsg.lineType == "spiral"
                    spiralmsg = spiralPointSet(geomsg.x,geomsg.y,geomsg.hdg,geomsg.mlength,geomsg.curvStart,geomsg.curvEnd,offset,sign(laneId));
                    plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
                end
                end
        
        end
        
    end
    

    
 
    

%     for i0 = 1:laneSectionListSize
%         temp_laneSection = getSingleObject(laneSectionList,i0);
%         temp_laneSection_S = str2double(temp_laneSection.Attributes.s);
%         msgResult = getGeoByLaneSection(mRoadObj,temp_laneSection_S);%车道的对应参考线信息
%         lanemsg = getMsgFromLaneSection(temp_laneSection);%车道信息
% 
% 
% 
%         for i2 = 1:size(lanemsg,1)
%             laneId = lanemsg(i2,1);
%             offset = lanemsg(i2,2);
%             if msgResult.lineType == "line"
%                 linemsg = linePointSet(msgResult.x,msgResult.y,msgResult.hdg,msgResult.mlength,offset,sign(laneId));
%                 line(ax,[linemsg.x,linemsg.x+linemsg.dx],[linemsg.y,linemsg.y+linemsg.dy],'linestyle','-');  
%                 quiver(ax,linemsg.x,linemsg.y,linemsg.dx/2,linemsg.dy/2,'linestyle','-','color','g','maxHeadsize',0.5);
%             end
%             if msgResult.lineType == "arc"
%                 arcmsg = arcPointSet(msgResult.x,msgResult.y,msgResult.hdg,msgResult.mlength,msgResult.curvature,offset,sign(laneId));
%                 plot(ax,arcmsg.xs,arcmsg.ys,'linestyle','-');
%             end
%             if msgResult.lineType == "spiral"
%                 spiralmsg = spiralPointSet(msgResult.x,msgResult.y,msgResult.hdg,msgResult.mlength,msgResult.curvStart,msgResult.curvEnd,offset,sign(laneId));
%                 plot(ax,spiralmsg.xs,spiralmsg.ys,'linestyle','-');
%             end
%         end
%     end
end      
