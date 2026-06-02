%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "SymbolTable.h"
#include "quad.h"

char *strdup(const char *s);
int yylex(void);
void yyerror(const char *s);

/* =========================
   Variables internes
   ========================= */

static char current_decl_id[64];
static int  current_decl_line = 0;

/* =========================
   Fonctions utilitaires
   ========================= */

static char* make_typed(const char* prefix, const char* val) {
    char* r = (char*)malloc(strlen(prefix) + strlen(val) + 1);
    sprintf(r, "%s%s", prefix, val);
    return r;
}

static const char* raw(const char* tv) {
    if (tv && strlen(tv) > 4 && tv[3] == ':') return tv + 4;
    return tv;
}

static int is_float_type(const char* tv) {
    return tv && strncmp(tv, "FLT:", 4) == 0;
}

static int is_str_type(const char* tv) {
    return tv && strncmp(tv, "STR:", 4) == 0;
}

static int is_tab_noidx(const char* tv) {
    return tv && strncmp(tv, "TAB:", 4) == 0;
}

static int is_integer_literal_text(const char* s) {
    int i = 0;

    if (!s || !*s) return 0;

    if (s[0] == '-' || s[0] == '+') i = 1;

    if (!s[i]) return 0;

    for (; s[i]; i++) {
        if (!isdigit((unsigned char)s[i])) return 0;
    }

    return 1;
}

static int get_int_const_value(const char* tv, int* out) {
    const char* r = raw(tv);

    if (!tv || !is_integer_literal_text(r)) return 0;

    if (out) *out = atoi(r);

    return 1;
}

static int verifier_double_declaration(const char* nom, int ligne) {
    if (chercherTS((char*)nom) != NULL) {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : double declaration de '%s'.\n",
          ligne, nom);
        return 1;
    }

    return 0;
}

static void inserer_var_secure(const char* nom, int type, int ligne) {
    if (!verifier_double_declaration(nom, ligne)) {
        insererVar((char*)nom, type, ligne);
    }
}

static void inserer_tab_secure(const char* nom, int type, int taille, int ligne) {
    if (!verifier_double_declaration(nom, ligne)) {
        insererTab((char*)nom, type, taille, ligne);
    }
}

static void inserer_const_secure(const char* nom, int type, const char* val, int ligne) {
    if (!verifier_double_declaration(nom, ligne)) {
        insererConst((char*)nom, type, (char*)val, ligne);
    }
}

static void inserer_liste_idf(const char* liste, int type, int ligne) {
    char* copie = strdup(liste);
    char* tok = strtok(copie, "|");

    while (tok) {
        inserer_var_secure(tok, type, ligne);
        tok = strtok(NULL, "|");
    }

    free(copie);
}

static char* construire_liste_avec_premier(const char* premier, const char* reste) {
    char* liste = (char*)malloc(strlen(premier) + strlen(reste) + 2);
    sprintf(liste, "%s|%s", premier, reste);
    return liste;
}

static void generer_affectation_liste(const char* liste, const char* val) {
    char* copie = strdup(liste);
    char* tok = strtok(copie, "|");

    while (tok) {
        quadr(qc, "=", val, "-", tok);
        tok = strtok(NULL, "|");
    }

    free(copie);
}
%}

%locations

%union {
    int    ival;
    float  fval;
    char*  sval;
}

/* =========================
   TOKENS
   ========================= */

%token <sval> IDF STRING
%token <ival> ENTIER
%token <fval> FLOTTANT

%token BEGINPROJECT SETUP RUN ENDPROJECT
%token DEFINE CONSTKW
%token IF THEN ELSE ENDIF
%token LOOP WHILE ENDLOOP
%token FOR INKW TOKW ENDFOR
%token INPUTKW OUTPUTKW
%token INTEGER_TYPE FLOAT_TYPE
%token PIPE

%token PLUS MOINS MUL DIV
%token AND OR NOT
%token GT LT GTE LTE EQ NEQ
%token AFFECT EGAL
%token PV DP VIRG
%token PO PF CROO CROF ACCO ACCF

/* =========================
   TYPES DES NON-TERMINAUX
   ========================= */

