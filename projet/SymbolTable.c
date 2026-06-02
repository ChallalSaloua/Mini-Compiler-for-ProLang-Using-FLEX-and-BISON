#define _POSIX_C_SOURCE 200809L
#include "SymbolTable.h"

element* tab[HASH_SIZE_IDF];
elt*     tabm[HASH_SIZE_KW];
elt*     tabs[HASH_SIZE_SEP];

char*    type_stack[STACK_SIZE];
int      stack_top = -1;

/* ========= utilitaire strdup portable ========= */
char* my_strdup(const char* s) {
    if (!s) return NULL;

    char* p = (char*)malloc(strlen(s) + 1);

    if (p) {
        strcpy(p, s);
    }

    return p;
}

/* ========= initialisation des tables ========= */
void initialisation(void) {
    int i;

    for (i = 0; i < HASH_SIZE_IDF; i++) {
        tab[i] = NULL;
    }

    for (i = 0; i < HASH_SIZE_KW; i++) {
        tabm[i] = NULL;
    }

    for (i = 0; i < HASH_SIZE_SEP; i++) {
        tabs[i] = NULL;
    }

    stack_top = -1;
}

/* ========= fonction de hachage djb2 améliorée ========= */
unsigned int hash_function(const char* str) {
    unsigned int h = 5381;
    unsigned char c;

    if (!str) return 0;

    while ((c = (unsigned char)*str++)) {
        if (c >= 'A' && c <= 'Z') {
            c = (unsigned char)(c - 'A' + 'a');
        }

        h = ((h << 5) + h) ^ c;
    }

    return h;
}

/* ========= recherche dans un bucket ========= */
static element* chercher_bucket(element* bucket, const char* nom) {
    element* c;

    for (c = bucket; c != NULL; c = c->next) {
        if (strcmp(c->name, nom) == 0) {
            return c;
        }
    }

    return NULL;
}

/* ========= API publique : recherche dans la table IDF ========= */
element* chercherTS(char* nom) {
    unsigned int h;
    unsigned int idx;

    if (!nom) return NULL;

    h   = hash_function(nom);
    idx = h % HASH_SIZE_IDF;

    return chercher_bucket(tab[idx], nom);
}

/* ========= insertion brute dans un bucket IDF ========= */
static element* inserer_dans_bucket(element** bucket,
                                    const char* entite,
                                    const char* code,
                                    const char* type,
                                    float val,
                                    int scope,
                                    int line_number)
{
    element* e;

    if (!bucket || !entite || !code || !type) return NULL;

    e = (element*)malloc(sizeof(element));

    if (!e) {
        fprintf(stderr, "Erreur malloc inserer\n");
        return NULL;
    }

    e->state = 1;

    strncpy(e->name, entite, 63);
    e->name[63] = '\0';

    strncpy(e->code, code, 31);
    e->code[31] = '\0';

    strncpy(e->type, type, 15);
    e->type[15] = '\0';

    e->val         = val;
    e->scope       = scope;
    e->line_number = line_number;

    e->next = *bucket;
    *bucket = e;

    return e;
}

/* ========= insertion générique ========= */
void inserer(char entite[], char code[], char type[],
             float val, int y, int scope, int line_number)
{
    unsigned int h;
    unsigned int index;

    if (!entite || !code || !type) return;

    h = hash_function(entite);

    if (y == 0) {
        index = h % HASH_SIZE_IDF;

        inserer_dans_bucket(&tab[index],
                            entite,
                            code,
                            type,
                            val,
                            scope,
                            line_number);
    }

    else if (y == 1) {
        elt* n;

        index = h % HASH_SIZE_KW;
        n = (elt*)malloc(sizeof(elt));

        if (!n) return;

        n->state = 1;

        strncpy(n->name, entite, 31);
        n->name[31] = '\0';

        strncpy(n->type, code, 15);
        n->type[15] = '\0';

        n->next = tabm[index];
        tabm[index] = n;
    }

    else if (y == 2) {
        elt* n;

        index = h % HASH_SIZE_SEP;
        n = (elt*)malloc(sizeof(elt));

        if (!n) return;

        n->state = 1;

        strncpy(n->name, entite, 31);
        n->name[31] = '\0';

        strncpy(n->type, code, 15);
        n->type[15] = '\0';

        n->next = tabs[index];
        tabs[index] = n;
    }
}

