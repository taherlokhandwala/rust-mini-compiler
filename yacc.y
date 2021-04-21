%{
        #include <stdlib.h>
        #include <stdio.h>
        #include <string.h>

        #include "symboltable.h"

        sym_table* table;

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

        char temporary[10] = "t";
        char temp_var_number[10] = "1";
        char stack[1000][100];
        int top = 0, label_number = 0;
        int label[1000];
        int quad_table_size = 0;
        quad quad_table[100];

        void push(char *a)
        {
	        strcpy(stack[++top],a);
        }

        void insert_quad_table(char *op, char *arg1, char *arg2, char *res)
        {
                quad_table[quad_table_size].op = (char*)malloc(sizeof(char)*strlen(op));
                quad_table[quad_table_size].arg1 = (char*)malloc(sizeof(char)*strlen(arg1));
                quad_table[quad_table_size].arg2 = (char*)malloc(sizeof(char)*strlen(arg1));
                quad_table[quad_table_size].res = (char*)malloc(sizeof(char)*strlen(res));
                strcpy(quad_table[quad_table_size].op,op);
                strcpy(quad_table[quad_table_size].arg1,arg1);
                strcpy(quad_table[quad_table_size].arg2,arg2);
                strcpy(quad_table[quad_table_size].res,res);
                quad_table_size++;
        }

        void codegen_while()
        {
                label_number++;
                strcpy(temporary,"t");
                strcat(temporary,temp_var_number);
                printf("L%d:\n",label_number);
                printf("if !%s goto L%d\n",stack[top],++label_number);
                char t[20]="L";
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", label_number);
                strcat(t,cpy_temp);
                strcpy(cpy_temp,"!");
                insert_quad_table("if",strcat(cpy_temp,stack[top--]),"NULL",t);
                strcpy(t,"L"); 
                sprintf(cpy_temp, "%d", --label_number);
                strcat(t,cpy_temp);
                insert_quad_table("goto","NULL","NULL",t);
        }

        void codegen()
        {
                char value[100]={'\0'};
                
                strcpy(temporary,"t");
                strcat(temporary,temp_var_number);
                strcpy(value,stack[top]);
                
                printf("%s = %s %s %s\n",temporary,stack[top-2],stack[top-1],stack[top]);
                insert_quad_table(stack[top-1],stack[top-2],stack[top],temporary);
                
                top-=2;
                strcpy(stack[top],temporary);
                temp_var_number[0]++;

        }

        void codegen_for(){
                label_number++;
                strcpy(temporary,"t");
                strcat(temporary,temp_var_number);
                printf("L%d:\n",label_number);
                printf("if !%s goto L%d\n",stack[top],++label_number);
                --label_number;
                char t[20]="L";
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", ++label_number);
                strcat(t,cpy_temp);
                strcpy(cpy_temp,"!");
                insert_quad_table("if",strcat(cpy_temp,stack[top]),"NULL",t);

                strcpy(t,"L"); 
                sprintf(cpy_temp, "%d", --label_number);
                strcat(t,cpy_temp);
                
                insert_quad_table("goto","NULL","NULL",t);

        }

        void codegen_rel()
        {
                strcpy(temporary,"t");
                strcat(temporary,temp_var_number);
                printf("%s = %s %s %s\n",temporary,stack[top-1],stack[top],stack[top-2]);
                
                insert_quad_table(stack[top],stack[top-1],stack[top-2],temporary);
                top-=2;
                strcpy(stack[top],temporary);
                temp_var_number[0]++;
        }

        void codegen_for_iter(){
                strcpy(temporary,"t");
                strcat(temporary,temp_var_number);
                printf("%s = %s %s %s\n",temporary,"i","<",stack[top]);
                insert(table,"i",strtol(stack[top],NULL,0)-1,"Identifier",scope_ret()+1);
                insert_quad_table("<","i",stack[top--],temporary);
                strcpy(stack[top],temporary);
                temp_var_number[0]++;
        }

        void codegen_assign()
        {
                printf("%s = %s\n",stack[top-1],stack[top-2]);
                insert_quad_table("=",stack[top-2],"NULL",stack[top-1]);
                top-=2;  
        }
        int yyerror(char *msg);
        int yylex();
%}

%union{
        long lval;
        char *str;
}

%token FN 
%token MAIN 
%token BREAK 
%token CONTINUE 
%token FOR 
%token IN 
%token WHILE 
%token RANGE
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
Prog	:       {printf("\nTHREE ADDRESS CODE :\n\n");}
                FN MAIN OP CP OB Statement CB 
                { YYACCEPT;} 
        ;
Statement:      Decl Statement 
                | Assignment Statement 
                | ForLoop Statement 
                | WhileLoop Statement 
                | Break Statement 
                | Continue Statement 
                | Print Statement 
                | ST Statement 
                | /* empty */
        ; 
Decl    :       LET MUT IDENTIFIER COLON Type ASSIGN w ST {insert(table,$<str>3,$<lval>7,"Identifier",scope_ret()); strcpy(stack[++top],$<str>3); strcpy(stack[++top],"=");
                                        codegen_assign();}
        ;
Type    :       I32 {$<str>$ = $<str>1;}
                | F32 {$<str>$ = $<str>1;} //| STR {$<str>$ = $<str>1;}
        ;
w       :       STRING {$<lval>$ = $<str>1;}
                | Array //
                | Expr { $<lval>$ = $<lval>1; }
        ;
Array   :       OS Args CS
        ;
Args    :       w 
                | Args COM w
        ;
