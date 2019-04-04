funciton [x,y,t] = spiral(s, cDot, x, y, t)

    double a;

    a = 1.0 / sqrt( fabs( cDot ) );
    a *= sqrt( M_PI );
    
    fresnel( s / a, y, x );
    
    *x *= a;
    *y *= a;
    
    if ( cDot < 0.0 )
        *y *= -1.0;

    *t = s * s * cDot * 0.5;
ned

function [ssa,cca] = fresnel(xxa,ssa,cca)
    x = abs(xxa);
    x2 = x.^2;
    
    if x2 < 2.5625
        t = x2.^2;
        [ans1,~] = polevl(t,sn,5);
        [ans2,~] = p1evl(t,sd,6);
        [ans3,~] = polevl(t,cn,5);
        [ans4,~] = p1evl(t,cd,6);
        ss = x*x2*ans1/ans2;
        cc = x*ans3/ans4;
    elseif x > 36974.0
        cc = 0.5;
        ss = 0.5;
    else
        x2 = x^2;
        t = pi*x2;
        u = 1.0 / (t.^2);
        t = 1.0 / t;
        [ans5,~] = polevl(t,fn,9);
        [ans6,~] = p1evl(t,fd,10);
        [ans7,~] = polevl(t,gn,10);
        [ans8,~] = p1evl(t,gd,11);
        f = 1.0 - u * ans5 / ans6;
        g = t * ans7 / ans8;

        t = pi * 0.5 * x2;
        c = cos (t);
        s = sin (t);
        t = pi * x;
        cc = 0.5 + (f * s - g * c) / t;
        ss = 0.5 - (f * c + g * s) / t;
    end
    if xxa < 0.0
        cc = -cc;
        ss = -ss;
    end
    cca = cc;
    ssa = ss;
        
end

function [ans,coef] = polevl(x,coef,n)
    ans = coef;
    coef = coef + 1;
    i = n;
    coef = coef + 1;
    ans = ans * x + coef;
    while(i)
        coef = coef + 1;
        ans = ans * x + coef;
        i = i -1;
    end
    return ans;
end

function [ans,coef] = p1evl(x,coef,n)
    coef = coef + 1;
    ans = x + coef;
    i =  n -1;
    coef = coef + 1;
    ans = ans * x + coef
    while(i)
        coef = coef + 1;
        ans = ans * x + coef
        i = i-1;
    end
    return ans;
end