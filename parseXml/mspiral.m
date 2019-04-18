function [x,y,t] = mspiral(s, cDot, x, y, t)
    a = 1.0 / sqrt(abs(cDot ) );
    a = a * sqrt(pi);    
    [y,x] = fresnel( s / a, y, x );
    x = x * a;
    y = y * a;        
    if  cDot < 0.0 
        y =  -y;
    end
    t = s * s * cDot * 0.5;
end

function [ssa,cca] = fresnel(xxa,ssa,cca)

sn = [
    -2.99181919401019853726E3
     7.08840045257738576863E5
    -6.29741486205862506537E7
     2.54890880573376359104E9
    -4.42979518059697779103E10
     3.18016297876567817986E11
];
sd =[
     2.81376268889994315696E2
     4.55847810806532581675E4
     5.17343888770096400730E6
     4.19320245898111231129E8
     2.24411795645340920940E10
     6.07366389490084639049E11
];

cn =[
    -4.98843114573573548651E-8
     9.50428062829859605134E-6
    -6.45191435683965050962E-4
     1.88843319396703850064E-2
    -2.05525900955013891793E-1
     9.99999999999999998822E-1
 ];

cd = [
     3.99982968972495980367E-12
     9.15439215774657478799E-10
     1.25001862479598821474E-7
     1.22262789024179030997E-5
     8.68029542941784300606E-4
     4.12142090722199792936E-2
     1.00000000000000000118E0
];

fn = [
      4.21543555043677546506E-1
      1.43407919780758885261E-1
      1.15220955073585758835E-2
      3.45017939782574027900E-4
      4.63613749287867322088E-6
      3.05568983790257605827E-8
      1.02304514164907233465E-10
      1.72010743268161828879E-13
      1.34283276233062758925E-16
      3.76329711269987889006E-20
];
fd = [
      7.51586398353378947175E-1
      1.16888925859191382142E-1
      6.44051526508858611005E-3
      1.55934409164153020873E-4
      1.84627567348930545870E-6
      1.12699224763999035261E-8
      3.60140029589371370404E-11
      5.88754533621578410010E-14
      4.52001434074129701496E-17
      1.25443237090011264384E-20
];

gn = [
      5.04442073643383265887E-1
      1.97102833525523411709E-1
      1.87648584092575249293E-2
      6.84079380915393090172E-4
      1.15138826111884280931E-5
      9.82852443688422223854E-8
      4.45344415861750144738E-10
      1.08268041139020870318E-12
      1.37555460633261799868E-15
      8.36354435630677421531E-19
      1.86958710162783235106E-22
];
gd =[
      1.47495759925128324529E0
      3.37748989120019970451E-1
      2.53603741420338795122E-2
      8.14679107184306179049E-4
      1.27545075667729118702E-5
      1.04314589657571990585E-7
      4.60680728146520428211E-10
      1.10273215066240270757E-12
      1.38796531259578871258E-15
      8.39158816283118707363E-19
      1.86958710162783236342E-22
];

    x = abs(xxa);
    x2 = x^2;
    
    if x2 < 2.5625
        t = x2.^2;
        ss = x * x2 * polevl(t,sn,6) / p1evl(t,sd,6);
        cc = x * polevl(t,cn,6) / polevl(t,cd,7);
    elseif x > 36974.0
        cc = 0.5;
        ss = 0.5;
    else
        x2 = x^2;
        t = pi*x2;
        u = 1.0 / (t.^2);
        t = 1.0 / t;
        f = 1.0 - u * polevl(u,fn,10) / p1evl(u,fd,10);
        g = t * polevl(u,gn,11) / p1evl(u,gd,11);

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

function ans_1 = polevl(x,coef,n)
    
    ans_1 = coef(1);
    for i = 1:n-1
        ans_1 = ans_1 * x + coef(i+1);
    end

end

function ans_2 = p1evl(x,coef,n)
    ans_2 = x + coef(1);
     for i = 1:n-1
        ans_2 = ans_2 * x + coef(i+1);
     end
end