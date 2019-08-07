%初始化车的参数
Xo=[0 0];%起点位置
k=15;%计算引力需要的增益系数
K=0;%初始化
m=5;%计算斥力的增益系数，都是自己设定的。
Po=2.5;%障碍影响距离，当障碍和车的距离大于这个距离时，斥力为0，即不受该障碍的影响。也是自己设定。
n=7;%障碍个数
a=0.5;
l=0.2;%步长
J=200;%循环迭代次数
%如果不能实现预期目标，可能也与初始的增益系数，Po设置的不合适有关。
%end
%给出障碍和目标信息
Xsum=[10 10;1 1.2;3 2.5;4 4.5;3 6;6 2;5.5 5.5;8 8.5];%这个向量是(n+1)*2维，其中[10 10]是目标位置，剩下的都是障碍的位置。
Xj=Xo;%j=1循环初始，将车的起始坐标赋给Xj
%***************初始化结束，开始主体循环******************
for j=1:J %循环开始
Goal(j,1)=Xj(1); %Goal是保存车走过的每个点的坐标。刚开始先将起点放进该向量。
Goal(j,2)=Xj(2);
%调用计算角度模块
Theta=compute_angle(Xj,Xsum,n);%Theta是计算出来的车和障碍，和目标之间的与X轴之间的夹角，统一规定角度为逆时针方向，用这个模块可以计算出来。

%调用计算引力模块
Angle=Theta(1);%Theta（1）是车和目标之间的角度，目标对车是引力。
angle_at=Theta(1);%为了后续计算斥力在引力方向的分量赋值给angle_at
[Fatx,Faty]=compute_Attract(Xj,Xsum,k,Angle,0,Po,n); %计算出目标对车的引力在x,y方向的两个分量值。
for i=1:n
angle_re(i)=Theta(i+1);%计算斥力用的角度，是个向量，因为有n个障碍，就有n个角度。
end

%调用计算斥力模块
[Frerxx,Freryy,Fataxx,Fatayy]=compute_repulsion(Xj,Xsum,m,angle_at,angle_re,n,Po,a);%计算出斥力在x,y方向的分量数组。
%计算合力和方向，这有问题，应该是数，每个j循环的时候合力的大小应该是一个唯一的数，不是数组。应该把斥力的所有分量相加，引力所有分量相加。
Fsumyj=Faty+Freryy+Fatayy;%y方向的合力
Fsumxj=Fatx+Frerxx+Fataxx;%x方向的合力
Position_angle(j)=atan(Fsumyj/Fsumxj);%合力与x轴方向的夹角向量

%计算车的下一步位置
Xnext(1)=Xj(1)+l*cos(Position_angle(j));
Xnext(2)=Xj(2)+l*sin(Position_angle(j));
%保存车的每一个位置在向量中
Xj=Xnext;
%判断
if ((Xj(1)-Xsum(1,1))>0)&((Xj(2)-Xsum(1,2))>0) %是应该完全相等的时候算作到达，还是只是接近就可以？现在按完全相等的时候编程。
    K=j;%记录迭代到多少次，到达目标。
break;
%记录此时的j值
end%如果不符合if的条件，重新返回循环，继续执行。
end%大循环结束

K=j;
Goal(K,1)=Xsum(1,1);%把路径向量的最后一个点赋值为目标
Goal(K,2)=Xsum(1,2);

%***********************************画出障碍，起点，目标，路径点*************************
%画出路径
X=Goal(:,1);
Y=Goal(:,2);
%路径向量Goal是二维数组,X,Y分别是数组的x,y元素的集合，是两个一维数组。
x=[1 3 4 3 6 5.5 8];%障碍的x坐标
y=[1.2 2.5 4.5 6 2 5.5 8.5];
plot(x,y,'o',10,10,'v',0,0,'ms',X,Y,'.r');


