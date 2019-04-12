function  a= test1()
% sn = [
%     -2.99181919401019853726E3
%      7.08840045257738576863E5
%     -6.29741486205862506537E7
%      2.54890880573376359104E9
%     -4.42979518059697779103E10
%      3.18016297876567817986E11
% ];

sn = [
    1
    2
    3
    4
    5
    6
];
% a = p1evl(0.1,sn,6);

a = polevl(0.1,sn,6);
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