; === prologue ====
@str3= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str2= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str1= private unnamed_addr constant [4 x i8] c"%d\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 0, i32* %t0, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
store i32 0, i32* %t1, align 4
%t3 = icmp sgt i32 1, 0
br i1  %t3, label %L1, label %L2
L1:
%t4 = icmp sgt i32 1, 0
br i1  %t4, label %L4, label %L5
L4:
%t5 = alloca i32, align 4
store i32 2, i32* %t5, align 4
%t6 = icmp sgt i32 1, 0
br i1  %t6, label %L7, label %L8
L7:
%t7=load i32, i32* %t5, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str1, i64 0, i64 0),i32 %t7)
store i32 1, i32* %t5, align 4
br label %L9
L8:
br label %L9
L9:
%t8=load i32, i32* %t5, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str2, i64 0, i64 0),i32 %t8)
store i32 3, i32* %t5, align 4
br label %L6
L5:
br label %L6
L6:
%t9=load i32, i32* %t0, align 4
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str3, i64 0, i64 0),i32 %t9)
br label %L3
L2:
br label %L3
L3:

; === epilogue ===
ret i32 0
}
