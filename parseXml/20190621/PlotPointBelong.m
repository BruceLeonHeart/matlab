function plotList = PlotPointBelong(ax,pointX,pointY,point)
%plotList:记录点归属的列表
plotList = plot(ax,pointX,pointY,'+');
plotList = [plotList ; line(ax,[pointX point.x_offset],[pointY point.y_offset],'linestyle','--')];
end

