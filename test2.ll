; === prologue ====
@str8= private unnamed_addr constant [3 x i8] c"8\0A\00"
@str7= private unnamed_addr constant [3 x i8] c"7\0A\00"
@str6= private unnamed_addr constant [3 x i8] c"6\0A\00"
@str5= private unnamed_addr constant [3 x i8] c"5\0A\00"
@str4= private unnamed_addr constant [3 x i8] c"4\0A\00"
@str3= private unnamed_addr constant [3 x i8] c"3\0A\00"
@str2= private unnamed_addr constant [3 x i8] c"2\0A\00"
@str1= private unnamed_addr constant [3 x i8] c"1\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 1, i32* %t0, align 4
%t1 = icmp sge i32 1, 0
br i1  %t1, label %L1, label %L2
L1:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str1, i64 0, i64 0))
%t2 = icmp sgt i32 1, 0
br i1  %t2, label %L4, label %L5
L4:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str2, i64 0, i64 0))
%t3=load i32, i32* %t0, align 4
%t4 = icmp eq i32 1,%t3
br i1  %t4, label %L7, label %L8
L7:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str3, i64 0, i64 0))
%t5 = icmp sle i32 1, 0
br i1  %t5, label %L10, label %L11
L10:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str4, i64 0, i64 0))
br label %L12
L11:
%t6=load i32, i32* %t0, align 4
%t7 = icmp slt i32 0,%t6
br i1  %t7, label %L13, label %L14
L13:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str5, i64 0, i64 0))
%t8=load i32, i32* %t0, align 4
%t9 = icmp sge i32 %t8, 0
br i1  %t9, label %L16, label %L17
L16:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str6, i64 0, i64 0))
br label %L18
L17:
%t10 = icmp ne i32 1, 0
br i1  %t10, label %L19, label %L20
L19:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str7, i64 0, i64 0))
br label %L21
L20:
br label %L21
L21:
br label %L18
L18:
br label %L15
L14:
br label %L15
L15:
br label %L12
L12:
br label %L9
L8:
br label %L9
L9:
br label %L6
L5:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @str8, i64 0, i64 0))
br label %L6
L6:
br label %L3
L2:
br label %L3
L3:

; === epilogue ===
ret i32 0
}
