all:
	bison -d portugol.y
	flex portugol.l
	g++ -o portugol lex.yy.c portugol.tab.c
	
clean:
	rm -f portugol lex.yy.c *.tab.*
