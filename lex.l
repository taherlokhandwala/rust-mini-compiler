%option noyywrap
%{
#include <stdio.h>
#include "y.tab.h"
void yyerror(char *s);
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
STMT_TERMINATOR ;
OPEN_BLOCK \{
CLOSE_BLOCK \}
OPEN_PARANTHESIS \(
CLOSE_PARANTHESIS \)
OPEN_SQUARE \[
CLOSE_SQUARE \]
COMMA ,
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
{OPEN_BLOCK} {return OB;}
{CLOSE_BLOCK} {return CB;}
{OPEN_PARANTHESIS} {return OP;}
{CLOSE_PARANTHESIS} {return CP;}
{OPEN_SQUARE} {return OS;}
{CLOSE_SQUARE} {return CS;}
{COMMA} {return COM;}
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
{IDENTIFIER} {return IDENTIFIER;}
{NUMBER} {return NUMBER;}
{STRING} {return STRING;}
