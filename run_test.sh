if [[ $# -eq 0 ]] ; then
    echo 'put your test file in "test_files", and then pass full filename as arg'
    exit 0
fi

lex lex.l
yacc -d yacc.y -v
gcc -w -g y.tab.c -ll -ly
./a.out < test_files/$1