%type <ival> M suite_if
%type <sval> programme partie_declarations declaration declaration_suite liste_idf
%type <sval> partie_instructions instruction expr condition output_args

/* =========================
   PRIORITES
   ========================= */

%left OR
%left AND
%right NOT

%left GT LT GTE LTE EQ NEQ
%left PLUS MOINS
%left MUL DIV

%start programme

%%

/* =========================
   PROGRAMME
   ========================= */

programme
    : BEGINPROJECT IDF PV
      {
        initialisation();
        insererProg($2, @2.first_line);
        init_qdr();
      }
      SETUP DP
      partie_declarations
      RUN DP ACCO
      partie_instructions
      ACCF
      ENDPROJECT PV
      {
        afficher();
        afficher_qdr();
        optimiser_quadruplets();
        afficher_qdr_supprimes();
        afficher_qdr_apres_opti();
        generer_code_objet();
      }
    ;

/* =========================
   DECLARATIONS
   ========================= */

partie_declarations
    : /* vide */
      {
        $$ = NULL;
      }

    | partie_declarations declaration
      {
        $$ = $1;
      }
    ;

declaration
    : DEFINE IDF
      {
        strcpy(current_decl_id, $2);
        current_decl_line = @2.first_line;
      }
      declaration_suite
      {
        $$ = NULL;
      }

    | CONSTKW IDF DP FLOAT_TYPE EGAL FLOTTANT PV
      {
        char val[32];

        sprintf(val, "%f", $6);
        inserer_const_secure($2, T_FLOAT, val, @2.first_line);
        quadr(qc, "=", val, "-", $2);

        $$ = NULL;
      }

    | CONSTKW IDF DP INTEGER_TYPE EGAL ENTIER PV
      {
        char val[32];

        sprintf(val, "%d", $6);
        inserer_const_secure($2, T_INTEGER, val, @2.first_line);
        quadr(qc, "=", val, "-", $2);

        $$ = NULL;
      }

    | CONSTKW IDF DP INTEGER_TYPE EGAL FLOTTANT PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : constante '%s' de type INTEGER initialisee avec une valeur FLOAT.\n",
          @2.first_line, $2);

        char val[32];
        sprintf(val, "%d", (int)$6);

        inserer_const_secure($2, T_INTEGER, val, @2.first_line);

        $$ = NULL;
      }

    | CONSTKW IDF DP FLOAT_TYPE EGAL ENTIER PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : constante '%s' de type FLOAT initialisee avec une valeur INTEGER.\n",
          @2.first_line, $2);

        char val[32];
        sprintf(val, "%f", (float)$6);

        inserer_const_secure($2, T_FLOAT, val, @2.first_line);
        quadr(qc, "=", val, "-", $2);

        $$ = NULL;
      }
    ;

