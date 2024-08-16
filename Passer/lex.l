%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "y.tab.h"

int linenumber = 1;

//get the error
void yyerror(const char* s);
%}


%x multiline_Comment


/*Regular Expressions*/
id          {letter}+{alphanum}*
letter      [a-zA-Z]
alphanum    {letter}|{digit}|[_]
digit       [0-9]

intLit      {nonzero}{digit}*|"0"
nonzero     [1-9]
floatLit    {intLit}{fraction}+[eE][+|-]?{digit}+
fraction    "."{digit}*{nonzero}|".""0"
eE          [eE]{sign}?[0-9]+
sign        [+|-]


/*Regular */
%%

"("             { return LEFT_PARA; }
")"             { return RIGHT_PARA; }

";"             { return SEMICOLON; }
","             { return COMMA; }

"{"             { return LEFT_BRACE; }
"}"             { return RIGHT_BRACE; }

"."             { return DOT; }
":"             { return COLON; }

"["             { return LEFT_BRACKET; }
"]"             { return RIGHT_BRACKET; }

"+"             { return PLUS; }
"=="            { return EQUAL_EQUAL; }
"-"             { return MINUS; }
"="             { return ASSIGN; }

"*"             { return ASTERISK; }

"<"             { return LESS_THAN; }
"/"             { return SLASH; }
">"             { return GREATER_THAN; }

"or"            { return OR; }
"<="            { return LESS_THAN_EQUAL; }
"and"           { return AND; }
">="            { return GREATER_THAN_EQUAL; }
"not"           { return NOT; }
"<>"            { return NOT_EQUAL; }
"attribute"     { return ATTRIBUTE; }
"class"         { return CLASS; }
"constructor"   { return CONSTRUCTOR; }
"else"          { return ELSE; }
"float"         { return FLOAT; }
"function"      { return FUNCTION; }
"if"            { return IF; }
"integer"       { return INTEGER_TYPE; }
"isa"           { return ISA; }
"localvar"      { return LOCALVAR; }
"private"       { return PRIVATE; }
"public"        { return PUBLIC; }
"read"          { return READ; }
"return"        { return RETURN; }
"self"          { return SELF; }
"then"          { return THEN; }
"void"          { return VOID; }
"while"         { return WHILE; }
"write"         { return WRITE; }

"rt"             {return RT;}
"sr"             {return SR;}
"eq"             {return EQ;}
"gt"             {return GT;}
"nq"           {return NQ;}
"lq"           {return LQ;}
"gq"           {return GQ;}
"row"         {return ROW;}

"//".*     { /* Ignore Comment */ } 

"/*"       { /* multiline Comment Start */ BEGIN(multiline_Comment); }

<multiline_Comment>"*/"  { BEGIN(INITIAL); }
<multiline_Comment>[^*\n]+
<multiline_Comment>"*"+[^*/\n]*
<multiline_Comment>"\n" { linenumber += 1; }\

"\n"                    { linenumber += 1; }
[ \t\r\f]+              /* eat up whitespace */


{id}     { return ID; }
{intLit}     { return INTLIT; }
{floatLit}     { return FLOATLIT; }


%%
//wrap up all and return function

int yywrap()
{
    return 1;
}