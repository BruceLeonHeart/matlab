%gagh.m  遗传算法主程序
clc
%定义遗传算法参数
NIND=40;    %个体数目（Number of individuals）
MAXGEN=200;    %最大遗传代数(Maximum number. of generations)
NVAR=9;    %变量的维数
PRECI=20;    %变量的二进制位数(Precision of variables)
GGAP=0.9;    %代沟（Generation gap）
trace=zeros(MAXGEN,2);    %寻优结果的初始值
 
%建立区域描述器(Build field descriptor)
vlb=0.5*[110 66 222 118 72 76 30 40 40];
vub=[69 44 155 79 50 42 17 25 22];
ub=[vlb;vub];
FieldD=[REP([PRECI],[1,NVAR]);ub;REP([1;0;1;1],[1,NVAR])];
 
Chrom=CRTBP(NIND,NVAR*PRECI);    %创建初始种群（2进制）
P=BS2RV(Chrom,FieldD);    %初始种群的10进制化
gen=0;                      %代计数器
ObjV=objfunction(P);%计算初始种群个体的目标函数值
while gen<MAXGEN
    
    f=RANKING(-ObjV);    %分配适应度值（Assign fitness values
    FitnV=fit(f,P);
    
    SelCh=SELECT('SUS',Chrom,FitnV,GGAP);    %选择
    SelCh=RECOMBIN('XOVSP',SelCh,0.7);    %重组
    SelCh=MUT(SelCh);    %变异  
    P=BS2RV(SelCh,FieldD);
    ObjVSel=objfunction(P);
    [Chrom ObjV]=REINS(Chrom,SelCh,1,1,ObjV,ObjVSel);    %重插入子代的新种群
    P=BS2RV(Chrom,FieldD);
    gen=gen+1;    %代计数器增加
    trace(gen,1)=max(ObjV);    %遗传算法性能跟踪
    trace(gen,2)=sum(ObjV)/length(ObjV);
end
for i=1:NIND
    if ObjV(i)==max(ObjV)
        value=P(i,:);
        break
    end
end
objvalue=max(ObjV);
plot(trace(:,1));hold on;
plot(trace(:,2),'-.');grid;
legend('解的变化','种群均值的变化')

function z=fit(x,y)
%适应度函数
%x--40组按目标值的大小预分配的适应度
%y--40组自变量向量（y1,y2...y9）
for i=1:40
    if abs(sum(y(i,:))-500)>5
        x(i)=0.001*x(i);
    end
end
z=x;

function y=objfunction(a)
%遗传算法目标函数程序
%各科目各课程的均价
jsj=[25.8 25.5 28.0 26.0 24.7 25.6 27.0 22.9 25.9 24.5];
jg=[26.4 27.3 24.9 27.5 23.5 23.5 25.7 32.9 31.5 35.3];
sx=[21.0 20.2 24.8 19.6 18.6 23.3 13.1 18.4 22.5 25.7];
yy=[34.4 18.7 33.0 20.6 27.9 21.4 11.4 31.3 23.5 32.3];
lk=[14.7 18.8 26.6 16.7 13.4 14.8 17.5 24.2];
jn=[22.5 32.3 20.8 21.6 23.0 35.4];
hg=[20.0 23.6 25.6 28.0 18.9 26.7];
dl=[21.5 32.4 24.0 23.8 18.2 22.7];
hj=[37.5 22.2 20.7 22.7 24.3 32.2];
%各课程的书号个数百分比
w1=[0.159090909 0.161931818 0.039772727 0.048295455 0.048295455 0.153409091 0.122159091 0.048295455 0.147727273 0.071022727];
w2=[0.135678392 0.08040201 0.090452261 0.070351759 0.090452261 0.090452261 0.095477387 0.16080402 0.095477387 0.090452261];
w3=[0.044354839 0.173387097 0.239247312 0.036290323 0.120967742 0.143817204 0.059139785 0.024193548 0.102150538 0.056451613];
w4=[0.355971897 0.044496487 0.016393443 0.18969555 0.06088993 0.121779859 0.049180328 0.044496487 0.072599532 0.044496487];
w5=[0.065789474 0.149122807 0.105263158 0.157894737 0.074561404 0.140350877 0.157894737 0.149122807];
w6=[0.296482412 0.060301508 0.110552764 0.27638191 0.100502513 0.155778894];
w7=[0.076190476 0.152380952 0.2 0.123809524 0.123809524 0.323809524];
w8=[0.175 0.183333333 0.191666667 0.216666667 0.116666667 0.116666667];
w9=[0.174603175 0.238095238 0.222222222 0.214285714 0.087301587 0.063492063];
 
c1=[249.4166666 363.8375 118.3333333 238.4375 162.4166667 276.5818181 503.5486111 83.08333333 387.975 414.9375];
c2=[1425.5 1875.75 386.6666666 1106.208333 286.4166667 544.9166667 812.9375 575.2916666 2589.9375 1356.0625];
c3=[746.5416667 847.3785714 8609.903374 1297.5 1462.357843 2617.573864 628.4214286 498.8125 465.6760417 2863.553572];
c4=[747.8024039 525.45 907.9166667 268.5805555 447.8583334 274.1125 59.91666667 632.3875 347.4464286 301.8333333];
c5=[5297.5625 7532.660714 8622.2 4606.104167 16071.85416 7891.25 4104.633929 1241.875];
c6=[681.3461539 266.875 480.25 816.175 1204.683334 1000.75];
c7=[1038.75 863.95 406.975 162.9166667 782.0833333 427.4583333];
c8=[226.6666667 644.875 600.125 810.5 295.1666667 1543.666666];
c9=[593.1875 476.7916667 629.1666666 414.25 718.625 1460.75];
 
for k=1:length(a)
    s(1)=sum(a(k,1).*jsj.*w1.*c1);
    s(2)=sum(a(k,2).*jg.*w2.*c2);
    s(3)=sum(a(k,3).*sx.*w3.*c3);
    s(4)=sum(a(k,4).*yy.*w4.*c4);
    s(5)=sum(a(k,5).*lk.*w5.*c5);
    s(6)=sum(a(k,6).*jn.*w6.*c6);
    s(7)=sum(a(k,7).*hg.*w7.*c7);
    s(8)=sum(a(k,8).*dl.*w8.*c8);
    s(9)=sum(a(k,9).*hj.*w9.*c9);
    zc(k)=sum(s);
end
y=zc';