declaration_suite
    : DP INTEGER_TYPE PV
      {
        inserer_var_secure(current_decl_id, T_INTEGER, current_decl_line);
        $$ = NULL;
      }

    | DP FLOAT_TYPE PV
      {
        inserer_var_secure(current_decl_id, T_FLOAT, current_decl_line);
        $$ = NULL;
      }

    | DP INTEGER_TYPE EGAL ENTIER PV
      {
        char val[32];

        sprintf(val, "%d", $4);
        inserer_var_secure(current_decl_id, T_INTEGER, current_decl_line);
        quadr(qc, "=", val, "-", current_decl_id);

        $$ = NULL;
      }

    | DP INTEGER_TYPE EGAL FLOTTANT PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : variable '%s' de type INTEGER initialisee avec une valeur FLOAT.\n",
          current_decl_line, current_decl_id);

        char val[32];
        sprintf(val, "%d", (int)$4);

        inserer_var_secure(current_decl_id, T_INTEGER, current_decl_line);
        quadr(qc, "=", val, "-", current_decl_id);

        $$ = NULL;
      }

    | DP FLOAT_TYPE EGAL FLOTTANT PV
      {
        char val[32];

        sprintf(val, "%f", $4);
        inserer_var_secure(current_decl_id, T_FLOAT, current_decl_line);
        quadr(qc, "=", val, "-", current_decl_id);

        $$ = NULL;
      }

    | DP FLOAT_TYPE EGAL ENTIER PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : variable '%s' de type FLOAT initialisee avec une valeur INTEGER.\n",
          current_decl_line, current_decl_id);

        char val[32];
        sprintf(val, "%f", (float)$4);

        inserer_var_secure(current_decl_id, T_FLOAT, current_decl_line);
        quadr(qc, "=", val, "-", current_decl_id);

        $$ = NULL;
      }

    | DP CROO INTEGER_TYPE PV ENTIER CROF PV
      {
        if ($5 <= 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : taille du tableau '%s' invalide (%d). Doit etre > 0.\n",
              current_decl_line, current_decl_id, $5);
        }

        inserer_tab_secure(current_decl_id, T_INTEGER, $5, current_decl_line);

        $$ = NULL;
      }

    | DP CROO FLOAT_TYPE PV ENTIER CROF PV
      {
        if ($5 <= 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : taille du tableau '%s' invalide (%d). Doit etre > 0.\n",
              current_decl_line, current_decl_id, $5);
        }

        inserer_tab_secure(current_decl_id, T_FLOAT, $5, current_decl_line);

        $$ = NULL;
      }

    | PIPE liste_idf DP INTEGER_TYPE PV
      {
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        inserer_liste_idf(liste, T_INTEGER, current_decl_line);

        free(liste);
        $$ = NULL;
      }

    | PIPE liste_idf DP FLOAT_TYPE PV
      {
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        inserer_liste_idf(liste, T_FLOAT, current_decl_line);

        free(liste);
        $$ = NULL;
      }

    | PIPE liste_idf DP INTEGER_TYPE EGAL ENTIER PV
      {
        char val[32];
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        sprintf(val, "%d", $6);

        inserer_liste_idf(liste, T_INTEGER, current_decl_line);
        generer_affectation_liste(liste, val);

        free(liste);
        $$ = NULL;
      }

    | PIPE liste_idf DP INTEGER_TYPE EGAL FLOTTANT PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : variable(s) de type INTEGER initialisee(s) avec une valeur FLOAT.\n",
          current_decl_line);

        char val[32];
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        sprintf(val, "%d", (int)$6);

        inserer_liste_idf(liste, T_INTEGER, current_decl_line);
        generer_affectation_liste(liste, val);

        free(liste);
        $$ = NULL;
      }

    | PIPE liste_idf DP FLOAT_TYPE EGAL FLOTTANT PV
      {
        char val[32];
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        sprintf(val, "%f", $6);

        inserer_liste_idf(liste, T_FLOAT, current_decl_line);
        generer_affectation_liste(liste, val);

        free(liste);
        $$ = NULL;
      }

    | PIPE liste_idf DP FLOAT_TYPE EGAL ENTIER PV
      {
        fprintf(stderr,
          "[ERREUR SEMANTIQUE] ligne %d : variable(s) de type FLOAT initialisee(s) avec une valeur INTEGER.\n",
          current_decl_line);

        char val[32];
        char* liste = construire_liste_avec_premier(current_decl_id, $2);

        sprintf(val, "%f", (float)$6);

        inserer_liste_idf(liste, T_FLOAT, current_decl_line);
        generer_affectation_liste(liste, val);

        free(liste);
        $$ = NULL;
      }
    ;

liste_idf
    : IDF
      {
        $$ = strdup($1);
      }

    | IDF PIPE liste_idf
      {
        char* tmp = (char*)malloc(strlen($1) + strlen($3) + 2);

        sprintf(tmp, "%s|%s", $1, $3);
        $$ = tmp;
      }
    ;

/* =========================
   INSTRUCTIONS
   ========================= */

partie_instructions
    : /* vide */
      {
        $$ = NULL;
      }

    | partie_instructions instruction
      {
        $$ = $1;
      }
    ;

M
    : /* vide */
      {
        $$ = qc;
      }
    ;

suite_if
    : ENDIF PV
      {
        $$ = 0;
      }

    | ELSE
      {
        int qbr = qc;

        quadr(qc, "BR", "-", "-", "0");
        empiler_quad(qbr);

        {
            int qcond = depiler_branch();
            ajour_quad_entier(qcond, 4, qc);
        }
      }
      ACCO partie_instructions ACCF ENDIF PV
      {
        int qsortie = depiler_quad();

        ajour_quad_entier(qsortie, 4, qc);
        $$ = 1;
      }
    ;

