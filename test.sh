lex lex.l
yacc -d yacc.y -v
gcc -w -g y.tab.c -ll -ly
./a.out < abc.rs