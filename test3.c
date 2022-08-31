
int main()
{
    int a=0;
    int b=0;
    printf("%d %d\n",a,b);
    printf("%d %d\n",1,b);
    printf("%d %d\n",a,1);
    printf("%d %d\n",1,1);
    b=2;
    a=1;
    printf("test\n");
    if(a+b>=3)
        a = 1+b*3+4/2+4%3*(a+a);

    printf("1+2*3+4/2+4%3*(1+1) = %d\n",a);

}
