c = figure(1)
arrowPlot([1 2],[4 8])
     t = [0:0.01:20];
     x = t.*cos(t);
     y = t.*sin(t);
     arrowPlot(x, y, 'number', 3)
% annotation('arrow',[0 0.5],[0.5 1]) % 建立从(x(1), y(1))到(x(2), y(2))的箭头注释对象。