instruction
    : IDF AFFECT expr PV
      {
        element* s = chercherTS($1);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : identificateur '%s' non declare.\n",
              @1.first_line, $1);
        } else {
            if (strcmp(s->code, "CONST") == 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' est une constante, reaffectation interdite.\n",
                  @1.first_line, $1);
            }

            if (is_tab_noidx($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' est un tableau, utilisation sans indice interdite.\n",
                  @3.first_line, (char*)raw($3));
            }

            if (strcmp(s->type, "INT") == 0 && is_float_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : '%s' est INTEGER mais l'expression est FLOAT.\n",
                  @1.first_line, $1);
            }

            if (strcmp(s->type, "INT") == 0 && is_str_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : '%s' est INTEGER mais l'expression est STRING.\n",
                  @1.first_line, $1);
            }

            if (strcmp(s->type, "FLOAT") == 0 && is_str_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : '%s' est FLOAT mais l'expression est STRING.\n",
                  @1.first_line, $1);
            }

            if (strcmp(s->code, "CONST") != 0 &&
                !is_tab_noidx($3) &&
                !(strcmp(s->type, "INT") == 0 && is_float_type($3)) &&
                !(strcmp(s->type, "INT") == 0 && is_str_type($3)) &&
                !(strcmp(s->type, "FLOAT") == 0 && is_str_type($3))) {
                quadr(qc, "<--", (char*)raw($3), "-", $1);
            }
        }
      }

    | IDF CROO expr CROF AFFECT expr PV
      {
        element* s = chercherTS($1);
        int erreur = 0;

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : tableau '%s' non declare.\n",
              @1.first_line, $1);
            erreur = 1;
        } else {
            if (strcmp(s->code, "TAB") != 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' n'est pas un tableau.\n",
                  @1.first_line, $1);
                erreur = 1;
            }

            if (is_float_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : indice du tableau '%s' doit etre INTEGER.\n",
                  @1.first_line, $1);
                erreur = 1;
            }

            if (is_str_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : indice du tableau '%s' doit etre INTEGER, pas STRING.\n",
                  @1.first_line, $1);
                erreur = 1;
            }

            if (strcmp(s->code, "TAB") == 0) {
                char taille[32];
                int idxConst;

                sprintf(taille, "%d", s->scope);

                if (get_int_const_value($3, &idxConst)) {
                    if (idxConst < 0) {
                        fprintf(stderr,
                          "[ERREUR SEMANTIQUE] ligne %d : indice negatif %d pour le tableau '%s'.\n",
                          @3.first_line, idxConst, $1);
                        erreur = 1;
                    }

                    if (idxConst >= s->scope) {
                        fprintf(stderr,
                          "[ERREUR SEMANTIQUE] ligne %d : depassement de taille : indice %d hors limites pour le tableau '%s' de taille %d. Indices valides : [0..%d].\n",
                          @3.first_line, idxConst, $1, s->scope, s->scope - 1);
                        erreur = 1;
                    }
                }

                if (!erreur) {
                    quadr(qc, "BOUNDS", "0", taille, (char*)raw($3));
                }

                if (strcmp(s->type, "INT") == 0 && is_float_type($6)) {
                    fprintf(stderr,
                      "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : tableau '%s' est INTEGER mais la valeur est FLOAT.\n",
                      @1.first_line, $1);
                    erreur = 1;
                }

                if (strcmp(s->type, "INT") == 0 && is_str_type($6)) {
                    fprintf(stderr,
                      "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : tableau '%s' est INTEGER mais la valeur est STRING.\n",
                      @1.first_line, $1);
                    erreur = 1;
                }

                if (strcmp(s->type, "FLOAT") == 0 && is_str_type($6)) {
                    fprintf(stderr,
                      "[ERREUR SEMANTIQUE] ligne %d : affectation incompatible : tableau '%s' est FLOAT mais la valeur est STRING.\n",
                      @1.first_line, $1);
                    erreur = 1;
                }
            }
        }

        if (!erreur) {
            quadr(qc, "[]<--", (char*)raw($6), (char*)raw($3), $1);
        }
      }

    | IF PO condition PF THEN DP
      {
        int qcond = qc;

        quadr(qc, "BZ", (char*)raw($3), "-", "0");
        empiler_branch(qcond);
      }
      ACCO partie_instructions ACCF suite_if
      {
        if ($11 == 0) {
            int qif = depiler_branch();
            ajour_quad_entier(qif, 4, qc);
        }
      }

    | LOOP WHILE PO M condition PF
      {
        int qcond = qc;

        quadr(qc, "BZ", (char*)raw($5), "-", "0");
        empiler_branch(qcond);
      }
      ACCO partie_instructions ACCF
      {
        int debut = $4;

        quadr(qc, "BR", "-", "-", "0");
        ajour_quad_entier(qc - 1, 4, debut);

        {
            int qcond = depiler_branch();
            ajour_quad_entier(qcond, 4, qc);
        }
      }
      ENDLOOP PV
      { }

    | FOR IDF INKW expr TOKW expr
      {
        element* s_var = chercherTS($2);

        if (!s_var) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : variable de boucle 'for' '%s' non declaree.\n",
              @2.first_line, $2);
        } else {
            if (strcmp(s_var->type, "INT") != 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : variable de boucle 'for' '%s' doit etre de type INTEGER.\n",
                  @2.first_line, $2);
            }

            if (strcmp(s_var->code, "CONST") == 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : variable de boucle 'for' '%s' est une constante, modification interdite.\n",
                  @2.first_line, $2);
            }
        }

        if (is_float_type($4) || is_str_type($4)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : la valeur initiale du 'for' doit etre un entier.\n",
              @4.first_line);
        }

        if (is_float_type($6) || is_str_type($6)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : la valeur limite du 'for' doit etre un entier.\n",
              @6.first_line);
        }

        {
            int debut, fin;

            if (get_int_const_value($4, &debut) && get_int_const_value($6, &fin)) {
                if (debut > fin) {
                    fprintf(stderr,
                      "[ERREUR SEMANTIQUE] ligne %d : borne initiale (%d) > borne finale (%d) dans le 'for'.\n",
                      @2.first_line, debut, fin);
                }

                if (debut == fin) {
                    fprintf(stderr,
                      "[AVERTISSEMENT SEMANTIQUE] ligne %d : borne initiale == borne finale (%d) dans le 'for', la boucle s'execute une seule fois.\n",
                      @2.first_line, debut);
                }
            }
        }

        quadr(qc, "<--", (char*)raw($4), "-", $2);

        empiler_quad(qc);

        {
            char tmp[32];

            sprintf(tmp, "c%d", qc);
            quadr(qc, "<=", $2, (char*)raw($6), tmp);
            quadr(qc, "BZ", tmp, "-", "0");
            empiler_branch(qc - 1);
        }
      }
      ACCO partie_instructions ACCF
      {
        quadr(qc, "AINC", $2, "-", "-");

        {
            int debut_test = depiler_quad();

            quadr(qc, "BR", "-", "-", "0");
            ajour_quad_entier(qc - 1, 4, debut_test);
        }

        {
            int qcond = depiler_branch();

            ajour_quad_entier(qcond, 4, qc);
        }
      }
      ENDFOR PV
      { }

    | INPUTKW PO IDF PF PV
      {
        element* s = chercherTS($3);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : identificateur '%s' non declare dans INPUT.\n",
              @3.first_line, $3);
        } else {
            if (strcmp(s->code, "CONST") == 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' est une constante, INPUT interdit.\n",
                  @3.first_line, $3);
            } else if (strcmp(s->code, "TAB") == 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' est un tableau, INPUT sans indice interdit.\n",
                  @3.first_line, $3);
            } else {
                quadr(qc, "INPUT", "-", "-", $3);
            }
        }
      }

    | OUTPUTKW PO output_args PF PV
      {
        quadr(qc, "OUTPUT", $3, "-", "-");
      }
    ;

