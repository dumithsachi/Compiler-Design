%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include"lex.yy.c"

void yyerror(const char *s);

extern FILE* yyin;
extern char* sourceCode;
extern int nestedCommentCount;
extern int lineCount;
extern int commentFlag;
extern int errorFlag;

void addToSymbolTable(char c);
void insertDataType(void);

%}



%token  LEFT_PARA RIGHT_PARA SEMICOLON COMMA LEFT_BRACE RIGHT_BRACE DOT COLON LEFT_BRACKET RIGHT_BRACKET PLUS
%token  EQUAL_EQUAL MINUS ASSIGN ASTERISK LESS_THAN SLASH GREATER_THAN OR LESS_THAN_EQUAL AND GREATER_THAN_EQUAL
%token  NOT NOT_EQUAL ATTRIBUTE CLASS CONSTRUCTOR ELSE FLOAT FUNCTION IF INTEGER_TYPE ISA LOCALVAR PRIVATE PUBLIC
%token  READ RETURN SELF THEN VOID WHILE WRITE ID INTLIT FLOATLIT  

%%

prog : classDecl { printf("syntax Valid\n"); } | funcDef { printf("syntax Valid\n"); };

classDecl : CLASS ID {addToSymbolTable('C');} classDeclTail '{' classDeclList '}';

classDeclTail : ISA ID {addToSymbolTable('C');} classDeclTailList ';' | /* epsilon */;

classDeclTailList : /* epsilon */ | ',' ID classDeclTailList;

classDeclList : /* epsilon */ | visibility memberDecl classDeclList;

visibility : PUBLIC {addToSymbolTable('K');}| PRIVATE {addToSymbolTable('K');};

memberDecl : memberFuncDecl | memberVarDecl;

memberFuncDecl : FUNCTION ID {addToSymbolTable('F');} ':' '(' fParams ')' ROW returnType ';'
               | CONSTRUCTOR {addToSymbolTable('K');} ':' '(' fParams ')' ';';

memberVarDecl : ATTRIBUTE ID {addToSymbolTable('V');} ':' type memberVarDeclTail ';';

memberVarDeclTail : /* epsilon */ | arraySize memberVarDeclTail;

funcDef : funcHead funcBody;

funcHead : FUNCTION ID '(' fParams ')' ROW returnType
         | FUNCTION ID SR CONSTRUCTOR '(' fParams ')';

funcBody : '{' funcBodyTail '}';

funcBodyTail : /* epsilon */ | localVarDeclOrStmt funcBodyTail;

localVarDeclOrStmt : localVarDecl | statement;

localVarDecl : LOCALVAR ID { addToSymbolTable('V'); }':' type localVarDeclTail ';';

localVarDeclTail : /* epsilon */ | arraySize localVarDeclTail | LOCALVAR ID { addToSymbolTable('V'); } ':' type '(' aParams ')';

statement : assignStat ';'
          | IF { addToSymbolTable('K'); }'(' relExpr ')' THEN { addToSymbolTable('K'); } statBlock ELSE { addToSymbolTable('K'); } statBlock ';'
          | WHILE { addToSymbolTable('K'); } '(' relExpr ')' statBlock ';'
          | READ { addToSymbolTable('K'); } '(' variable ')' ';'
          | WRITE { addToSymbolTable('K'); } '(' expr ')' ';'
          | RETURN { addToSymbolTable('K'); } '(' expr ')' ';'
          | functionCall ';';

assignStat : variable assignOp expr;

statBlock : '{' statBlockTail '}'
          | statement
          | /* epsilon */;

statBlockTail : /* epsilon */ | statement statBlockTail;

expr : arithExpr | relExpr;

relExpr : arithExpr relOp arithExpr;

arithExpr : term arithExprTail;

arithExprTail : addOp term arithExprTail | /* epsilon */;

sign : PLUS | MINUS;

term : factor termTail;

termTail : multOp factor termTail | /* epsilon */;

factor : variable | functionCall | INTLIT { addToSymbolTable('I'); } | FLOATLIT { addToSymbolTable('I'); }| '(' arithExpr ')' | NOT factor | sign factor;

variable : variableTail ID variableList;

variableTail : /* epsilon */ | idnest variableTail;

variableList : /* epsilon */ | indice variableList;

functionCall : variableTail ID '(' aParams ')';

idnest : ID variableList '.' | ID '(' aParams ')' '.';

indice : '{' arithExpr '}';

arraySize : '{' INTLIT '}' | '{' '}';

type : INTEGER_TYPE {insertDataType();} 
| FLOAT  {insertDataType();} | ID;

returnType : type | VOID;

fParams : ID ':' type localVarDeclTail fParamsTail | /* epsilon */;

fParamsTail : /* epsilon */ | ',' ID ':' type localVarDeclTail fParamsTail;

aParams : ',' expr;

assignOp : ASSIGN;

relOp : RT | QR | GT | NQ | LQ | GQ;

addOp : AND | MINUS | OR;

multOp : ASTERISK | SLASH | PLUS;

%%
void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}

int main(int argc, char** argv) {
    if (argc <= 1) {
        printf("Invalid, Expected Format: ./a.out <\"sourceCode\">\n");
    }

    yyin = fopen(argv[1], "r");
    sourceCode = (char*)malloc(strlen(argv[1]) * sizeof(char));
    sourceCode = argv[1];
    yyparse();

    if (nestedCommentCount != 0) {
        printf("%s : %d : Comment Does Not End\n", sourceCode, lineCount);
    }
    if (commentFlag == 1) {
        printf("%s : %d : Nested Comment\n", sourceCode, lineCount);
    }

   if (!errorFlag) {
        // Your code here
    }

    return 0;
}

