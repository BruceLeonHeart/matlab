clear;
clc;
format long
s=4.8660000002386400e-01;
x=-6.7269896520425938e+00;
y=6.7269896522231525e+00;
hdg=5.4977871437736381e+00; 
length=3.1746031746031744e+00;
curvStart=-0.0000000000000001e+00;
curvEnd=-1.2698412698412698e-01;
delta =  curvEnd - curvStart;
curvFlag = sign(curvStart)&&sign(curvEnd);
temp_x = [];
temp_y = []

last_theta = hdg - pi/2;
last_c = abs(curvStart);
last_r = 1/last_c;
for i = 0:0.001:length
    format long;
    cur_c = abs((curvStart + i/length*(delta)));
    cur_r = 1/cur_c;
    cur_theta = (hdg - pi/2 + curvFlag*i.^2/length*delta);
    
 
    
    temp_x = [temp_x x + cur_r*cos(cur_theta) - last_r*cos(last_theta)];
    temp_y = [temp_y y + cur_r*sin(cur_theta) - last_r*sin(last_theta)]; 
    last_c = abs((curvStart + i/length*(delta)));
    last_r = 1/last_c;
    last_theta = (hdg - pi/2 + curvFlag*i.^2/length*delta);
 
end
   plot(temp_x,temp_x);