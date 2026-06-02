#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASH_SIZE_IDF 211
#define HASH_SIZE_KW   53
#define HASH_SIZE_SEP  53
#define STACK_SIZE    100

#define T_INTEGER 1
#define T_FLOAT   2

typedef struct element {
    char  name[64];
    char  code[32];   /* VAR / CONST / TAB */
    char  type[16];   /* INT / FLOAT */
    float val;
    int   state;
    int   scope;      /* Pour TAB : taille du tableau ; sinon portee */
    int   line_number;
    struct element* next;
} element;

typedef struct elt {
    char name[32];
    char type[16];
    int  state;
    struct elt* next;
} elt;

/* =========================
   Tables de hachage
   ========================= */
extern element* tab[HASH_SIZE_IDF];
extern elt*     tabm[HASH_SIZE_KW];
extern elt*     tabs[HASH_SIZE_SEP];

/* =========================
   Pile de types
   ========================= */
extern char* type_stack[STACK_SIZE];
extern int   stack_top;

/* =========================
   Fonctions utilitaires
   ========================= */
char*        my_strdup(const char* s);
void         initialisation(void);
unsigned int hash_function(const char* str);

/* =========================
   Table des symboles
   ========================= */
void         inserer(char entite[], char code[], char type[],
                     float val, int y, int scope, int line_number);

element*     chercherTS(char* nom);
void         afficher(void);

/* =========================
   Pile de types
   ========================= */
void         push_type(const char* t);
char*        pop_type(void);
char*        peek_type(void);

/* =========================
   Insertion haut niveau
   ========================= */
void         insererProg(char* nom, int ligne);
void         insererConst(char* nom, int type, char* val, int ligne);
void         insererVar(char* nom, int type, int ligne);
void         insererTab(char* nom, int type, int taille, int ligne);

/* =========================
   Erreurs
   ========================= */
void         erreur_semantique(const char* msg, int ligne, int col, char* id);

#endif