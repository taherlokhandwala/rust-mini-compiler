# cd-project-rust

# Notes:
# If running on windows PLEASE convert files using dos2unix, and then push
# If you run into an error where '-ly' isn't found, install libbison-dev

## Steps
1. Make sure you have lex (flex) and yacc (bison) installed.
2. Run ```lex lex.l```
3. Run ```yacc -d yacc.y -v```
4. Run ```gcc -w -g y.tab.c -ll -ly```
5. Run ```./a.out```
