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

        void while_label()
        {
                lnum++;
                strcpy(temporary,"t");
                strcat(temporary,i_);
                printf("if !%s goto L%d\n",st1[--top],lnum);
                char t[20]="L";
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", lnum);
                strcat(t,cpy_temp);
                strcpy(cpy_temp,"!");
                quad_table("if",strcat(cpy_temp,st1[top--]),"NULL",t);
                quad_table("goto","NULL","NULL",t);
                //i_[0]++;
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

        void for_label(){
                lnum++;
                strcpy(temporary,"t");
                strcat(temporary,i_);
                printf("L%d:\n",lnum);
                printf("if !%s goto L%d\n",st1[top],++lnum);
                --lnum;
                char t[20]="L";
                char cpy_temp[50]; 
                sprintf(cpy_temp, "%d", ++lnum);
                strcat(t,cpy_temp);
                strcpy(cpy_temp,"!");
                quad_table("if",strcat(cpy_temp,st1[top]),"NULL",t);

                strcpy(t,"L"); 
                sprintf(cpy_temp, "%d", --lnum);
                strcat(t,cpy_temp);
                
                quad_table("goto","NULL","NULL",t);

        }

        void codegen_rel()
        {
                strcpy(temporary,"t");
                strcat(temporary,i_);
                printf("%s = %s %s %s\n",temporary,st1[top-1],st1[top],st1[top-2]);
                
                quad_table(st1[top],st1[top-1],st1[top-2],temporary);
                top-=2;
                strcpy(st1[top],temporary);
                i_[0]++;  //i_=2
        }

        void codegen_for(){
                strcpy(temporary,"t");
                strcat(temporary,i_);
                printf("%s = %s %s %s\n",temporary,"i","<",st1[top]);
                insert(table,"i",strtol(st1[top],NULL,0)-1,"Identifier",scope_ret()+1);
                quad_table("<","i",st1[top--],temporary);
                strcpy(st1[top],temporary);
                i_[0]++;
        }

        void codegen_assign()
        {
                printf("%s = %s\n",st1[top-1],st1[top-2]);
                quad_table("=",st1[top-2],"NULL",st1[top-1]);
                //insert(table,st1[top-1],st1[top-2],"temp","temp",scope_ret());
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
Prog	:       {printf("\n\n---------------Three address code---------------\n");}
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
Decl    :       LET MUT IDENTIFIER COLON Type ASSIGN w ST {insert(table,$<str>3,$<lval>7,"Identifier",scope_ret()); strcpy(st1[++top],$<str>3); strcpy(st1[++top],"=");
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
                                        strcpy(st1[++top],$<str>1); strcpy(st1[++top],"=");
                                        codegen_assign();
                                        }
        ;
Expr    :       AddExpr LESS_THAN AddExpr  { 
                                                $<lval>$ = ($<lval>1 < $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(st1[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(st1[++top],cpy_temp);
                                                strcpy(st1[++top],"<"); 
                                                codegen_rel(); 
                                           }
                | AddExpr LESS_OR_EQUAL AddExpr { 
                                                        $<lval>$ = ($<lval>1 <= $<lval>3);
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(st1[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(st1[++top],cpy_temp);
                                                        strcpy(st1[++top],"<="); 
                                                        codegen_rel(); 
                                                }
                | AddExpr GREATER_THAN AddExpr { 
                                                        $<lval>$ = ($<lval>1 > $<lval>3);
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(st1[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(st1[++top],cpy_temp);
                                                        strcpy(st1[++top],">"); 
                                                        codegen_rel(); 
                                                }
                | AddExpr GREATER_OR_EQUAL AddExpr { 
                                                        $<lval>$ = ($<lval>1 >= $<lval>3); 
                                                        char cpy_temp[50]; 
                                                        sprintf(cpy_temp, "%d", $<lval>3);
                                                        strcpy(st1[++top],cpy_temp);  
                                                        sprintf(cpy_temp, "%d", $<lval>1);
                                                        strcpy(st1[++top],cpy_temp);
                                                        strcpy(st1[++top],">="); 
                                                        codegen_rel();
                                                   }
                | AddExpr EQUALS AddExpr { 
                                                $<lval>$ = ($<lval>1 == $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(st1[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(st1[++top],cpy_temp);
                                                strcpy(st1[++top],"=="); 
                                                codegen_rel(); 
                                         }
                | AddExpr NOT_EQUALS AddExpr { 
                                                $<lval>$ = ($<lval>1 != $<lval>3);
                                                char cpy_temp[50]; 
                                                sprintf(cpy_temp, "%d", $<lval>3);
                                                strcpy(st1[++top],cpy_temp);  
                                                sprintf(cpy_temp, "%d", $<lval>1);
                                                strcpy(st1[++top],cpy_temp);
                                                strcpy(st1[++top],"!="); 
                                                codegen_rel(); 
                                             }
                | AddExpr {$<lval>$ = $<lval>1;}
                | TRUE { $<lval>$ = 1; }
                | FALSE { $<lval>$ = 0; }
        ;
AddExpr :       AddExpr PLUS Term {
                                $<lval>$ = $<lval>1 + $<lval>3; 
                                strcpy(st1[++top],st1[top-1]);
                                strcpy(st1[++top],"+");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(st1[++top],cpy_temp); 
                                codegen();
                                }
                | AddExpr MINUS Term {
                                $<lval>$ = $<lval>1 - $<lval>3; 
                                strcpy(st1[++top],st1[top-1]);
                                strcpy(st1[++top],"-");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(st1[++top],cpy_temp);
                                codegen();
                                } 
                | Term          {$<lval>$ = $<lval>1;}
        ;
        
Term    :       Term MUL Factor {
                                $<lval>$ = $<lval>1 * $<lval>3; 
                                strcpy(st1[++top],st1[top-1]);
                                strcpy(st1[++top],"*");
                                char cpy_temp[50]; 
                                sprintf(cpy_temp, "%d", $<lval>3);
                                strcpy(st1[++top],cpy_temp);
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
                        strcpy(st1[++top],cpy_temp);
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
                        strcpy(st1[++top],cpy_temp);
                        codegen_for();
                        for_label();
                        } OB Statement CB       {
                                                printf("goto L%d\n",lnum);
                                                printf("L%d:\n",++lnum);
                                                }
        ;
WhileLoop:      WHILE Expr {while_label();} OB Statement CB 
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