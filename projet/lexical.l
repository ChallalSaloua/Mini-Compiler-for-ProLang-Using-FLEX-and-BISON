%{
#define _POSIX_C_SOURCE 200809L
#include "syntaxique.tab.h"
#include "SymbolTable.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <io.h>      
int fileno(FILE *);
char *strdup(const char *s);
int yycol = 1;


#define YY_USER_ACTION                     \
    yylloc.first_line   = yylineno;        \
    yylloc.first_column = yycol;           \
    yycol += yyleng;

/* Vérifie les règles sur les identificateurs :
   - commencent par une lettre (maj ou min)
   - longueur <= 14
   - ne se terminent pas par '_'
   - ne contiennent pas "__" consécutifs
*/
static int valider_idf(const char *s) {
    int len = strlen(s);
    if (len > 14) {
        fprintf(stderr,
          "[ERREUR LEXICALE] ligne %d, colonne %d : identificateur '%s' depasse 14 caracteres.\n",
          yylineno, yycol - yyleng, s);
        return 0;
    }
    if (s[len - 1] == '_') {
        fprintf(stderr,
          "[ERREUR LEXICALE] ligne %d, colonne %d : identificateur '%s' se termine par '_'.\n",
          yylineno, yycol - yyleng, s);
        return 0;
    }
    if (strstr(s, "__") != NULL) {
        fprintf(stderr,
          "[ERREUR LEXICALE] ligne %d, colonne %d : identificateur '%s' contient '__' consecutifs.\n",
          yylineno, yycol - yyleng, s);
        return 0;
    }
    return 1;
}
%}

%option noyywrap
%option yylineno

/* Etats pour commentaires */
%x COMMENT_ML
%x COMMENT_SL

BLANC      [ \t\r]+
IDF        [a-zA-Z][a-zA-Z0-9_]*
ENTIER     [0-9]+
FLOAT      [0-9]*\.[0-9]+
STRING     \"[^\"]*\"

%%



"//*"              { BEGIN(COMMENT_ML); }
<COMMENT_ML>"*//"  { BEGIN(INITIAL); }
<COMMENT_ML>\n     { yycol = 1; }
<COMMENT_ML>.      { /* ignorer */ }


"%%"               { BEGIN(COMMENT_SL); }
<COMMENT_SL>\n     { yycol = 1; BEGIN(INITIAL); }
<COMMENT_SL>.      { /* ignorer */ }


"BeginProject"     { return BEGINPROJECT; }
"Setup"            { return SETUP; }
"Run"              { return RUN; }
"EndProject"       { return ENDPROJECT; }


"define"           { return DEFINE; }
"const"            { return CONSTKW; }
"integer"          { return INTEGER_TYPE; }
"float"            { return FLOAT_TYPE; }


"if"               { return IF; }
"then"             { return THEN; }
"else"             { return ELSE; }
"endIf"            { return ENDIF; }

"loop"             { return LOOP; }
"while"            { return WHILE; }
"endloop"          { return ENDLOOP; }

"for"              { return FOR; }
"in"               { return INKW; }
"to"               { return TOKW; }
"endfor"           { return ENDFOR; }


"INPUT"            { return INPUTKW; }
"OUTPUT"           { return OUTPUTKW; }


"AND"              { return AND; }
"OR"               { return OR; }
"NON"              { return NOT; }

"="                { return EGAL; }
">="               { return GTE; }
"<="               { return LTE; }
"=="               { return EQ; }
"!="               { return NEQ; }
">"                { return GT; }
"<"                { return LT; }


"+"                { return PLUS; }
"-"                { return MOINS; }
"*"                { return MUL; }
"/"                { return DIV; }


"<--"              { return AFFECT; }


";"                { return PV; }
":"                { return DP; }
","                { return VIRG; }
"|"                { return PIPE; }
"("                { return PO; }
")"                { return PF; }
"["                { return CROO; }
"]"                { return CROF; }
"{"                { return ACCO; }
"}"                { return ACCF; }


{BLANC}            { /* on ignore */ }
\n                 { yycol = 1; }




"\("[-+]{ENTIER}")" {
    yylval.ival = atoi(yytext + 1);  /* saute '(' */
    return ENTIER;
}

"\("[-+]{FLOAT}")" {
    yylval.fval = atof(yytext + 1);
    return FLOTTANT;
}

{ENTIER} {
    yylval.ival = atoi(yytext);
    return ENTIER;
}

{FLOAT}  {
    yylval.fval = atof(yytext);
    return FLOTTANT;
}


{STRING} {
    yylval.sval = strdup(yytext);
    return STRING;
}


{IDF} {
    valider_idf(yytext);     /* affiche erreurs si non conforme */
    yylval.sval = strdup(yytext);
    return IDF;
}


. {
    fprintf(stderr,
      "[ERREUR LEXICALE] ligne %d, colonne %d : caractere inconnu '%s'\n",
      yylineno, yycol - yyleng, yytext);
}

%%
