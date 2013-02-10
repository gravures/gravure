#include"stdio.h"
#define N 5         /*the number of x and y*/
float vx[N],vy[N],h[N-1],u[N-2],v[N-2],d[N-2],a[N-2][N-1]={{0},{0}},S[N-1][4],M[N];
jiefangcheng()
{
    float temp=0;
    int i,j,k,N1=N-2;
    for(i=0;i<N1;i++)
    {
        for(j=i;j<N1;j++)
        {   
            temp=0;
            for(k=0;k<i;k++)
            temp+=a[j][k]*a[k][i];
            a[j][i]=a[j][i]-temp;
        }
        
        for(j=i+1;j<N1+1;j++)
        {
            temp=0;
            for(k=0;k<i;k++)
            temp+=a[i][k]*a[k][j];
            a[i][j]=(a[i][j]-temp)/a[i][i];
        }
    }
    for(i=N1-2;i>0;i--)
    {
        temp=0;
        for(k=i+1;k<N1;k++)
        temp+=a[i][k]*a[k][N1];
        a[i][N1]=a[i][N1]-temp;
    }
    a[0][N1]=a[0][N1]-1;
    printf("\nthe anwser is: \nM0=0 ");    
    for(i=1;i<=N1;i++)
    printf("M%d=%f ",i,a[i-1][N1]);
    printf("M%d=0\n",N-1);
    getch();
}
biaodashi1()
{
	int i;
	S[N-1][4]={{1,9,25,28},{-1,3,19,26},{-2,3,19,26},{5,-60,208,-163}};
	for(i=0;i<=N-2;i++)
    printf("S%d=%fx^3+%fx^2+%fx^1+%f   %f<=x<=%f\n",i+1,S[i][0],S[i][1],S[i][2],S[i][3],vx[i],vx[i+1]);
}

biaodashi()
{

    int i,j;
    M[0]=0;
    M[N-1]=0;
    for(i=1;i<N-1;i++)
    M[i]=a[i-1][N-2];
    for(i=1;i<=N-1;i++)
    {
        S[i-1][0]=(M[i]-M[i-1])/6*h[i-1];
        S[i-1][1]=-(M[i]*vx[i-1]-M[i-1]*vx[i])/2*h[i-1];
        S[i-1][2]=(3*M[i]*vx[i-1]*vx[i-1]-3*M[i-1]*vx[i]*vx[i]+h[i-1]*h[i-1]*M[i-1]-6*vy[i-1]-h[i-1]*h[i-1]*M[i]+6*vy[i])/6*h[i-1];
        S[i-1][3]=-(M[i]*vx[i-1]*vx[i-1]*vx[i-1]-M[i-1]*vx[i]*vx[i]*vx[i]+6*vx[i]*vy[i-1]-h[i-1]*h[i-1]*M[i-1]*vx[i]-6*vy[i]*vx[i-1]+h[i-1]*h[i-1]*M[i]*vx[i-1])/6*h[i-1];
    }
    for(i=0;i<=N-2;i++)
    printf("S%d=%fx^3+%fx^2+%fx^1+%f\n",i+1,S[i][0],S[i][1],S[i][2],S[i][3]);
}

main()
{
    int i,j;
    printf("please input the value of x\n");
    for(i=0;i<N;i++)
    scanf("%f",&vx[i]);                             /*get value of x*/
    printf("please input the value of y\n");
    for(i=0;i<N;i++)
    scanf("%f",&vy[i]);
    printf("h is:\n");                              /*get value of y*/
    for(i=0;i<N-1;i++)
    {
        h[i]=vx[i+1]-vx[i];
        printf("h%d=%f ",i+1,h[i]);                  /*get value of h*/
    }
    printf("\nu and v are:\n");
    for(i=0;i<N-2;i++)
    {
        u[i]=h[i]/(h[i]+h[i+1]);
        v[i]=1-u[i];
        printf("u%d=%f v%d=%f ",i+1,u[i],i+1,v[i]);  /*get value of u and v*/
    }
    printf("\nd is:\n");
    for(i=0;i<N-2;i++)
    {
        d[i]=(6/(h[i]+h[i+1]))*((vy[i+2]-vy[i+1])/h[i+1]-(vy[i+1]-vy[i])/h[i]);
        printf("d%d=%f ",i+1,d[i]);                  /*get value of d*/
    }
    for(i=0;i<N-2;i++)
    a[i][i]=2;                                  /*set 2 into a*/
    for(i=1,j=0;i<N-2;i++,j++)
    {
        a[i][j]=u[i];
        a[j][i]=v[j];                            /*set u into a*/
    }
    for(i=0;i<N-2;i++)
    a[i][N-2]=d[i];                             /*set d into a*/
    for(i=0;i<N-2;i++)
    {
        printf("\n");
        for(j=0;j<N-1;j++)
        printf("%f  ",a[i][j]);
    }
                                /*非自然样条函数时需要用到
    a[0][N-3]=u[0];
    a[N-3][0]=v[N-3];
                                */
    jiefangcheng();                             /*jiefangcheng get value of M*/
    biaodashi1();                   /*get S biao da shi*/
}