/* =========================
   OUTPUT
   ========================= */

output_args
    : STRING
      {
        $$ = strdup($1);
      }

    | IDF
      {
        element* s = chercherTS($1);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : identificateur '%s' non declare dans OUTPUT.\n",
              @1.first_line, $1);
        } else if (strcmp(s->code, "TAB") == 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : '%s' est un tableau, OUTPUT sans indice interdit.\n",
              @1.first_line, $1);
        }

        $$ = strdup($1);
      }

    | STRING VIRG output_args
      {
        char* tmp = (char*)malloc(strlen($1) + strlen($3) + 2);

        sprintf(tmp, "%s,%s", $1, $3);
        $$ = tmp;
      }

    | IDF VIRG output_args
      {
        element* s = chercherTS($1);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : identificateur '%s' non declare dans OUTPUT.\n",
              @1.first_line, $1);
        } else if (strcmp(s->code, "TAB") == 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : '%s' est un tableau, OUTPUT sans indice interdit.\n",
              @1.first_line, $1);
        }

        char* tmp = (char*)malloc(strlen($1) + strlen($3) + 2);

        sprintf(tmp, "%s,%s", $1, $3);
        $$ = tmp;
      }
    ;

/* =========================
   EXPRESSIONS
   ========================= */

expr
    : expr PLUS expr
      {
        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : operation '+' interdite sur une expression STRING.\n",
              @1.first_line);
        }

        char tmp[16];
        sprintf(tmp, "t%d", qc);

        quadr(qc, "+", (char*)raw($1), (char*)raw($3), tmp);

        $$ = (is_float_type($1) || is_float_type($3))
              ? make_typed("FLT:", tmp)
              : make_typed("INT:", tmp);
      }

    | expr MOINS expr
      {
        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : operation '-' interdite sur une expression STRING.\n",
              @1.first_line);
        }

        char tmp[16];
        sprintf(tmp, "t%d", qc);

        quadr(qc, "-", (char*)raw($1), (char*)raw($3), tmp);

        $$ = (is_float_type($1) || is_float_type($3))
              ? make_typed("FLT:", tmp)
              : make_typed("INT:", tmp);
      }

    | expr MUL expr
      {
        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : operation '*' interdite sur une expression STRING.\n",
              @1.first_line);
        }

        char tmp[16];
        sprintf(tmp, "t%d", qc);

        quadr(qc, "*", (char*)raw($1), (char*)raw($3), tmp);

        $$ = (is_float_type($1) || is_float_type($3))
              ? make_typed("FLT:", tmp)
              : make_typed("INT:", tmp);
      }

    | expr DIV expr
      {
        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : operation '/' interdite sur une expression STRING.\n",
              @1.first_line);
        }

        if (!is_float_type($3) && !is_str_type($3) && strcmp(raw($3), "0") == 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : division par zero interdite.\n",
              @3.first_line);
        }

        if (is_float_type($3) && strcmp(raw($3), "0.000000") == 0) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : division par zero (0.0) interdite.\n",
              @3.first_line);
        }

        char tmp[16];
        sprintf(tmp, "t%d", qc);

        quadr(qc, "/", (char*)raw($1), (char*)raw($3), tmp);
        quadr(qc, "DIVCHECK", "-", "-", (char*)raw($3));

        $$ = make_typed("FLT:", tmp);
      }

    | IDF CROO expr CROF
      {
        element* s = chercherTS($1);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : tableau '%s' non declare.\n",
              @1.first_line, $1);
        } else {
            if (strcmp(s->code, "TAB") != 0) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : '%s' n'est pas un tableau.\n",
                  @1.first_line, $1);
            }

            if (is_float_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : indice du tableau '%s' doit etre INTEGER.\n",
                  @1.first_line, $1);
            }

            if (is_str_type($3)) {
                fprintf(stderr,
                  "[ERREUR SEMANTIQUE] ligne %d : indice du tableau '%s' doit etre INTEGER, pas STRING.\n",
                  @1.first_line, $1);
            }

            if (strcmp(s->code, "TAB") == 0) {
                char taille[32];
                int idxConst;

                sprintf(taille, "%d", s->scope);

                if (get_int_const_value($3, &idxConst)) {
                    if (idxConst < 0) {
                        fprintf(stderr,
                          "[ERREUR SEMANTIQUE] ligne %d : indice negatif %d pour le tableau '%s'.\n",
                          @3.first_line, idxConst, $1);
                    }

                    if (idxConst >= s->scope) {
                        fprintf(stderr,
                          "[ERREUR SEMANTIQUE] ligne %d : depassement de taille : indice %d hors limites pour le tableau '%s' de taille %d. Indices valides : [0..%d].\n",
                          @3.first_line, idxConst, $1, s->scope, s->scope - 1);
                    }
                }

                quadr(qc, "BOUNDS", "0", taille, (char*)raw($3));
            }
        }

        {
            char tmp[64];

            sprintf(tmp, "%s[%s]", $1, (char*)raw($3));

            if (s && strcmp(s->type, "FLOAT") == 0) {
                $$ = make_typed("FLT:", tmp);
            } else {
                $$ = make_typed("INT:", tmp);
            }
        }
      }

    | MOINS ENTIER
      {
        char tmp[32];

        sprintf(tmp, "-%d", $2);
        $$ = make_typed("INT:", tmp);
      }

    | MOINS FLOTTANT
      {
        char tmp[32];

        sprintf(tmp, "-%f", $2);
        $$ = make_typed("FLT:", tmp);
      }

    | PO expr PF
      {
        $$ = $2;
      }

    | ENTIER
      {
        char tmp[32];

        sprintf(tmp, "%d", $1);
        $$ = make_typed("INT:", tmp);
      }

    | FLOTTANT
      {
        char tmp[32];

        sprintf(tmp, "%f", $1);
        $$ = make_typed("FLT:", tmp);
      }

    | STRING
      {
        $$ = make_typed("STR:", $1);
      }

    | IDF
      {
        element* s = chercherTS($1);

        if (!s) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : identificateur '%s' non declare.\n",
              @1.first_line, $1);

            $$ = make_typed("INT:", $1);
        } else if (strcmp(s->code, "TAB") == 0) {
            $$ = make_typed("TAB:", $1);
        } else if (strcmp(s->type, "FLOAT") == 0) {
            $$ = make_typed("FLT:", $1);
        } else {
            $$ = make_typed("INT:", $1);
        }
      }
    ;

