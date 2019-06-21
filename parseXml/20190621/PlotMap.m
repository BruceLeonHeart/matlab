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
    for j = 1:length(mGeos)
        plotGeo(mGeos(j),mGeos);
    end  
end
end

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
    if mGeo.lineType
    plot(ax,x_set,y_set,'linestyle','--','color','k');    
end


