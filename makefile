all:tmp
	javac -cp ./antlr-3.5.2-complete.jar:. *.java
tmp:myCompiler.g
	java -cp ./antlr-3.5.2-complete.jar org.antlr.Tool myCompiler.g 
clean:
	rm *.class myCompilerParser.java myCompilerLexer.java *.tokens 