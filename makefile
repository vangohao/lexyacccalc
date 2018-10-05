calc : lex.yy.o y.tab.o
	g++ -o calc lex.yy.o y.tab.o
lex.yy.o : lex.yy.c y.tab.h
	g++ -c lex.yy.c
y.tab.o : y.tab.c y.tab.h
	g++ -c y.tab.c
lex.yy.c : calc.l
	flex -l calc.l
y.tab.c y.tab.h : calc.y
	bison -y -d calc.y
clean:
	rm calc lex.yy.o y.tab.o lex.yy.c y.tab.c y.tab.h