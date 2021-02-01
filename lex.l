%option noyywrap
%{
#include <stdio.h>
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
OP_EXPONENT	([Ee][+-]?{DIGITS})?
NUMBER	{DIGITS}{OP_FRACTION}{OP_EXPONENT}
STRING \".*\"
ARITH_OPERATOR [+\-\/\*\%]
ASSIGN \=
RELATIONAL (\=\=|\!\=|>|<|>\=|<\=)
%%
\n {;}
{STMT_TERMINATOR} {;}
{FN} {printf("fn\n");};
{MAIN} {printf("main\n");};
{OPEN_BLOCK} {printf("Block open\n");}
{CLOSE_BLOCK} {printf("Block closed\n");}
{OPEN_PARANTHESIS} {printf("Parenthesis open\n");}
{CLOSE_PARANTHESIS} {printf("Parenthesis closed\n");}
{OPEN_SQUARE} {printf("Square brackets open\n");}
{CLOSE_SQUARE} {printf("Square brackets closed\n");}
{COMMA} {printf(",");}
{ASSIGN} {printf("Assignment\n");}
{RELATIONAL} {printf("Relational Operator\n");}
{ARITH_OPERATOR} {printf("Arithmetic Operator\n");}
{BREAK} {printf("Break\n");}
{CONTINUE} {printf("Continue\n");}
{FOR} {printf("For\n");}
{IN} {printf("In\n");}
{LET} {printf("let\n");}
{MUT} {printf("mut\n");}
{WHILE} {printf("While\n");}
{PRINTLN} {printf("println!\n");}
{IDENTIFIER} {printf("Identifier\n");}
{NUMBER} {printf("Number\n");}
{STRING} {printf("String\n");}