function Y=compute_angle(X,Xsum,n)%Y是引力，斥力与x轴的角度向量,X是起点坐标，Xsum是目标和障碍的坐标向量,是(n+1)*2矩阵
for i=1:n+1%n是障碍数目
    deltaX(i)=Xsum(i,1)-X(1);
    deltaY(i)=Xsum(i,2)-X(2);
    r(i)=sqrt(deltaX(i)^2+deltaY(i)^2);
    if deltaX(i)>0
        theta=acos(deltaX(i)/r(i));
    else
        theta=pi-acos(deltaX(i)/r(i));
    end
    if i==1%表示是目标
        angle=theta;
    else
        angle=theta;
    end
Y(i)=angle;%保存每个角度在Y向量里面，第一个元素是与目标的角度，后面都是与障碍的角度
end
end

function [Yatx,Yaty]=compute_Attract(X,Xsum,k,angle,b,Po,n)%输入参数为当前坐标，目标坐标，增益常数,分量和力的角度
%把路径上的临时点作为每个时刻的Xgoal
R=(X(1)-Xsum(1,1))^2+(X(2)-Xsum(1,2))^2;%路径点和目标的距离平方
r=sqrt(R);%路径点和目标的距离
Yatx=k*r*cos(angle);%angle=Y(1)
Yaty=k*r*sin(angle);
end

function [Yrerxx,Yreryy,Yataxx,Yatayy]=compute_repulsion(X,Xsum,m,angle_at,angle_re,n,Po,a)%输入参数为当前坐标，Xsum是目标和障碍的坐标向量，增益常数,障碍，目标方向的角度
Rat=(X(1)-Xsum(1,1))^2+(X(2)-Xsum(1,2))^2;%路径点和目标的距离平方
rat=sqrt(Rat);%路径点和目标的距离
for i=1:n
    Rrei(i)=(X(1)-Xsum(i+1,1))^2+(X(2)-Xsum(i+1,2))^2;%路径点和障碍的距离平方
    rre(i)=sqrt(Rrei(i));%路径点和障碍的距离保存在数组rrei中
    R0=(Xsum(1,1)-Xsum(i+1,1))^2+(Xsum(1,2)-Xsum(i+1,2))^2;
    r0=sqrt(R0);
    if rre(i)>Po%如果每个障碍和路径的距离大于障碍影响距离，斥力令为0
        Yrerx(i)=0;
        Yrery(i)=0;
        Yatax(i)=0;
        Yatay(i)=0;
    else
%if r0<Po
    if rre(i)<Po/2
        Yrer(i)=m*(1/rre(i)-1/Po)*(1/Rrei(i))*(rat^a);%分解的Fre1向量
        Yata(i)=a*m*((1/rre(i)-1/Po)^2)*(rat^(1-a))/2;%分解的Fre2向量
        Yrerx(i)=(1+0.1)*Yrer(i)*cos(angle_re(i));%angle_re(i)=Y(i+1)
        Yrery(i)=-(1-0.1)*Yrer(i)*sin(angle_re(i));
        Yatax(i)=Yata(i)*cos(angle_at);%angle_at=Y(1)
        Yatay(i)=Yata(i)*sin(angle_at);
    else
        Yrer(i)=m*(1/rre(i)-1/Po)*1/Rrei(i)*Rat;%分解的Fre1向量
        Yata(i)=m*((1/rre(i)-1/Po)^2)*rat;%分解的Fre2向量
        Yrerx(i)=Yrer(i)*cos(angle_re(i));%angle_re(i)=Y(i+1)
        Yrery(i)=Yrer(i)*sin(angle_re(i));
        Yatax(i)=Yata(i)*cos(angle_at);%angle_at=Y(1)
        Yatay(i)=Yata(i)*sin(angle_at);
    end
    end%判断距离是否在障碍影响范围内
end
    Yrerxx=sum(Yrerx);%叠加斥力的分量
    Yreryy=sum(Yrery);
    Yataxx=sum(Yatax);
    Yatayy=sum(Yatay);
end
