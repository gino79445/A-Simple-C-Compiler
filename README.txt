用的是(antlr-3.5.2-complete.jar)
可使用makefile來編譯檔案，輸入make後，會自動編譯
(java -cp ./antlr-3.5.2-complete.jar org.antlr.Tool myCompiler.g
javac -cp ./antlr-3.5.2-complete.jar:. *.java)
產生myCompilerParser.java......

因為有三個測試程式test1.c、test2.c、test3.c，
因此假設若要產生 test1.c 的 LLVM IR code，請輸入java -cp ./antlr-3.5.2-complete.jar:. myCompiler_test test1.c >> test1.ll，以此類推。
(前提是antlr-3.5.2-complete.jar在此資料夾)

test1.ll、test2.ll、test3.ll為透過 myCompiler 產生之 LLVM IR code


test1.c =>測試對於variable的scope判斷是否正確
test2.c =>測試if-then-else多巢狀使用及條件判斷
test3.c =>測試運算是否有先乘除後加減與printf的功能

subset_description 描述此 subset of C language。

輸入make clean 可清除make產生的文件



以下為提供功能:

(1) 使用int main 或 void main開頭都行
(2) 宣告同時也能賦值以及宣告多個
    Ex: int a;  int b = 3;  int a,b;
(3) if-then-else 可使用多個接在一起
(4) if-then、if-then-else可巢狀使用
(5) if-then、if-then-else若要做內只有一行，不必加{}
    Ex: if(a>1) printf("a>1");
(6)運算子左右兩邊可為常數或變數
	Ex: 	b = a +1, a !=1 , 2+b>=a , 2+2….. 
(7) printf 函數(可含一個、兩個或三個參數) 
    Ex: printf("%d %d" ,a,b);  printf("%d " ,3);  printf("ccc");
	且字串後參數可為常數或變數
(8)支持複雜運算及先乘除後加減
	Ex : 1+b*3+4/2+4%3*(a+a)
(9) 要return 不 return 都行
(10) 支援註解
(11) Ex:	; 或 a+1; ……等，也能為一個statement
(12) 在if-then中，有辦法使local variable 有自己的scope，且若此scope沒有會找外面scope的。

Ex :
int a =0;
if(1>0){
	int a =1;
	if(1>0){ printf(“%d”,a); }
}
printf(“%d”,a);
會印出: 10





