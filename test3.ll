; === prologue ====
@str6= private unnamed_addr constant [26 x i8] c"1+2*3+4/2+4%3*(1+1) = %d\0A\00"
@str5= private unnamed_addr constant [6 x i8] c"test\0A\00"
@str4= private unnamed_addr constant [7 x i8] c"%d %d\0A\00"
@str3= private unnamed_addr constant [7 x i8] c"%d %d\0A\00"
@str2= private unnamed_addr constant [7 x i8] c"%d %d\0A\00"
@str1= private unnamed_addr constant [7 x i8] c"%d %d\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 0, i32* %t0, align 4
%t1 = alloca i32, align 4
store i32 0, i32* %t1, align 4
%t2=load i32, i32* %t0, align 4
%t3=load i32, i32* %t1, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str1, i64 0, i64 0),i32 %t2,i32 %t3)
%t4=load i32, i32* %t1, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str2, i64 0, i64 0),i32 1,i32 %t4)
%t5=load i32, i32* %t0, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str3, i64 0, i64 0),i32 %t5,i32 1)
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str4, i64 0, i64 0),i32 1,i32 1)
store i32 2, i32* %t1, align 4
store i32 1, i32* %t0, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str5, i64 0, i64 0))
%t6=load i32, i32* %t0, align 4
%t7=load i32, i32* %t1, align 4
%t8 = add nsw i32 %t6, %t7
%t9 = icmp sge i32 %t8, 3
br i1  %t9, label %L1, label %L2
L1:
%t10=load i32, i32* %t1, align 4
%t11 = mul nsw i32 %t10, 3
%t12 = add nsw i32 1,%t11
%t13 = sdiv i32 4, 2
%t14 = add nsw i32 %t12, %t13
%t15 = srem i32 4, 3
%t16=load i32, i32* %t0, align 4
%t17=load i32, i32* %t0, align 4
%t18 = add nsw i32 %t16, %t17
%t19 = mul nsw i32 %t15, %t18
%t20 = add nsw i32 %t14, %t19
store i32 %t20, i32* %t0, align 4
br label %L3
L2:
br label %L3
L3:
%t21=load i32, i32* %t0, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @str6, i64 0, i64 0),i32 %t21)

; === epilogue ===
ret i32 0
}
