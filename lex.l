%option noyywrap
%{
    #include<stdio.h>
    #include"y.tab.h"
    #include<string.h>
    #include<stdlib.h>

    int yyerror(char *s);
    int line_no = 1;
    int scope = 0;
    int scope_ret(){
        return scope;
    }
%}
FN fn
MAIN main
BREAK break
CONTINUE continue
FOR for
IN in
WHILE while
LET let
MUT mut
TRUE true
FALSE false
PRINTLN println!
I32 i32
F32 f32
STR str
STMT_TERMINATOR ;
OPEN_BLOCK \{
CLOSE_BLOCK \}
OPEN_PARANTHESIS \(
CLOSE_PARANTHESIS \)
OPEN_SQUARE \[
CLOSE_SQUARE \]
COMMA ,
COLON :
IDENTIFIER [a-zA-Z][a-zA-Z0-9_]*|_[a-zA-Z0-9_]+
DIGIT	[0-9]
DIGITS	{DIGIT}+
OP_FRACTION	(\.{DIGITS})?
NUMBER	{DIGITS}{OP_FRACTION}
STRING \".*\"
PLUS \+
MINUS \-
MUL \*
DIVIDE \/
LOGICAL_OPERATOR (\|\||&&)
ASSIGN \=
EQUALS \=\=
NOT_EQUALS \!\=
GREATER_THAN >
LESS_THAN <
GREATER_OR_EQUAL >\=
LESS_OR_EQUAL <\=
%%
\n {;}
{STMT_TERMINATOR} { return ST;}
{FN} {return FN;}
{MAIN} {return MAIN;}
{OPEN_BLOCK} {scope++;return OB;}
{CLOSE_BLOCK} {scope--;return CB;}
{OPEN_PARANTHESIS} {return OP;}
{CLOSE_PARANTHESIS} {return CP;}
{OPEN_SQUARE} {char *s = "Array Pointer"; yylval.str = strdup(s); return OS;}
{CLOSE_SQUARE} {return CS;}
{COMMA} {return COM;}
{COLON} {return COLON;}
{ASSIGN} {return ASSIGN;}
{EQUALS} {return EQUALS;}
{NOT_EQUALS} {return NOT_EQUALS;}
{GREATER_THAN} {return GREATER_THAN;}
{LESS_THAN} {return LESS_THAN;}
{GREATER_OR_EQUAL} {return GREATER_OR_EQUAL;}
{LESS_OR_EQUAL} {return EQUALS;}
{LOGICAL_OPERATOR} {return LOGICAL;}
{PLUS} {return PLUS;}
{MINUS} {return MINUS;}
{MUL} {return MUL;}
{DIVIDE} {return DIVIDE;}
{BREAK} {return BREAK;}
{CONTINUE} {return CONTINUE;}
{FOR} {return FOR;} 
{IN} {return IN;}
{LET} {return LET;}
{MUT} {return MUT;}
{WHILE} {return WHILE;}
{PRINTLN} {return PRINTLN;}
{I32} {yylval.str = strdup(yytext);return I32;}
{F32} {yylval.str = strdup(yytext);return F32;}
{STR} {yylval.str = strdup(yytext);return STR;}
{IDENTIFIER} {yylval.str = strdup(yytext);return IDENTIFIER;}
{NUMBER} {yylval.lval = strtol(yytext,NULL,0);return NUMBER;}
{STRING} {yylval.str = strdup(yytext);return STRING;}
