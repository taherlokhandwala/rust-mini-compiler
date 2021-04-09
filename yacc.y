%{
        #include <stdlib.h>
	#include <stdio.h>
        #include <string.h>
	#include "symboltable.h"

	sym_table* table;
        
	int yyerror(char *msg);
        int yylex();

        int *value_storage(int val){
                int *v = calloc(1,sizeof(int));
                *v = val;
                return v;
        }
%}

%union{
        int ival;
        char *name;
        void *type;
}

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
%token I32
%token F32
%token STR
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
%token COLON
%token LOGICAL

%%
Prog	: FN MAIN OP CP OB Statement CB 
        {printf("\nValid"); YYACCEPT;} 
	;
Statement   : Decl | Assignment | ForLoop | WhileLoop | Break | Continue | Print| ST | /* empty */
        ; 
Decl    : LET MUT IDENTIFIER COLON Type ASSIGN w ST Statement {insert(table,$<name>3,$<type>7,$<name>5,"Identifier",scope_ret());}
        ;
Type    : I32 {$<name>$ = $<name>1;}
        | F32 {$<name>$ = $<name>1;}
        | STR {$<name>$ = $<name>1;}
        ;
w       : STRING {$<type>$ = $<name>1;}
        | Array //
        | Expr { $<type>$ = value_storage($<ival>1); }
        ;
Array   : OS Args CS
        ;
Args    : w | Args COM w
        ;
Assignment  : IDENTIFIER ASSIGN w ST Statement //{printf("%d\n",$3);}
        ;
Expr:   AddExpr Relop AddExpr 
        | AddExpr {$<ival>$ = $<ival>1;}
        | Bool
        ;
Bool : TRUE | FALSE
        ;
Relop: LESS_THAN | LESS_OR_EQUAL | GREATER_THAN | GREATER_OR_EQUAL | EQUALS | NOT_EQUALS
        ;
AddExpr: AddExpr PLUS Term {$<ival>$ = $<ival>1 + $<ival>3;} 
        | AddExpr MINUS Term {$<ival>$ = $<ival>1 - $<ival>3;} 
        | Term {$<ival>$ = $<ival>1;}
        ;
Term: Term MUL Factor | Term DIVIDE Factor | Factor {$<ival>$ = $<ival>1;}
        ;
Factor: OP Expr CP | IDENTIFIER | NUMBER {$<ival>$ = $<ival>1;}
        ;
ForLoop : FOR IDENTIFIER IN IDENTIFIER OB Statement CB Statement
        ;
WhileLoop : WHILE Expr OB Statement CB Statement
        ;
Break   : BREAK ST Statement
        ;
Continue   : CONTINUE ST Statement
        ;
Print   : PRINTLN OP STRING c CP ST Statement
        ;
c       : COM ListVars | /* empty */   
        ;
ListVars  : IDENTIFIER | ListVars COM IDENTIFIER
        ;
%%

#include "lex.yy.c"
#include <ctype.h>

int main(int argc, char *argv[])
{
	table = init_table();

	yyin = fopen(argv[1], "r");

	if(!yyparse()){
		printf("\nParsing complete\n");
	}
	else{
		printf("\nParsing failed\n");
	}

	printf("\n\tSymbol table");
	display(table);

	fclose(yyin);
	return 0;
}

int yyerror(char *msg){
	//printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	return 0;
}