/* =========================
   CONDITIONS
   ========================= */

condition
    : expr GT expr
      {
        char tmp[32];

        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '>' avec une expression STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, ">", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | expr LT expr
      {
        char tmp[32];

        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '<' avec une expression STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, "<", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | expr GTE expr
      {
        char tmp[32];

        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '>=' avec une expression STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, ">=", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | expr LTE expr
      {
        char tmp[32];

        if (is_str_type($1) || is_str_type($3)) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '<=' avec une expression STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, "<=", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | expr EQ expr
      {
        char tmp[32];

        if ((is_str_type($1) && !is_str_type($3)) ||
            (!is_str_type($1) && is_str_type($3))) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '==' entre STRING et non-STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, "==", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | expr NEQ expr
      {
        char tmp[32];

        if ((is_str_type($1) && !is_str_type($3)) ||
            (!is_str_type($1) && is_str_type($3))) {
            fprintf(stderr,
              "[ERREUR SEMANTIQUE] ligne %d : comparaison '!=' entre STRING et non-STRING interdite.\n",
              @1.first_line);
        }

        sprintf(tmp, "c%d", qc);
        quadr(qc, "!=", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | condition AND condition
      {
        char tmp[32];

        sprintf(tmp, "c%d", qc);
        quadr(qc, "AND", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | condition OR condition
      {
        char tmp[32];

        sprintf(tmp, "c%d", qc);
        quadr(qc, "OR", (char*)raw($1), (char*)raw($3), tmp);
        $$ = strdup(tmp);
      }

    | NOT condition
      {
        char tmp[32];

        sprintf(tmp, "c%d", qc);
        quadr(qc, "NOT", (char*)raw($2), "-", tmp);
        $$ = strdup(tmp);
      }

    | PO condition PF
      {
        $$ = $2;
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr,
            "Erreur_syntaxique, ligne %d, colonne %d : %s\n",
            yylloc.first_line,
            yylloc.first_column,
            s);
}

int main(int argc, char** argv) {
    (void)argc;
    (void)argv;

    if (yyparse() == 0) {
        printf("\nCompilation Programme M1_iv_2526 terminee.\n");
    }

    return 0;
}
