%{
        #include <stdlib.h>
	#include <stdio.h>
        #include <string.h>
        
        #include "lex.yy.c"

	sym_table* table;
        
	int yyerror(char *msg);
        int yylex();

        long *value_storage(long val){
                long *v = calloc(1,sizeof(long));
                *v = val;
                return v;
        }

        typedef struct quadruples{
                char *op;
                char *arg1;
                char *arg2;
                char *res;
        }quad;
        int quadlen = 0;
        quad q[100];
        char i_[10]="1";
        char temporary[10]="t";
        int index1=0,top=0,lnum=0,ltop=0;
        int label[1000];
        char st1[1000][100];

        void push(char *a)
        {
	        strcpy(st1[++top],a);
        }

        void quad_table(char *op, char *arg1, char *arg2, char *res)
        {
                q[quadlen].op = (char*)malloc(sizeof(char)*strlen(op));
                q[quadlen].arg1 = (char*)malloc(sizeof(char)*strlen(arg1));
                q[quadlen].arg2 = (char*)malloc(sizeof(char)*strlen(arg1));
                q[quadlen].res = (char*)malloc(sizeof(char)*strlen(res));
                strcpy(q[quadlen].op,op);
                strcpy(q[quadlen].arg1,arg1);
                strcpy(q[quadlen].arg2,arg2);
                strcpy(q[quadlen].res,res);
                quadlen++;
        }

        void codegen()
        {
                char value[100]={'\0'};
                
                strcpy(temporary,"t");
                strcat(temporary,i_);
                strcpy(value,st1[top]);
                
                printf("%s = %s %s %s\n",temporary,st1[top-2],st1[top-1],st1[top]);
                quad_table(st1[top-1],st1[top-2],st1[top],temporary);
                //insert(table,temporary,value,"temp","temp",scope_ret());
                
                top-=2;
                strcpy(st1[top],temporary);
                i_[0]++;  //i_=2

        }

        void codegen_assign()
        {
                printf("%s = %s\n",st1[top-1],st1[top-2]);
                quad_table("=",st1[top-2],"NULL",st1[top-1]);
                //insert(table,st1[top-1],st1[top-2],"temp","temp",scope_ret());
                top-=2;  
        }
%}