Assignment:     IDENTIFIER ASSIGN w ST  {
                                        update(table,$<str>1,$<lval>3,scope_ret());
                                        strcpy(stack[++top],$<str>1); strcpy(stack[++top],"=");
                                        codegen_assign();
                                        }
        ;
Expr    :       AddExpr LESS_THAN AddExpr  { 
                                                $<lval>$ = ($<lval>1 < $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(stack[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(stack[++top],cpy_temp);
                                                strcpy(stack[++top],"<"); 
                                                codegen_rel(); 
                                           }
                | AddExpr LESS_OR_EQUAL AddExpr { 
                                                        $<lval>$ = ($<lval>1 <= $<lval>3);
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(stack[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(stack[++top],cpy_temp);
                                                        strcpy(stack[++top],"<="); 
                                                        codegen_rel(); 
                                                }
                | AddExpr GREATER_THAN AddExpr { 
                                                        $<lval>$ = ($<lval>1 > $<lval>3);
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(stack[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(stack[++top],cpy_temp);
                                                        strcpy(stack[++top],">"); 
                                                        codegen_rel(); 
                                                }
                | AddExpr GREATER_OR_EQUAL AddExpr { 
                                                        $<lval>$ = ($<lval>1 >= $<lval>3); 
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(stack[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(stack[++top],cpy_temp);
                                                        strcpy(stack[++top],">="); 
                                                        codegen_rel();
                                                   }
                | AddExpr EQUALS AddExpr { 
                                                $<lval>$ = ($<lval>1 == $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(stack[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(stack[++top],cpy_temp);
                                                strcpy(stack[++top],"=="); 
                                                codegen_rel(); 
                                         }
                | AddExpr NOT_EQUALS AddExpr { 
                                                $<lval>$ = ($<lval>1 != $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(stack[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(stack[++top],cpy_temp);
                                                strcpy(stack[++top],"!="); 
                                                codegen_rel(); 
                                             }
                | AddExpr {$<lval>$ = $<lval>1;}
                | TRUE { $<lval>$ = 1; }
                | FALSE { $<lval>$ = 0; }
        ;
AddExpr :       AddExpr PLUS Term {
                                $<lval>$ = $<lval>1 + $<lval>3; 
                                strcpy(stack[++top],stack[top-1]);
                                strcpy(stack[++top],"+");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(stack[++top],cpy_temp); 
                                codegen();
                                }
                | AddExpr MINUS Term {
                                $<lval>$ = $<lval>1 - $<lval>3; 
                                strcpy(stack[++top],stack[top-1]);
                                strcpy(stack[++top],"-");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(stack[++top],cpy_temp);
                                codegen();
                                } 
                | Term          {$<lval>$ = $<lval>1;}
        ;
        
Term    :       Term MUL Factor {
                                $<lval>$ = $<lval>1 * $<lval>3; 
                                strcpy(stack[++top],stack[top-1]);
                                strcpy(stack[++top],"*");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(stack[++top],cpy_temp);
                                codegen();
                                } 
                | Term DIVIDE Factor    {
                                                if($<lval>3 == 0)
                                                {
                                                        printf("Divide by Zero Error\n");
                                                        return;
                                                }
                                                $<lval>$ = $<lval>1 / $<lval>3;
                                        } 
                | Factor {
                        $<lval>$ = $<lval>1;
                        char cpy_temp[50]; 
                        sprintf(cpy_temp, "%d", $<lval>1);
                        strcpy(stack[++top],cpy_temp);
                        }
        ;

Factor  :       OP Expr CP 
                | IDENTIFIER    {
                                long *value=calloc(1,sizeof(long));
                                if(fetch(table,$<str>1,value))
                                        $<lval>$= *value;
                                
                                } 
                | NUMBER {
                                $<lval>$ = $<lval>1;
                         }
        ;
ForLoop :       FOR IDENTIFIER IN RANGE OP NUMBER CP {
                        char cpy_temp[50]; 
                        sprintf(cpy_temp, "%d", $<lval>6);
                        strcpy(stack[++top],cpy_temp);
                        codegen_for_iter();
                        codegen_for();
                        } OB Statement CB       {
                                                printf("goto L%d\n",label_number);
                                                printf("L%d:\n",++label_number);
                                                }
        ;
WhileLoop:      WHILE Expr {codegen_while();} OB Statement CB {
                                                                printf("goto L%d\n",label_number);
                                                                printf("L%d:\n",++label_number);
                                                            }
        ;
Break   :       BREAK ST 
        ;
Continue:       CONTINUE ST 
        ;
Print   :       PRINTLN OP STRING c CP ST 
        ;
c       :       COM ListVars | /* empty */   
        ;
ListVars:       IDENTIFIER | ListVars COM IDENTIFIER
        ;
%%

#include "lex.yy.c"
#include <ctype.h>

int main(int argc, char *argv[])
{
	table = init_table();

	yyin = fopen(argv[1], "r");

	if(!yyparse()){
		printf("\n\nPARSING COMPLETE\n\n");
                printf("QUADRUPLES :\n\n");
                printf("Operator \t Argument 1 \t Argument 2 \t Result \n");
                int i;
                for(i=0;i<quad_table_size;i++)
                {
                        printf("%-8s \t %-8s \t %-8s \t %-6s      \n",quad_table[i].op,quad_table[i].arg1,quad_table[i].arg2,quad_table[i].res);
                }
                printf("\n\n");
                printf("SYMBOL TABLE");
	        display(table);
	}
	else{
		printf("\nPARSING FAILED\n");
	}

	fclose(yyin);
	return 0;
}

int yyerror(char *msg){
	//printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	return 0;
}