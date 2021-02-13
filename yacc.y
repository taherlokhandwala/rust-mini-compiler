%{
    #include <stdlib.h>
	#include <stdio.h>
	#include "symboltable.h"

	entry_t** symbol_table;
    entry_t** constant_table;

	//double Evaluate (double lhs_value,int assign_type,double rhs_value);
	//int current_dtype;
	int yyerror(char *msg);
    int yylex();
%}

%union
{
	entry_t* entry;
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
%token <entry> IDENTIFIER 
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
Assignment  : IDENTIFIER ASSIGN w ST Statement //{yylval.entry = insert(symbol_table, $1, $3);}
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

#include "lex.yy.c"
#include <ctype.h>

/*
double Evaluate (double lhs_value,int assign_type,double rhs_value)
{
	switch(assign_type)
	{
		case '=': return rhs_value;
		case ADD_ASSIGN: return (lhs_value + rhs_value);
		case SUB_ASSIGN: return (lhs_value - rhs_value);
		case MUL_ASSIGN: return (lhs_value * rhs_value);
		case DIV_ASSIGN: return (lhs_value / rhs_value);
		case MOD_ASSIGN: return ((int)lhs_value % (int)rhs_value);
	}
}
*/

int main(int argc, char *argv[])
{
	symbol_table = create_table();
	constant_table = create_table();

	yyin = fopen(argv[1], "r");

	if(!yyparse()){
		printf("\nParsing complete\n");
	}
	else{
		printf("\nParsing failed\n");
	}

	printf("\n\tSymbol table");
	display(symbol_table);

	fclose(yyin);
	return 0;
}

int yyerror(char *msg){
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	return 0;
}