/* ========= affichage table des symboles ========= */
void afficher(void) {
    int count = 0;
    int i;

    printf("\n============================================================================================================\n");
    printf("                               TABLE DES SYMBOLES                                  \n");
    printf("============================================================================================================\n\n");

    printf("\t| %-15s | %-12s | %-12s | %-10s | %-9s | %-9s | %-5s |\n",
           "Nom_Entite",
           "Code_Entite",
           "Type_Entite",
           "Val_Entite",
           "TailleMIN",
           "TailleMAX",
           "Ligne");

    printf("\t------------------------------------------------------------------------------------------------------------\n");

    for (i = 0; i < HASH_SIZE_IDF; i++) {
        element* c = tab[i];

        while (c) {
            if (c->state) {
                int tailleMin = 0;
                int tailleMax = 0;

                if (strcmp(c->code, "TAB") == 0) {
                    tailleMin = 0;
                    tailleMax = c->scope - 1;
                }

                printf("\t| %-15s | %-12s | %-12s | %-10.2f | %-9d | %-9d | %-5d |\n",
                       c->name,
                       c->code,
                       c->type,
                       c->val,
                       tailleMin,
                       tailleMax,
                       c->line_number);

                count++;
            }

            c = c->next;
        }
    }

    if (count == 0) {
        printf("\t| %-50s |\n", "(table vide)");
    }

    printf("==============================================================================================================\n");
    printf("  Total : %d symbole(s)\n", count);
    printf("==============================================================================================================\n");
}

/* ========= pile de types ========= */
void push_type(const char* t) {
    if (stack_top < STACK_SIZE - 1) {
        type_stack[++stack_top] = my_strdup(t);
    } else {
        fprintf(stderr, "Stack overflow type\n");
        exit(1);
    }
}

char* pop_type(void) {
    if (stack_top >= 0) {
        return type_stack[stack_top--];
    }

    fprintf(stderr, "Stack underflow type\n");
    exit(1);
}

char* peek_type(void) {
    return (stack_top >= 0) ? type_stack[stack_top] : NULL;
}

/* ========= insertion haut niveau ========= */
void insererProg(char* nom, int ligne) {
    printf("Programme '%s' ligne %d\n", nom, ligne);
}

void insererConst(char* nom, int type, char* val, int ligne) {
    unsigned int h;
    unsigned int idx;
    float fval;

    if (!nom || !val) return;

    h   = hash_function(nom);
    idx = h % HASH_SIZE_IDF;

    if (chercher_bucket(tab[idx], nom)) {
        erreur_semantique("double declaration", ligne, 0, nom);
        return;
    }

    fval = (type == T_INTEGER) ? (float)atoi(val) : (float)atof(val);

    inserer_dans_bucket(&tab[idx],
                        nom,
                        "CONST",
                        (type == T_INTEGER) ? "INT" : "FLOAT",
                        fval,
                        0,
                        ligne);
}

void insererVar(char* nom, int type, int ligne) {
    unsigned int h;
    unsigned int idx;

    if (!nom) return;

    h   = hash_function(nom);
    idx = h % HASH_SIZE_IDF;

    if (chercher_bucket(tab[idx], nom)) {
        erreur_semantique("double declaration", ligne, 0, nom);
        return;
    }

    inserer_dans_bucket(&tab[idx],
                        nom,
                        "VAR",
                        (type == T_INTEGER) ? "INT" : "FLOAT",
                        0.0f,
                        0,
                        ligne);
}

void insererTab(char* nom, int type, int taille, int ligne) {
    unsigned int h;
    unsigned int idx;

    if (!nom) return;

    h   = hash_function(nom);
    idx = h % HASH_SIZE_IDF;

    if (chercher_bucket(tab[idx], nom)) {
        erreur_semantique("double declaration", ligne, 0, nom);
        return;
    }

    if (taille <= 0) {
        erreur_semantique("taille de tableau <= 0", ligne, 0, nom);
        return;
    }

    inserer_dans_bucket(&tab[idx],
                        nom,
                        "TAB",
                        (type == T_INTEGER) ? "INT" : "FLOAT",
                        0.0f,
                        taille,
                        ligne);
}

/* ========= gestion d'erreurs ========= */
void erreur_semantique(const char* msg, int ligne, int col, char* id) {
    fprintf(stderr,
        "[ERREUR SEMANTIQUE] ligne %d, col %d : %s (id='%s')\n",
        ligne,
        col,
        msg ? msg : "",
        id ? id : "");
}