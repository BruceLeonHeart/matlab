clear;
clc;
format long e
s   = 4.8660000002386400e-01;
x1  = -6.7269896520425938e+00;
y1  = 6.7269896522231525e+00;
hdg = 5.4977871437736381e+00; 
length = 3.1746031746031744e+00;
curvStart = -0.0000000000000000e+00;
curvEnd = -1.2698412698412698e-01;
delta =  curvEnd - curvStart;
cDot = delta/length;
curvFlag = sign(curvStart)&&sign(curvEnd);
% if curvFlag
%     t = hdg +pi/2;
% else
%     t = hdg +pi/2;
% end
temp_x = [];
temp_y = [];
% x = 0.0;
% y = 0.0;
x = 0.0;
y = 0.0;
t = 0.0;
for i = 0:0.01:length
    format long e;
    [x,y,t] = mspiral( i, cDot, x, y, t );
%     fprintf( "x: %f y:%f \n", x, y );
    r  = sqrt(x^2 + y^2);
    x_new = x*cos(hdg) - y*sin(hdg);
    y_new = y*cos(hdg) + x*sin(hdg);
    fprintf( "x: %f y:%f \n", x_new, y_new );
    temp_x = [temp_x x1+x_new];
    temp_y = [temp_y y1+y_new];
 
end
   plot(temp_x,temp_y);