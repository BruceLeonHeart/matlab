#include<stdio.h>
double polevl( double x, double* coef, int n );
double p1evl( double x, double* coef, int n );
int main()
{
//     double sn[6] = {
// -2.99181919401019853726E3,
//  7.08840045257738576863E5,
// -6.29741486205862506537E7,
//  2.54890880573376359104E9,
// -4.42979518059697779103E10,
//  3.18016297876567817986E11,
// };

double sn[6] = {1.0 ,2.0,  3.0 ,4.0, 5.0 ,6.0};
double x= 0.1;
int n = 6;
double a =0.0;
// a = polevl(x,sn,n);
a = p1evl(x,sn,n);
printf("%f",a);
return 0;
}



double polevl( double x, double* coef, int n )
{
    double ans;
    double *p = coef;
    int i;

    ans = *p++;
    i   = n;

    do
    {
        ans = ans * x + *p++;
    }
    while (--i);

    return ans;
}

double p1evl( double x, double* coef, int n )
{
    double ans;
    double *p = coef;
    int i;

    ans = x + *p++;
    i   = n - 1;

    do
    {
        ans = ans * x + *p++;
    }
    while (--i);

    return ans;
}