%union{
        long lval;
        char *str;
        void *void_type;
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
//here
Prog	:       {printf("\n\n---------------Three address code---------------\n");}
                FN MAIN OP CP OB Statement CB 
                { YYACCEPT;} 
	        ;

Statement   :   Decl | Assignment | ForLoop | WhileLoop | Break | Continue | Print| ST | /* empty */
                ;

Decl    :       LET MUT IDENTIFIER COLON Type ASSIGN w ST Statement {insert(table,$<name>3,$<type>7,$<name>5,
                "Identifier",scope_ret());}
                ;

Type    : I32 {$<name>$ = $<name>1;}
        | F32 {$<name>$ = $<name>1;}
        | STR {$<name>$ = $<name>1;}
        ;

w       : STRING {$<type>$ = $<name>1;}
Prog	: FN MAIN OP CP OB Statement CB 
        {printf("\nValid"); YYACCEPT;} 
	;
Statement   : Decl | Assignment | ForLoop | WhileLoop | Break | Continue | Print| ST | /* empty */
        ; 
Decl    : LET MUT IDENTIFIER COLON Type ASSIGN w ST Statement {insert(table,$<str>3,$<void_type>7,$<str>5,"Identifier",scope_ret());}
        ;
Type    : I32 {$<str>$ = $<str>1;}
        | F32 {$<str>$ = $<str>1;}
        | STR {$<str>$ = $<str>1;}
        ;
w       : STRING {$<void_type>$ = $<str>1;}
        | Array //
        | Expr { $<void_type>$ = value_storage($<lval>1); }
        ;

Array   : OS Args CS
        ;

Args    : w | Args COM w
        ;
// Here
Assignment  : IDENTIFIER ASSIGN w ST Statement 
        {strcpy(st1[++top],$<name>1); strcpy(st1[++top],"=");codegen_assign();}
        ;

Expr:   AddExpr Relop AddExpr 
        | AddExpr {$<ival>$ = $<ival>1;}
        | Bool
        ;

Bool : TRUE | FALSE
        ;

Relop: LESS_THAN | LESS_OR_EQUAL | GREATER_THAN | GREATER_OR_EQUAL | EQUALS | NOT_EQUALS
        ;

AddExpr: AddExpr PLUS Term 
        {
                $<ival>$ = $<ival>1 + $<ival>3; 
                strcpy(st1[++top],st1[top-1]);
                strcpy(st1[++top],"+");
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", $<ival>3);
                strcpy(st1[++top],cpy_temp); 
                codegen();
        } 
        | AddExpr MINUS Term 
        {
                $<ival>$ = $<ival>1 - $<ival>3; 
                strcpy(st1[++top],st1[top-1]);
                strcpy(st1[++top],"-");
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", $<ival>3);
                strcpy(st1[++top],cpy_temp);
                codegen();
        } 
        | Term {$<ival>$ = $<ival>1;}
        ;
        
Term:   Term MUL Factor 
        {
                $<ival>$ = $<ival>1 * $<ival>3; 
                strcpy(st1[++top],st1[top-1]);
                strcpy(st1[++top],"*");
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", $<ival>3);
                strcpy(st1[++top],cpy_temp);
                codegen();
        } 
        | Term DIVIDE Factor 
        {
                if($<ival>3 == 0)
                {
                        printf("Divide by Zero Error\n");
                        return;
                }
                $<ival>$ = $<ival>1 / $<ival>3;
        } 
        | Factor 
        {
                $<ival>$ = $<ival>1;
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", $<ival>1);
                strcpy(st1[++top],cpy_temp);
        }
        ;
        
Factor: OP Expr CP | IDENTIFIER | NUMBER {$<ival>$ = $<ival>1;}
Assignment  : IDENTIFIER ASSIGN w ST Statement {
                                                
                                                int check = update(table,$<str>1,$<void_type>3,scope_ret());
                                                }
        ;
Expr:     AddExpr LESS_THAN AddExpr  { $<lval>$ = ($<lval>1 < $<lval>3); }
        | AddExpr LESS_OR_EQUAL AddExpr { $<lval>$ = ($<lval>1 <= $<lval>3); }
        | AddExpr GREATER_THAN AddExpr { $<lval>$ = ($<lval>1 > $<lval>3); }
        | AddExpr GREATER_OR_EQUAL AddExpr { $<lval>$ = ($<lval>1 >= $<lval>3); }
        | AddExpr EQUALS AddExpr { $<lval>$ = ($<lval>1 == $<lval>3); }
        | AddExpr NOT_EQUALS AddExpr { $<lval>$ = ($<lval>1 != $<lval>3); }
        | AddExpr {$<lval>$ = $<lval>1;}
        | TRUE { $<lval>$ = 1; }
        | FALSE { $<lval>$ = 0; }
        ;
AddExpr: AddExpr PLUS Term {$<lval>$ = $<lval>1 + $<lval>3;} 
        | AddExpr MINUS Term {$<lval>$ = $<lval>1 - $<lval>3;} 
        | Term {$<lval>$ = $<lval>1;}
        ;
Term: Term MUL Factor | Term DIVIDE Factor | Factor {$<lval>$ = $<lval>1;}
        ;
Factor: OP Expr CP 
        | IDENTIFIER    {
                        char *value = calloc(100,sizeof(char));
                        char *data_type = calloc(4,sizeof(char));
                        fetch(table,$<str>1,data_type,value);

                        if(!strcmp(data_type,"i32"))
                                $<lval>$ = strtol(value,NULL,0);
                        if(!strcmp(data_type,"f32"))
                                $<lval>$ = strtol(value,NULL,0);
                        else if(!strcmp(data_type,"str"))
                                $<str>$ = value;
                        } 
        | NUMBER {$<lval>$ = $<lval>1;}
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

#include <ctype.h>

int main(int argc, char *argv[])
{
	table = init_table();

	yyin = fopen(argv[1], "r");

	if(!yyparse()){
		printf("\nParsing complete\n");
                printf("----------------------Quadruples----------------------\n\n");
                printf("Operator \t Arg1 \t\t Arg2 \t\t Result \n");
                int i;
                for(i=0;i<quadlen;i++)
                {
                        printf("%-8s \t %-8s \t %-8s \t %-6s      \n",q[i].op,q[i].arg1,q[i].arg2,q[i].res);
                }
                printf("\n\n");
                printf("\n\tSymbol table");
	        display(table);
	}
	else{
		printf("\nParsing failed\n");
	}

	fclose(yyin);
	return 0;
}

int yyerror(char *msg){
	//printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	return 0;
}