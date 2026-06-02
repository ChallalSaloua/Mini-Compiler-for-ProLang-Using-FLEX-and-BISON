#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>

#define MAX_QUAD 1000
#define TAILLE_PILE 1000

/* =========================
   Structure d'un quadruplet
   ========================= */
typedef struct {
    char op[20];
    char arg1[50];
    char arg2[50];
    char res[50];
    int  supprime;   /* 0 = actif, 1 = supprimé après optimisation */
} quadruplet;

/* =========================
   Structure d'une pile
   ========================= */
typedef struct {
    int data[TAILLE_PILE];
    int sommet;
} Pile;

/* =========================
   Variables globales
   ========================= */
extern quadruplet qdr[MAX_QUAD];
extern int qc;

extern Pile branch;
extern Pile pileQuad;

/* =========================
   Gestion des piles
   ========================= */
void initPile(Pile *p);
int pileVide(Pile *p);

void empiler_branch(int val);
int depiler_branch(void);

void empiler_quad(int val);
int depiler_quad(void);

/* =========================
   Gestion des quadruplets
   ========================= */
void init_qdr(void);

void quadr(
    int index,
    const char *op,
    const char *arg1,
    const char *arg2,
    const char *res
);

void ajour_quad_char(int num_quad, int colonne, const char *val);
void ajour_quad_entier(int num_quad, int colonne, int val);

/* =========================
   Affichage
   ========================= */
void afficher_qdr(void);
void afficher_qdr_supprimes(void);
void afficher_qdr_apres_opti(void);

/* =========================
   Optimisation
   ========================= */
void optimiser_quadruplets(void);

/* =========================
   Génération code objet
   ========================= */
void generer_code_objet(void);

#endif
