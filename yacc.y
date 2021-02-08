%{
#include<stdio.h>
int yylex();
void yyerror(char *s);
%}
%token FN MAIN BREAK CONTINUE FOR IN WHILE LET MUT TRUE FALSE PRINTLN ST OB CB OP CP OS CS IDENTIFIER NUMBER STRING AOPERATOR ASSIGN RELATIONAL COM
%%
Prog	: FN MAIN OP CP OB Statement CB
        {printf("Valid\n"); YYACCEPT;} 
	;
Statement   : Decl | Assignment | ST | %empty
        ; 
Decl    : LET MUT x ST Statement
        ;
x       : IDENTIFIER | IDENTIFIER ASSIGN NUMBER | IDENTIFIER ASSIGN STRING 
        | IDENTIFIER ASSIGN IDENTIFIER | IDENTIFIER ASSIGN Expr
        ;
Assignment  : IDENTIFIER ASSIGN y ST Statement
        ;
y       : NUMBER | STRING | IDENTIFIER | Expr
        ;
Expr    : ArithExpr | RelExpr
        ;
ArithExpr    : z  | z AOPERATOR ArithExpr | OP ArithExpr CP 
                | ArithExpr AOPERATOR ArithExpr
        ;
RelExpr : a | a RELATIONAL RelExpr | OP RelExpr CP | RelExpr RELATIONAL RelExpr
        ;
a       : NUMBER | STRING | IDENTIFIER | ArithExpr
        ;
z       : IDENTIFIER | NUMBER
        ;
%%
void yyerror(char *s)
{
printf("%s\n",s);
}
int main()
{
// #ifdef YYDEBUG
// yydebug = 1;
// #endif
yyparse();
return 0;
}