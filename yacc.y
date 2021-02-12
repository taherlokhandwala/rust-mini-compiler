%{
#include<stdio.h>
int yylex();
void yyerror(char *s);
%}

%token FN 
%token MAIN 
%token BREAK 
%token CONTINUE 
%token FOR 
%token IN 
%token WHILE 
%token LET 
%token MUT 
%token TRUE 
%token FALSE 
%token PRINTLN 
%token ST 
%token OB 
%token CB 
%token OP 
%token CP 
%token OS 
%token CS 
%token IDENTIFIER 
%token NUMBER 
%token STRING 
%token PLUS 
%token MINUS 
%token MUL 
%token DIVIDE 
%token ASSIGN 
%token LESS_THAN
%token LESS_OR_EQUAL
%token GREATER_THAN
%token GREATER_OR_EQUAL
%token EQUALS
%token NOT_EQUALS 
%token COM 
%token LOGICAL

%%
Prog	: FN MAIN OP CP OB Statement CB
        {printf("Valid\n"); YYACCEPT;} 
	;
Statement   : Decl | Assignment | ForLoop | WhileLoop | Break | Continue | Print| ST | %empty
        ; 
Decl    : LET MUT x ST Statement
        ;
x       : IDENTIFIER | IDENTIFIER ASSIGN w
        ;
w       : STRING | Array | Expr 
        ;
Array   : OS Args CS
        ;
Args    : w | Args COM w
        ;
Assignment  : IDENTIFIER ASSIGN w ST Statement
        ;
Expr:   AddExpr Relop AddExpr | AddExpr | Bool
        ;
Bool : TRUE | FALSE
        ;
Relop: LESS_THAN | LESS_OR_EQUAL | GREATER_THAN | GREATER_OR_EQUAL | EQUALS | NOT_EQUALS
        ;
AddExpr: AddExpr Addop Term | Term
        ;
Addop: PLUS | MINUS
        ;
Term: Term Mulop Factor | Factor
        ;
Mulop: MUL | DIVIDE
        ;
Factor: OP Expr CP | IDENTIFIER | NUMBER;
        ;
ForLoop : FOR IDENTIFIER IN IDENTIFIER OB Statement CB
        ;
WhileLoop : WHILE Expr OB Statement CB
        ;
Break   : BREAK ST Statement
        ;
Continue   : CONTINUE ST Statement
        ;
Print   : PRINTLN OP STRING c CP ST Statement
        ;
c       : COM ListVars | %empty   
        ;
ListVars  : IDENTIFIER | ListVars COM IDENTIFIER
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