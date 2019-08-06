function [outputArg1,outputArg2] = ApfMain(inputArg1,inputArg2)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end


%% 计算角度
function Y=compute_angle(X,Xsum,n)
    for i = 1:n+1
        deltaX(i) = Xsum(i,1) - X(1);
        deltaY(i) = Xsum(i,2) - X(2);
        r(i) = sqrt(deltaX(i)^2 + deltaY(i)^2);
    theta=sign(deltaY(i))*acos(deltaX(i)/r(i));
    angle=theta;
    Y(i)=angle;
    end
end
%% 计算引力
function [Yatx,YatY]=compute_Attract(X,Xsum,k,angle)
% X:当前坐标
% Xsum:目标坐标
% k:增益常数
% angle:分量与力的角度
R=(X(1)-Xsum(1,1))^2 + (X(2)-Xsum(1,2))^2;
r=sqrt(R);
Yatx=k*r*cos(angle);
YatY=k*r*sin(angle);
end
%% 计算斥力
function [Yrerxx,Yreryy,Yataxx,Yatayy]=compute_repulsion(X,Xsum,m,angle_at,angle_re,n,Po,a)
% X:当前坐标
% Xsum:目标和障碍的坐标向量
Rat = (X(1)-Xsum(1,1))^2 + (X(2)-Xsum(1,2))^2;
rat = sqrt(Rat); %当前点与目标的距离
for i=1:n
    Rre(i) = (X(1)-Xsum(i+1,1))^2 + (X(2)-Xsum(i+1,2))^2;
    rre(i) = sqrt(Rre(i));%当前点与障碍的距离数组
    if rre(i) > Po %　每个障碍物和当前的距离大于障碍影响的距离，斥力为０
        Yrerx(i)=0;
        Yrery(i)=0;
        Yatax(i)=0;
        Yatay(i)=0;
    else
        if rre(i)<Po/2
            Yrer(i)=m*(1/rre(i)-1/Po)*(1/Rre(i))*(rat^a); %分解的Fre1向量
            Yata(i)=a*m*((1/rre(i)-1/Po)^2)*(rat^(1-a))/2;%分解的Fre2向量
            Yrerx(i)=(1+0.1)*Yrer(i)*cos(angle_re(i)+pi);
            Yrery(i)=-(1+0.1)*Yrer(i)*sin(angle_re(i)+pi);
            Yatax(i)=Yata(i)*cos(angle_at);
            Yatay(i)=Yata(i)*sin(angle_at);
        else
            Yrer(i)=m*(1/rre(i)-1/Po)*(1/Rre(i))*Rat; %分解的Fre1向量
            Yata(i)=m*((1/rre(i)-1/Po)^2)*rat;%分解的Fre2向量
            Yrerx(i)=Yrer(i)*cos(angle_re(i)+pi);
            Yrery(i)=Yrer(i)*sin(angle_re(i)+pi);
            Yatax(i)=Yata(i)*cos(angle_at);
            Yatay(i)=Yata(i)*sin(angle_at);
        end
    end
end
Yrerxx=sum(Yrerx);
Yreryy=sum(Yrery);
Yataxx=sum(Yatax);
Yatayy=sum(Yatay);
end