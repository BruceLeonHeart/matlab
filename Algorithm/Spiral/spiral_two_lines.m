clc;
clear all;
Xg = 0;
Yg = 20.0;
Xs = -sqrt(Xg.^2 + Yg.^2);
Ys = 0;
%% 曲率变化率
C_12 = 0.012;
C_23 = - C_12;

%% 中点C2的切线方向
theta_c2 = atan(Yg/Xg)/2.0;

%% 起点C1
theta_c1 = 0.0;  %角度
k_c1 = 0.0;  %斜率 
Yc1 = 0.0;

S_12 = sqrt(2.0*theta_c2/C_12);
k_c2 = k_c1 + C_12*S_12;

%% 做积分准备
n = 100;
t = linspace(0,S_12,n);
x_12 = zeros(1,n);
y_12 = zeros(1,n);
x_23 = zeros(1,n);
y_23 = zeros(1,n);

%% 函数积分
cos12 = @(t)(cos(C_12*t.^2/2.0 + k_c1*t + theta_c1));
sin12 = @(t)(sin(C_12*t.^2/2.0 + k_c1*t + theta_c1));
cos23 = @(t)(cos(C_23*t.^2/2.0 + k_c2*t + theta_c2));
sin23 = @(t)(sin(C_23*t.^2/2.0 + k_c2*t + theta_c2));

%% 单段积分
for i= 1:n
    x_12(i) = integral(cos12,t(1),t(i));
    y_12(i) = integral(sin12,t(1),t(i));
    x_23(i) = integral(cos23,t(1),t(i));
    y_23(i) = integral(sin23,t(1),t(i));
end
    figure(1);
    plot(x_12,y_12);
    hold on
      plot(x_23,y_23);