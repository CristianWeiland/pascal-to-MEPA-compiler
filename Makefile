$DEPURA=1

compilador: lex.yy.c y.tab.c compilador.o compilador.h utils.o utils.h
	gcc lex.yy.c compilador.tab.c compilador.o utils.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

y.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

utils.o : utils.h utils.c
	gcc -c utils.c -o utils.o

clean :
	rm -f compilador.tab.* lex.yy.c *.o compilador
