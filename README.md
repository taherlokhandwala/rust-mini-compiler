# cd-project-rust
## Steps
1. Make sure you have lex or flex and yacc or bison installed.
2. Run ```lex lex.l```
3. Run ```yacc -d yacc.y```
4. Run ```gcc y.tab.c lex.yy.c -ll -ly```
5. Run ```./a.out```
