
figure(1);
subplot(2,3,1)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(0.0001,0.03);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');

subplot(2,3,2)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(0.1,0.03);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');

subplot(2,3,3)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(100,0.03);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');

subplot(2,3,4)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(0.0001,3);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');

subplot(2,3,5)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(0.1,3);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');

subplot(2,3,6)
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(100,3);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');


figure(2);
hold on;
axis([-2.8 2.8 -1 1.5]);
[x,y,X,F1,F2] = L2_Constrained(0.1,0.3);
plot(X,F1,'g-');
plot(X,F2,'r--');
plot(x,y,'bo');
legend('LS','L2-Constrained LS');
%%定义函数，根据正则化参数与带宽不同的情形展示：
function [x,y,X,F1,F2] = L2_Constrained(L,h)
    n=50;
    N=1000;
    x=linspace(-3,3,n)';
    X=linspace(-3,3,N)';
    pix=pi*x; y=sin(pix)./(pix)+0.1*x+0.2*randn(n,1);
    x2=x.^2; 
    X2=X.^2; 
    hh=2*h^2; 
    k=exp(-(repmat(x2,1,n)+repmat(x2',n,1)-2*x*x')/hh);
    K=exp(-(repmat(X2,1,n)+repmat(x2',N,1)-2*X*x')/hh);
    t1=k\y; 
    F1=K*t1; 
    t2=(k^2+L*eye(n))\(k*y); 
    F2=K*t2;
end