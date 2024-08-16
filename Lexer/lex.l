%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int linenumber = 1;

// Function to print tokens
void tokn_print(char *token_type);
void yyerror(char *s);
%}

%x multiline_Comment

/* Regular Expressions */
ID          {letter}+{alphanum}*
letter      [a-zA-Z]
alphanum    {letter}|{digit}|[_]
digit       [0-9]

intLit      {nonzero}{digit}*|"0"
nonzero     [1-9]
floatLit    {intLit}{fraction}+[eE][+|-]?{digit}+
fraction    "."{digit}*{nonzero}|".""0"
eE          [eE]{sign}?[0-9]+
sign        [+|-]





/* Regular */
%%

"("             { tokn_print("LEFT_PARA"); }
")"             { tokn_print("RIGHT_PARA"); }
";"             { tokn_print("SEMICOLON"); }
","             { tokn_print("COMMA"); }
"{"             { tokn_print("LEFT_BRACE"); }
"}"             { tokn_print("RIGHT_BRACE"); }
"."             { tokn_print("DOT"); }
":"             { tokn_print("COLON"); }
"["             { tokn_print("LEFT_BRACKET"); }
"]"             { tokn_print("RIGHT_BRACKET"); }
"+"             { tokn_print("PLUS"); }
"=="            { tokn_print("EQUAL"); }
"-"             { tokn_print("MINUS"); }
"="             { tokn_print("ASSIGN"); }
"*"             { tokn_print("ASTERISK"); }
"<"             { tokn_print("LESS_THAN"); }
"/"             { tokn_print("DIV"); }
">"             { tokn_print("GREATER_THAN"); }
"or"            { tokn_print("OR"); }
"<="            { tokn_print("LESS_THAN_EQUAL"); }
"and"           { tokn_print("AND"); }
">="            { tokn_print("GREATER_THAN_EQUAL"); }
"not"           { tokn_print("NOT"); }
"<>"            { tokn_print("NOT_EQUAL"); }
"attribute"     { tokn_print("ATTRIBUTE"); }
"class"         { tokn_print("CLASS"); }
"constructor"   { tokn_print("CONSTRUCTOR"); }
"else"          { tokn_print("ELSE"); }
"float"         { tokn_print("FLOAT"); }
"function"      { tokn_print("FUNCTION"); }
"if"            { tokn_print("IF"); }
"integer"       { tokn_print("INTEGER_TYPE"); }
"isa"           { tokn_print("ISA"); }
"localvar"      { tokn_print("LOCALVAR"); }
"private"       { tokn_print("PRIVATE"); }
"public"        { tokn_print("PUBLIC"); }
"read"          { tokn_print("READ"); }
"return"        { tokn_print("RETURN"); }
"self"          { tokn_print("SELF"); }
"then"          { tokn_print("THEN"); }
"void"          { tokn_print("VOID"); }
"while"         { tokn_print("WHILE"); }
"write"         { tokn_print("WRITE"); }


{ID} { tokn_print("ID"); }
{intLit}                 { tokn_print("INTLIT"); }
{floatLit}               { tokn_print("FLOATLIT"); }

"//".*     { /* Ignore Comment */ } 

"/*"       { /* multiline Comment Start */ BEGIN(multiline_Comment); }

<multiline_Comment>"*/"  { BEGIN(INITIAL); }
<multiline_Comment>[^*\n]+
<multiline_Comment>"*"+[^*/\n]*
<multiline_Comment>"\n" { linenumber += 1; }\

"\n"                    { linenumber += 1; }
[ \t\r\f]+              /* eat up whitespace */

%%

// Function to print tokens
void tokn_print(char *token_type) {
    printf("yytext: %s\ttoken: %s\tlineno: %d\n", yytext, token_type, linenumber);
}

void yyerror(char *message) {
    printf("Error: \"%s\" in line %d. Token = %s\n", message, linenumber, yytext);
    exit(1);
}

int main() {
    while (1) {
        printf("> ");
        char input[256];
        if (fgets(input, sizeof(input), stdin) == NULL || strncmp(input, "exit", 4) == 0) {
            break;
        }

        yy_scan_string(input);
        yylex();
    }

    return 0;
}
