function  PlotMap(openDriveObj,ax0)
%PLOTMAP 绘制地图
% ax:坐标区对象
%　openDriveObj:地图对象
global ax;
ax = ax0;
roadObj = openDriveObj.road;
%     crtRoad = getSingleObject(roadObj,2);
%     fprintf("curRoad: %d \n",str2double(roadObj{1,2}.Attributes.id));
%     [mGeos,mOffsets] = OpenDriveParser(crtRoad);
%     for j = 1:length(mGeos)
%         plotGeo(mGeos(j),mGeos);
%     end

    for i =1:length(roadObj)
        crtRoad = getSingleObject(roadObj,i);
        fprintf("curRoad: %d \n",str2double(roadObj{1,i}.Attributes.id));
        [mGeos,mOffsets] = OpenDriveParser(crtRoad);
        RoadGeoEnd =  mGeos(end).s + mGeos(end).mlength;
        
        %打印参考线
        for j = 1:length(mGeos)
            plotGeo(mGeos(j),mGeos);
        end  
        
        %遍历mOffsets，提取type为driving的车道
        laneId = [];
        for m = 1:length(mOffsets)
            if strcmp(mOffsets(m).type,'driving')
                laneId = [laneId , mOffsets(m).id];
            end
        end
        %去除重复元素
        laneId = unique(laneId);
        for n = 1:length(mGeos)
            for n1 = 1:length(laneId)
                plotLane(mGeos(n),mGeos,laneId(n1),mOffsets,RoadGeoEnd);
            end
        end     
    end
end



%打印参考线
function plotGeo(mGeo,mGeos)
    global ax;
    delta_s = 0.5;
    x_set = [];
    y_set = [];
    sValueSet = mGeo.s:delta_s:mGeo.s + mGeo.mlength;
    for j = 1:length(sValueSet)
        [x_s,y_s,~] = OpenDriveGetSXY(sValueSet(j),mGeos);
        x_set = [x_set,x_s];
        y_set = [y_set,y_s];
    end
    plot(ax,x_set,y_set,'linestyle','--','color','k'); 
    if strcmp(mGeo.lineType,'line')
        quiverX = x_set(1);
        quiverY = y_set(1);
        quiverX_add = (x_set(end)-x_set(1))/2;
        quiverY_add = (y_set(end)-y_set(1))/2;
        quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add,'linestyle','--','color','r','maxHeadsize',0.5);
    end
end

%打印车道线
function plotLane(mGeo,mGeos,id,mOffsets,RoadGeoEnd)
    global ax;
    delta_s = 0.5;
    x_set = [];
    y_set = [];
    sValueSet = mGeo.s:delta_s:mGeo.s + mGeo.mlength;
    for j = 1:length(sValueSet)
        [x_s,y_s,hdg] = OpenDriveGetSXY(sValueSet(j),mGeos);
        offset = OpenDriveGetSOffset(sValueSet(j),id,mOffsets,RoadGeoEnd);
        x = x_s + offset*cos(hdg + sign(id)*pi/2);
        y = y_s + offset*sin(hdg + sign(id)*pi/2);
        x_set = [x_set,x];
        y_set = [y_set,y];
    end
    plot(ax,x_set,y_set,'color','k');
    if strcmp(mGeo.lineType,'line')
        if sign(id) == -1
            quiverX = x_set(1);
            quiverY = y_set(1);
            quiverX_add = (x_set(end)-x_set(1))/2;
            quiverY_add = (y_set(end)-y_set(1))/2;
            quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add,'color','r','maxHeadsize',0.5);
        end
        
        if sign(id) == 1
            quiverX = x_set(end);
            quiverY = y_set(end);
            quiverX_add = (x_set(1)-x_set(end))/2;
            quiverY_add = (y_set(1)-y_set(end))/2;
            quiver(ax,quiverX,quiverY,quiverX_add,quiverY_add,'color','r','maxHeadsize',0.5);
        end
    end
end
