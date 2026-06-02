#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "quad.h"

/* =========================================
   Variables globales
   ========================================= */
quadruplet qdr[MAX_QUAD];
int qc = 0;

Pile branch = { .sommet = -1 };
Pile pileQuad = { .sommet = -1 };

/* Pour mémoriser les lignes supprimées */
static int ids_supprimes[MAX_QUAD];
static int nb_supprimes = 0;

/* =========================================
   Fonctions utilitaires internes
   ========================================= */
static int est_zero(const char *s) {
    if (!s) return 0;

    return (strcmp(s, "0") == 0 ||
            strcmp(s, "0.0") == 0 ||
            strcmp(s, "0.000000") == 0);
}

static int est_un(const char *s) {
    if (!s) return 0;

    return (strcmp(s, "1") == 0 ||
            strcmp(s, "1.0") == 0 ||
            strcmp(s, "1.000000") == 0);
}

static void marquer_supprime(int i) {
    if (i >= 0 && i < qc && qdr[i].supprime == 0) {
        qdr[i].supprime = 1;
        ids_supprimes[nb_supprimes++] = i;
    }
}

static int est_nombre_constante(const char *s) {
    int i = 0;
    int point = 0;
    int chiffre = 0;

    if (!s || !*s) return 0;

    if (s[0] == '-' || s[0] == '+') i = 1;

    for (; s[i]; i++) {
        if (isdigit((unsigned char)s[i])) {
            chiffre = 1;
        } else if (s[i] == '.' && point == 0) {
            point = 1;
        } else {
            return 0;
        }
    }

    return chiffre;
}

static int est_temporaire(const char *s) {
    int i;

    if (!s || s[0] != 't') return 0;
    if (!isdigit((unsigned char)s[1])) return 0;

    for (i = 1; s[i]; i++) {
        if (!isdigit((unsigned char)s[i])) return 0;
    }

    return 1;
}

/*
   Recherche une constante affectée à un temporaire avant la ligne courante.
*/
static const char* valeur_constante_temporaire(const char* nom, int limite) {
    int i;

    if (!est_temporaire(nom)) return NULL;

    for (i = limite - 1; i >= 0; i--) {
        if (qdr[i].supprime) continue;

        if (strcmp(qdr[i].res, nom) == 0) {
            if (strcmp(qdr[i].op, "=") == 0 &&
                est_nombre_constante(qdr[i].arg1)) {
                return qdr[i].arg1;
            }

            return NULL;
        }
    }

    return NULL;
}

/* =========================================
   Gestion des piles
   ========================================= */
void initPile(Pile *p) {
    if (p) {
        p->sommet = -1;
    }
}

int pileVide(Pile *p) {
    return (!p || p->sommet == -1);
}

void empiler_branch(int val) {
    if (branch.sommet < TAILLE_PILE - 1) {
        branch.data[++branch.sommet] = val;
    } else {
        printf("Erreur : depassement pile branch\n");
    }
}

int depiler_branch(void) {
    if (branch.sommet >= 0) {
        return branch.data[branch.sommet--];
    }

    printf("Erreur : pile branch vide\n");
    return -1;
}

void empiler_quad(int val) {
    if (pileQuad.sommet < TAILLE_PILE - 1) {
        pileQuad.data[++pileQuad.sommet] = val;
    } else {
        printf("Erreur : depassement pileQuad\n");
    }
}

int depiler_quad(void) {
    if (pileQuad.sommet >= 0) {
        return pileQuad.data[pileQuad.sommet--];
    }

    printf("Erreur : pileQuad vide\n");
    return -1;
}

/* =========================================
   Gestion des quadruplets
   ========================================= */
void init_qdr(void) {
    int i;

    qc = 0;
    nb_supprimes = 0;

    initPile(&branch);
    initPile(&pileQuad);

    for (i = 0; i < MAX_QUAD; i++) {
        qdr[i].op[0] = '\0';
        qdr[i].arg1[0] = '\0';
        qdr[i].arg2[0] = '\0';
        qdr[i].res[0] = '\0';
        qdr[i].supprime = 0;
    }
}

void quadr(int index, const char *op, const char *arg1, const char *arg2, const char *res) {
    if (index < 0 || index >= MAX_QUAD) {
        printf("Erreur : index quadruplet invalide\n");
        return;
    }

    if (!op)   op = "-";
    if (!arg1) arg1 = "-";
    if (!arg2) arg2 = "-";
    if (!res)  res = "-";

    /*
       On garde l'affichage interne propre :
       - <-- devient =
       - []<-- devient []=
    */
    if (strcmp(op, "<--") == 0) {
        snprintf(qdr[index].op, sizeof(qdr[index].op), "%s", "=");
    } else if (strcmp(op, "[]<--") == 0) {
        snprintf(qdr[index].op, sizeof(qdr[index].op), "%s", "[]=");
    } else {
        snprintf(qdr[index].op, sizeof(qdr[index].op), "%s", op);
    }

    snprintf(qdr[index].arg1, sizeof(qdr[index].arg1), "%s", arg1);
    snprintf(qdr[index].arg2, sizeof(qdr[index].arg2), "%s", arg2);
    snprintf(qdr[index].res, sizeof(qdr[index].res), "%s", res);

    qdr[index].supprime = 0;

    if (index == qc) {
        qc++;
    }
}

void ajour_quad_char(int num_quad, int colonne, const char *val) {
    if (num_quad < 0 || num_quad >= qc) return;
    if (!val) val = "-";

    switch (colonne) {
        case 1:
            snprintf(qdr[num_quad].op, sizeof(qdr[num_quad].op), "%s", val);
            break;

        case 2:
            snprintf(qdr[num_quad].arg1, sizeof(qdr[num_quad].arg1), "%s", val);
            break;

        case 3:
            snprintf(qdr[num_quad].arg2, sizeof(qdr[num_quad].arg2), "%s", val);
            break;

        case 4:
            snprintf(qdr[num_quad].res, sizeof(qdr[num_quad].res), "%s", val);
            break;

        default:
            break;
    }
}

void ajour_quad_entier(int num_quad, int colonne, int val) {
    char buffer[32];

    snprintf(buffer, sizeof(buffer), "%d", val);
    ajour_quad_char(num_quad, colonne, buffer);
}

/* =========================================
   Affichage avant optimisation
   ========================================= */
void afficher_qdr(void) {
    int i;

    printf("\n============================================================================================================\n");
    printf("                               TABLE DES QUADRUPLETS (avant optimisation)\n");
    printf("============================================================================================================\n");
    printf("| %-5s | %-14s | %-16s | %-16s | %-16s |\n",
           "ID", "OPERATION", "ARG1", "ARG2", "RESULTAT");
    printf("------------------------------------------------------------------------------------------------------------\n");

    for (i = 0; i < qc; i++) {
        printf("| %-5d | %-14s | %-16s | %-16s | %-16s |\n",
               i, qdr[i].op, qdr[i].arg1, qdr[i].arg2, qdr[i].res);
    }

    printf("============================================================================================================\n");
}

/* =========================================
   Optimisation
   ========================================= */
void optimiser_quadruplets(void) {
    int i;
    int pass;

    nb_supprimes = 0;

    for (i = 0; i < qc; i++) {
        qdr[i].supprime = 0;
    }

    for (pass = 0; pass < 6; pass++) {
        for (i = 0; i < qc; i++) {
            const char* v1;
            const char* v2;

            if (qdr[i].supprime) continue;

            /*
               Propagation courte des constantes portées par des temporaires.
            */
            v1 = valeur_constante_temporaire(qdr[i].arg1, i);
            v2 = valeur_constante_temporaire(qdr[i].arg2, i);

            if (v1) {
                snprintf(qdr[i].arg1, sizeof(qdr[i].arg1), "%s", v1);
            }

            if (v2) {
                snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", v2);
            }

            /* 1) a = a -> suppression */
            if (strcmp(qdr[i].op, "=") == 0 &&
                strcmp(qdr[i].arg1, qdr[i].res) == 0) {
                marquer_supprime(i);
                continue;
            }

            /* 2) t = a + 0 -> t = a ; t = 0 + a -> t = a */
            if (strcmp(qdr[i].op, "+") == 0) {
                if (est_zero(qdr[i].arg1)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg1, sizeof(qdr[i].arg1), "%s", qdr[i].arg2);
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                } else if (est_zero(qdr[i].arg2)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                }
            }

            /* 3) t = a - 0 -> t = a */
            if (strcmp(qdr[i].op, "-") == 0) {
                if (est_zero(qdr[i].arg2)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                }
            }

            /* 4) t = a * 1 -> t = a ; t = 1 * a -> t = a ; t = a * 0 -> t = 0 */
            if (strcmp(qdr[i].op, "*") == 0) {
                if (est_un(qdr[i].arg1)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg1, sizeof(qdr[i].arg1), "%s", qdr[i].arg2);
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                } else if (est_un(qdr[i].arg2)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                } else if (est_zero(qdr[i].arg1) || est_zero(qdr[i].arg2)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg1, sizeof(qdr[i].arg1), "%s", "0");
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");
                }
            }

            /*
               5) t = a / 1 -> t = a.
            */
            if (strcmp(qdr[i].op, "/") == 0) {
                if (est_un(qdr[i].arg2)) {
                    snprintf(qdr[i].op, sizeof(qdr[i].op), "%s", "=");
                    snprintf(qdr[i].arg2, sizeof(qdr[i].arg2), "%s", "-");

                    if (i + 1 < qc &&
                        !qdr[i + 1].supprime &&
                        strcmp(qdr[i + 1].op, "DIVCHECK") == 0 &&
                        est_un(qdr[i + 1].res)) {
                        marquer_supprime(i + 1);
                    }
                }
            }

            /*
               6) Suppression directe des DIVCHECK sur constante non nulle.
            */
            if (strcmp(qdr[i].op, "DIVCHECK") == 0) {
                if (est_nombre_constante(qdr[i].res) && !est_zero(qdr[i].res)) {
                    marquer_supprime(i);
                    continue;
                }
            }

            /*
               7) propagation simple :
                  i   : t = x
                  i+1 : y = t
                  => i+1 devient y = x, et i est supprimé
            */
            if (i + 1 < qc && !qdr[i + 1].supprime) {
                if (strcmp(qdr[i].op, "=") == 0 &&
                    strcmp(qdr[i + 1].op, "=") == 0 &&
                    strcmp(qdr[i + 1].arg1, qdr[i].res) == 0) {
                    snprintf(qdr[i + 1].arg1,
                             sizeof(qdr[i + 1].arg1),
                             "%s",
                             qdr[i].arg1);
                    marquer_supprime(i);
                    continue;
                }
            }
        }
    }
}

/* =========================================
   Affichage des lignes supprimées
   ========================================= */
void afficher_qdr_supprimes(void) {
    int i;

    printf("\n============================================================================================================\n");
    printf("                         QUADRUPLETS SUPPRIMES / MODIFIES PAR L'OPTIMISATION\n");
    printf("============================================================================================================\n");
    printf("| %-5s | %-12s | %-16s | %-16s | %-16s | %-20s |\n",
           "ID", "TYPE", "OP", "ARG1", "ARG2", "RESULTAT");
    printf("------------------------------------------------------------------------------------------------------------\n");

    if (nb_supprimes == 0) {
        printf("| %-5s | %-12s | %-16s | %-16s | %-16s | %-20s |\n",
               "-", "AUCUN", "-", "-", "-", "-");
    } else {
        for (i = 0; i < nb_supprimes; i++) {
            int id = ids_supprimes[i];

            printf("| %-5d | %-12s | %-16s | %-16s | %-16s | %-20s |\n",
                   id, "SUPPRIMEE", qdr[id].op, qdr[id].arg1, qdr[id].arg2, qdr[id].res);
        }
    }

    printf("============================================================================================================\n");
}

/* =========================================
   Affichage après optimisation
   ========================================= */
void afficher_qdr_apres_opti(void) {
    int i;

    printf("\n============================================================================================================\n");
    printf("                               TABLE DES QUADRUPLETS (apres optimisation)\n");
    printf("============================================================================================================\n");
    printf("| %-5s | %-14s | %-16s | %-16s | %-16s |\n",
           "ID", "OPERATION", "ARG1", "ARG2", "RESULTAT");
    printf("------------------------------------------------------------------------------------------------------------\n");

    for (i = 0; i < qc; i++) {
        if (qdr[i].supprime) continue;

        printf("| %-5d | %-14s | %-16s | %-16s | %-16s |\n",
               i, qdr[i].op, qdr[i].arg1, qdr[i].arg2, qdr[i].res);
    }

    printf("============================================================================================================\n");
}

/* =========================================
   Fonctions pour la génération assembleur 8086
   ========================================= */

/* =========================================
   Génération assembleur 8086 complète
   - entiers
   - tableaux
   - floats en virgule fixe x100
   - OUTPUT avec affichage entier / float
   ========================================= */

#define MAX_NOMS_ASM 1000
#define CG_SCALE 100

typedef struct {
    char nom[50];
    int taille;
    int is_float;
} ArrayInfo;

typedef struct {
    char label[50];
    char text[200];
} MsgInfo;

static ArrayInfo arrays_asm[MAX_NOMS_ASM];
static int nb_arrays_asm = 0;

static char float_names_asm[MAX_NOMS_ASM][50];
static int nb_float_names_asm = 0;

static MsgInfo output_msgs[MAX_NOMS_ASM];
static int nb_output_msgs = 0;

/* =========================================================
   Détection nombres / identificateurs
   ========================================================= */

static int cg_is_int_literal(const char *s) {
    int i = 0;

    if (!s || !*s) return 0;
    if (strcmp(s, "-") == 0) return 0;

    if (s[0] == '-' || s[0] == '+') i = 1;
    if (!s[i]) return 0;

    for (; s[i]; i++) {
        if (!isdigit((unsigned char)s[i])) return 0;
    }

    return 1;
}

static int cg_is_float_literal(const char *s) {
    int i = 0;
    int point = 0;
    int chiffre = 0;

    if (!s || !*s) return 0;
    if (strcmp(s, "-") == 0) return 0;

    if (s[0] == '-' || s[0] == '+') i = 1;
    if (!s[i]) return 0;

    for (; s[i]; i++) {
        if (isdigit((unsigned char)s[i])) {
            chiffre = 1;
        } else if (s[i] == '.' && point == 0) {
            point = 1;
        } else {
            return 0;
        }
    }

    return chiffre && point;
}

static int cg_is_number(const char *s) {
    return cg_is_int_literal(s) || cg_is_float_literal(s);
}

static int cg_is_identifier(const char *s) {
    int i;

    if (!s || !*s) return 0;
    if (strcmp(s, "-") == 0) return 0;
    if (cg_is_number(s)) return 0;

    if (!(isalpha((unsigned char)s[0]) || s[0] == '_')) return 0;

    for (i = 1; s[i]; i++) {
        if (!(isalnum((unsigned char)s[i]) || s[i] == '_')) {
            return 0;
        }
    }

    return 1;
}

static int cg_float_to_fixed(const char *s) {
    double v = atof(s);

    if (v >= 0) {
        return (int)(v * CG_SCALE + 0.5);
    } else {
        return (int)(v * CG_SCALE - 0.5);
    }
}

/* =========================================================
   Parsing tableau : Tab[i]
   ========================================================= */

static int cg_parse_array_ref(const char *s, char *base, char *index) {
    const char *p1;
    const char *p2;
    int len_base;
    int len_index;

    if (!s) return 0;

    p1 = strchr(s, '[');
    p2 = strchr(s, ']');

    if (!p1 || !p2 || p2 < p1) return 0;

    len_base = (int)(p1 - s);
    len_index = (int)(p2 - p1 - 1);

    if (len_base <= 0 || len_base >= 50) return 0;
    if (len_index <= 0 || len_index >= 50) return 0;

    strncpy(base, s, len_base);
    base[len_base] = '\0';

    strncpy(index, p1 + 1, len_index);
    index[len_index] = '\0';

    return 1;
}

/* =========================================================
   Gestion listes noms
   ========================================================= */

static int cg_name_exists(char noms[][50], int nb, const char *nom) {
    int i;

    for (i = 0; i < nb; i++) {
        if (strcmp(noms[i], nom) == 0) return 1;
    }

    return 0;
}

static void cg_add_name(char noms[][50], int *nb, const char *nom) {
    if (!cg_is_identifier(nom)) return;

    if (!cg_name_exists(noms, *nb, nom)) {
        snprintf(noms[*nb], 50, "%s", nom);
        (*nb)++;
    }
}

/* =========================================================
   Gestion tableaux
   ========================================================= */

static int cg_array_index(const char *nom) {
    int i;

    for (i = 0; i < nb_arrays_asm; i++) {
        if (strcmp(arrays_asm[i].nom, nom) == 0) return i;
    }

    return -1;
}

static int cg_is_array_name(const char *nom) {
    return cg_array_index(nom) != -1;
}

static void cg_add_array(const char *nom, int taille, int is_float) {
    int idx;

    if (!cg_is_identifier(nom)) return;
    if (taille <= 0) taille = 1;

    idx = cg_array_index(nom);

    if (idx == -1) {
        snprintf(arrays_asm[nb_arrays_asm].nom, 50, "%s", nom);
        arrays_asm[nb_arrays_asm].taille = taille;
        arrays_asm[nb_arrays_asm].is_float = is_float;
        nb_arrays_asm++;
    } else {
        if (taille > arrays_asm[idx].taille) {
            arrays_asm[idx].taille = taille;
        }

        if (is_float) {
            arrays_asm[idx].is_float = 1;
        }
    }
}

static int cg_get_nearest_bounds_size(int pos, const char *index) {
    int i;

    for (i = pos - 1; i >= 0; i--) {
        if (strcmp(qdr[i].op, "BOUNDS") == 0 &&
            strcmp(qdr[i].res, index) == 0 &&
            cg_is_int_literal(qdr[i].arg2)) {
            return atoi(qdr[i].arg2);
        }
    }

    return 1;
}

/* =========================================================
   Gestion float
   ========================================================= */

static int cg_is_float_name(const char *nom) {
    int i;
    char base[50], index[50];

    if (!nom) return 0;

    if (cg_is_float_literal(nom)) return 1;

    if (cg_parse_array_ref(nom, base, index)) {
        int idx = cg_array_index(base);
        return idx != -1 && arrays_asm[idx].is_float;
    }

    for (i = 0; i < nb_float_names_asm; i++) {
        if (strcmp(float_names_asm[i], nom) == 0) return 1;
    }

    return 0;
}

static void cg_add_float_name(const char *nom) {
    char base[50], index[50];

    if (!nom) return;

    if (cg_parse_array_ref(nom, base, index)) {
        cg_add_array(base, 1, 1);
        return;
    }

    if (!cg_is_identifier(nom)) return;

    if (!cg_name_exists(float_names_asm, nb_float_names_asm, nom)) {
        snprintf(float_names_asm[nb_float_names_asm], 50, "%s", nom);
        nb_float_names_asm++;
    }
}

/* =========================================================
   Gestion OUTPUT messages
   ========================================================= */

static void cg_strip_quotes(const char *src, char *dst, int max) {
    int i = 0;
    int j = 0;
    int len;

    if (!src || !dst || max <= 0) return;

    len = (int)strlen(src);

    if (len >= 2 && src[0] == '"' && src[len - 1] == '"') {
        i = 1;
        len--;
    }

    for (; i < len && j < max - 1; i++) {
        if (src[i] == '$') {
            dst[j++] = ' ';
        } else if (src[i] == '\'') {
            dst[j++] = ' ';
        } else {
            dst[j++] = src[i];
        }
    }

    dst[j] = '\0';
}

static int cg_is_string_token(const char *s) {
    int len;

    if (!s) return 0;

    len = (int)strlen(s);

    return len >= 2 && s[0] == '"' && s[len - 1] == '"';
}

static char* cg_get_msg_label(const char *str_token) {
    int i;
    char clean[200];

    cg_strip_quotes(str_token, clean, sizeof(clean));

    for (i = 0; i < nb_output_msgs; i++) {
        if (strcmp(output_msgs[i].text, clean) == 0) {
            return output_msgs[i].label;
        }
    }

    snprintf(output_msgs[nb_output_msgs].label, 50, "msgOut%d", nb_output_msgs);
    snprintf(output_msgs[nb_output_msgs].text, 200, "%s", clean);

    nb_output_msgs++;

    return output_msgs[nb_output_msgs - 1].label;
}

static void cg_collect_output_messages(void) {
    int i;

    nb_output_msgs = 0;

    for (i = 0; i < qc; i++) {
        char buffer[300];
        char token[200];
        int j = 0;
        int k = 0;
        int in_string = 0;

        if (qdr[i].supprime) continue;

        if (strcmp(qdr[i].op, "OUTPUT") != 0) continue;

        snprintf(buffer, sizeof(buffer), "%s", qdr[i].arg1);

        for (j = 0; ; j++) {
            char ch = buffer[j];

            if (ch == '"') {
                in_string = !in_string;
            }

            if ((ch == ',' && !in_string) || ch == '\0') {
                token[k] = '\0';

                if (cg_is_string_token(token)) {
                    cg_get_msg_label(token);
                }

                k = 0;

                if (ch == '\0') break;
            } else {
                if (k < (int)sizeof(token) - 1) {
                    token[k++] = ch;
                }
            }
        }
    }
}

/* =========================================================
   Analyse avant génération
   ========================================================= */

static void cg_collect_arrays_and_floats(void) {
    int i, pass;

    nb_arrays_asm = 0;
    nb_float_names_asm = 0;

    for (i = 0; i < qc; i++) {
        char base[50], index[50];

        if (strcmp(qdr[i].op, "[]=") == 0) {
            int taille = cg_get_nearest_bounds_size(i, qdr[i].arg2);
            int is_float = cg_is_float_literal(qdr[i].arg1);
            cg_add_array(qdr[i].res, taille, is_float);
        }

        if (cg_parse_array_ref(qdr[i].arg1, base, index)) {
            int taille = cg_get_nearest_bounds_size(i, index);
            cg_add_array(base, taille, 0);
        }

        if (cg_parse_array_ref(qdr[i].arg2, base, index)) {
            int taille = cg_get_nearest_bounds_size(i, index);
            cg_add_array(base, taille, 0);
        }

        if (cg_parse_array_ref(qdr[i].res, base, index)) {
            int taille = cg_get_nearest_bounds_size(i, index);
            cg_add_array(base, taille, 0);
        }
    }

    for (pass = 0; pass < 10; pass++) {
        for (i = 0; i < qc; i++) {
            if (qdr[i].supprime) continue;

            if (strcmp(qdr[i].op, "=") == 0) {
                if (cg_is_float_literal(qdr[i].arg1) || cg_is_float_name(qdr[i].arg1)) {
                    cg_add_float_name(qdr[i].res);
                }
            }

            else if (
                strcmp(qdr[i].op, "+") == 0 ||
                strcmp(qdr[i].op, "-") == 0 ||
                strcmp(qdr[i].op, "*") == 0 ||
                strcmp(qdr[i].op, "/") == 0
            ) {
                if (cg_is_float_literal(qdr[i].arg1) ||
                    cg_is_float_literal(qdr[i].arg2) ||
                    cg_is_float_name(qdr[i].arg1) ||
                    cg_is_float_name(qdr[i].arg2)) {
                    cg_add_float_name(qdr[i].res);
                }
            }

            else if (strcmp(qdr[i].op, "[]=") == 0) {
                if (cg_is_float_literal(qdr[i].arg1) || cg_is_float_name(qdr[i].arg1)) {
                    cg_add_array(qdr[i].res, cg_get_nearest_bounds_size(i, qdr[i].arg2), 1);
                }
            }
        }
    }

    cg_collect_output_messages();
}

static int cg_quad_is_float(int i) {
    return cg_is_float_literal(qdr[i].arg1) ||
           cg_is_float_literal(qdr[i].arg2) ||
           cg_is_float_literal(qdr[i].res)  ||
           cg_is_float_name(qdr[i].arg1)   ||
           cg_is_float_name(qdr[i].arg2)   ||
           cg_is_float_name(qdr[i].res);
}

/* =========================================================
   DATA SEGMENT
   ========================================================= */

static void cg_add_operand_to_data(char noms[][50], int *nb, const char *op) {
    char base[50], index[50];

    if (!op || strcmp(op, "-") == 0) return;

    if (cg_parse_array_ref(op, base, index)) {
        if (!cg_is_array_name(base)) {
            cg_add_array(base, 1, 0);
        }

        if (cg_is_identifier(index) && !cg_is_array_name(index)) {
            cg_add_name(noms, nb, index);
        }

        return;
    }

    if (cg_is_identifier(op) && !cg_is_array_name(op)) {
        cg_add_name(noms, nb, op);
    }
}

static void generer_data_segment(FILE *f) {
    int i;
    char noms[1000][50];
    int nb = 0;

    cg_collect_arrays_and_floats();

    for (i = 0; i < qc; i++) {
        if (qdr[i].supprime) continue;

        if (strcmp(qdr[i].op, "[]=") == 0) {
            cg_add_operand_to_data(noms, &nb, qdr[i].arg1);
            cg_add_operand_to_data(noms, &nb, qdr[i].arg2);
            continue;
        }

        cg_add_operand_to_data(noms, &nb, qdr[i].arg1);
        cg_add_operand_to_data(noms, &nb, qdr[i].arg2);
        cg_add_operand_to_data(noms, &nb, qdr[i].res);
    }

    fprintf(f, "DATA SEGMENT\n");

    for (i = 0; i < nb; i++) {
        if (cg_is_float_name(noms[i])) {
            fprintf(f, "    %s DW ?        ; FLOAT fixe x%d\n", noms[i], CG_SCALE);
        } else {
            fprintf(f, "    %s DW ?\n", noms[i]);
        }
    }

    for (i = 0; i < nb_arrays_asm; i++) {
        if (arrays_asm[i].is_float) {
            fprintf(f, "    %s DW %d DUP(?) ; TABLEAU FLOAT fixe x%d\n",
                    arrays_asm[i].nom, arrays_asm[i].taille, CG_SCALE);
        } else {
            fprintf(f, "    %s DW %d DUP(?)\n",
                    arrays_asm[i].nom, arrays_asm[i].taille);
        }
    }

    for (i = 0; i < nb_output_msgs; i++) {
        fprintf(f, "    %s DB '%s$'\n", output_msgs[i].label, output_msgs[i].text);
    }

    fprintf(f, "    msgDivZero DB 'Erreur : division par zero$'\n");
    fprintf(f, "    msgBounds  DB 'Erreur : indice hors limites$'\n");
    fprintf(f, "    newline    DB 13,10,'$'\n");

    fprintf(f, "DATA ENDS\n\n");
}

/* =========================================================
   Chargement / stockage
   ========================================================= */

static void cg_load_index_to_si(FILE *f, const char *index) {
    fprintf(f, "    MOV SI, %s\n", index);
    fprintf(f, "    SHL SI, 1\n");
}

static void cg_load_operand_to_reg(FILE *f, const char *operand, const char *reg) {
    char base[50], index[50];

    if (!operand || strcmp(operand, "-") == 0) {
        fprintf(f, "    MOV %s, 0\n", reg);
        return;
    }

    if (cg_is_float_literal(operand)) {
        fprintf(f, "    MOV %s, %d\n", reg, cg_float_to_fixed(operand));
        return;
    }

    if (cg_parse_array_ref(operand, base, index)) {
        cg_load_index_to_si(f, index);
        fprintf(f, "    MOV %s, %s[SI]\n", reg, base);
        return;
    }

    fprintf(f, "    MOV %s, %s\n", reg, operand);
}

static void cg_store_ax_to_dest(FILE *f, const char *dest) {
    char base[50], index[50];

    if (!dest || strcmp(dest, "-") == 0) return;

    if (cg_parse_array_ref(dest, base, index)) {
        cg_load_index_to_si(f, index);
        fprintf(f, "    MOV %s[SI], AX\n", base);
        return;
    }

    fprintf(f, "    MOV %s, AX\n", dest);
}

/* =========================================================
   Comparaisons
   ========================================================= */

static void generer_comparaison(FILE *f, int i) {
    cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
    cg_load_operand_to_reg(f, qdr[i].arg2, "BX");

    fprintf(f, "    CMP AX, BX\n");

    if (strcmp(qdr[i].op, ">") == 0) {
        fprintf(f, "    JG TRUE_%d\n", i);
    } else if (strcmp(qdr[i].op, "<") == 0) {
        fprintf(f, "    JL TRUE_%d\n", i);
    } else if (strcmp(qdr[i].op, ">=") == 0) {
        fprintf(f, "    JGE TRUE_%d\n", i);
    } else if (strcmp(qdr[i].op, "<=") == 0) {
        fprintf(f, "    JLE TRUE_%d\n", i);
    } else if (strcmp(qdr[i].op, "==") == 0) {
        fprintf(f, "    JE TRUE_%d\n", i);
    } else if (strcmp(qdr[i].op, "!=") == 0) {
        fprintf(f, "    JNE TRUE_%d\n", i);
    }

    fprintf(f, "    MOV %s, 0\n", qdr[i].res);
    fprintf(f, "    JMP END_CMP_%d\n", i);

    fprintf(f, "TRUE_%d:\n", i);
    fprintf(f, "    MOV %s, 1\n", qdr[i].res);

    fprintf(f, "END_CMP_%d:\n", i);
}

/* =========================================================
   OUTPUT
   ========================================================= */

static void cg_trim(char *s) {
    int start = 0;
    int end;
    int i;

    if (!s) return;

    while (s[start] && isspace((unsigned char)s[start])) start++;

    if (start > 0) {
        for (i = 0; s[start + i]; i++) {
            s[i] = s[start + i];
        }
        s[i] = '\0';
    }

    end = (int)strlen(s) - 1;

    while (end >= 0 && isspace((unsigned char)s[end])) {
        s[end] = '\0';
        end--;
    }
}

static void cg_emit_output_token(FILE *f, char *token) {
    char *label;

    cg_trim(token);

    if (token[0] == '\0') return;

    if (cg_is_string_token(token)) {
        label = cg_get_msg_label(token);
        fprintf(f, "    LEA DX, %s\n", label);
        fprintf(f, "    CALL PRINT_STRING\n");
    } else {
        cg_load_operand_to_reg(f, token, "AX");

        if (cg_is_float_name(token) || cg_is_float_literal(token)) {
            fprintf(f, "    CALL PRINT_FIXED\n");
        } else {
            fprintf(f, "    CALL PRINT_INT\n");
        }
    }
}

static void cg_emit_output(FILE *f, const char *args) {
    char buffer[300];
    char token[200];
    int i;
    int k = 0;
    int in_string = 0;

    snprintf(buffer, sizeof(buffer), "%s", args);

    for (i = 0; ; i++) {
        char ch = buffer[i];

        if (ch == '"') {
            in_string = !in_string;
        }

        if ((ch == ',' && !in_string) || ch == '\0') {
            token[k] = '\0';
            cg_emit_output_token(f, token);
            k = 0;

            if (ch == '\0') break;
        } else {
            if (k < (int)sizeof(token) - 1) {
                token[k++] = ch;
            }
        }
    }

    fprintf(f, "    CALL PRINT_NEWLINE\n");
}

/* =========================================================
   Procédures assembleur d'affichage
   ========================================================= */

static void cg_emit_runtime_procedures(FILE *f) {
    fprintf(f, "\n; =====================================================\n");
    fprintf(f, "; Procedures d'affichage\n");
    fprintf(f, "; =====================================================\n\n");

    fprintf(f, "PRINT_STRING PROC\n");
    fprintf(f, "    MOV AH, 09H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    RET\n");
    fprintf(f, "PRINT_STRING ENDP\n\n");

    fprintf(f, "PRINT_NEWLINE PROC\n");
    fprintf(f, "    LEA DX, newline\n");
    fprintf(f, "    MOV AH, 09H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    RET\n");
    fprintf(f, "PRINT_NEWLINE ENDP\n\n");

    fprintf(f, "PRINT_INT PROC\n");
    fprintf(f, "    PUSH AX\n");
    fprintf(f, "    PUSH BX\n");
    fprintf(f, "    PUSH CX\n");
    fprintf(f, "    PUSH DX\n");
    fprintf(f, "    CMP AX, 0\n");
    fprintf(f, "    JNE PI_NOT_ZERO\n");
    fprintf(f, "    MOV DL, '0'\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    JMP PI_DONE\n");
    fprintf(f, "PI_NOT_ZERO:\n");
    fprintf(f, "    CMP AX, 0\n");
    fprintf(f, "    JGE PI_POSITIVE\n");
    fprintf(f, "    MOV DL, '-'\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    NEG AX\n");
    fprintf(f, "PI_POSITIVE:\n");
    fprintf(f, "    MOV CX, 0\n");
    fprintf(f, "    MOV BX, 10\n");
    fprintf(f, "PI_DIV_LOOP:\n");
    fprintf(f, "    XOR DX, DX\n");
    fprintf(f, "    DIV BX\n");
    fprintf(f, "    PUSH DX\n");
    fprintf(f, "    INC CX\n");
    fprintf(f, "    CMP AX, 0\n");
    fprintf(f, "    JNE PI_DIV_LOOP\n");
    fprintf(f, "PI_PRINT_LOOP:\n");
    fprintf(f, "    POP DX\n");
    fprintf(f, "    ADD DL, '0'\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    LOOP PI_PRINT_LOOP\n");
    fprintf(f, "PI_DONE:\n");
    fprintf(f, "    POP DX\n");
    fprintf(f, "    POP CX\n");
    fprintf(f, "    POP BX\n");
    fprintf(f, "    POP AX\n");
    fprintf(f, "    RET\n");
    fprintf(f, "PRINT_INT ENDP\n\n");

    fprintf(f, "PRINT_FIXED PROC\n");
    fprintf(f, "    PUSH AX\n");
    fprintf(f, "    PUSH BX\n");
    fprintf(f, "    PUSH CX\n");
    fprintf(f, "    PUSH DX\n");
    fprintf(f, "    CMP AX, 0\n");
    fprintf(f, "    JGE PF_POSITIVE\n");
    fprintf(f, "    MOV DL, '-'\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    NEG AX\n");
    fprintf(f, "PF_POSITIVE:\n");
    fprintf(f, "    XOR DX, DX\n");
    fprintf(f, "    MOV BX, %d\n", CG_SCALE);
    fprintf(f, "    DIV BX\n");
    fprintf(f, "    PUSH DX\n");
    fprintf(f, "    CALL PRINT_INT\n");
    fprintf(f, "    MOV DL, '.'\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    POP AX\n");
    fprintf(f, "    XOR DX, DX\n");
    fprintf(f, "    MOV BX, 10\n");
    fprintf(f, "    DIV BX\n");
    fprintf(f, "    ADD AL, '0'\n");
    fprintf(f, "    MOV DL, AL\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    MOV AX, DX\n");
    fprintf(f, "    ADD AL, '0'\n");
    fprintf(f, "    MOV DL, AL\n");
    fprintf(f, "    MOV AH, 02H\n");
    fprintf(f, "    INT 21H\n");
    fprintf(f, "    POP DX\n");
    fprintf(f, "    POP CX\n");
    fprintf(f, "    POP BX\n");
    fprintf(f, "    POP AX\n");
    fprintf(f, "    RET\n");
    fprintf(f, "PRINT_FIXED ENDP\n\n");
}

/* =========================================================
   Génération principale
   ========================================================= */

void generer_code_objet(void) {
    FILE *f;
    int i;

    f = fopen("code.asm", "w");

    if (f == NULL) {
        printf("Erreur : impossible de creer le fichier code.asm\n");
        return;
    }

    fprintf(f, "; Code assembleur 8086 genere automatiquement\n");
    fprintf(f, "; A partir des quadruplets optimises\n");
    fprintf(f, "; Les FLOAT sont geres en virgule fixe avec facteur %d\n\n", CG_SCALE);

    generer_data_segment(f);

    fprintf(f, "CODE SEGMENT\n");
    fprintf(f, "ASSUME CS:CODE, DS:DATA\n\n");

    fprintf(f, "MAIN PROC\n");
    fprintf(f, "    MOV AX, DATA\n");
    fprintf(f, "    MOV DS, AX\n\n");

    for (i = 0; i < qc; i++) {
        fprintf(f, "L%d:\n", i);

        if (qdr[i].supprime) {
            fprintf(f, "    ; Quad %d supprime par optimisation\n\n", i);
            continue;
        }

        fprintf(f, "    ; Quad %d : (%s, %s, %s, %s)\n",
                i, qdr[i].op, qdr[i].arg1, qdr[i].arg2, qdr[i].res);

        if (strcmp(qdr[i].op, "=") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "+") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    ADD AX, BX\n");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "-") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    SUB AX, BX\n");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "*") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    IMUL BX\n");

            if (cg_quad_is_float(i)) {
                fprintf(f, "    MOV BX, %d\n", CG_SCALE);
                fprintf(f, "    IDIV BX\n");
            }

            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "/") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");

            if (cg_quad_is_float(i)) {
                fprintf(f, "    MOV BX, %d\n", CG_SCALE);
                fprintf(f, "    IMUL BX\n");
            } else {
                fprintf(f, "    CWD\n");
            }

            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    IDIV BX\n");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (
            strcmp(qdr[i].op, ">") == 0 ||
            strcmp(qdr[i].op, "<") == 0 ||
            strcmp(qdr[i].op, ">=") == 0 ||
            strcmp(qdr[i].op, "<=") == 0 ||
            strcmp(qdr[i].op, "==") == 0 ||
            strcmp(qdr[i].op, "!=") == 0
        ) {
            generer_comparaison(f, i);
        }

        else if (strcmp(qdr[i].op, "BZ") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            fprintf(f, "    CMP AX, 0\n");
            fprintf(f, "    JE L%s\n", qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "BR") == 0) {
            fprintf(f, "    JMP L%s\n", qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "AINC") == 0) {
            fprintf(f, "    INC %s\n", qdr[i].arg1);
        }

        else if (strcmp(qdr[i].op, "ADEC") == 0) {
            fprintf(f, "    DEC %s\n", qdr[i].arg1);
        }

        else if (strcmp(qdr[i].op, "AND") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    AND AX, BX\n");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "OR") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            cg_load_operand_to_reg(f, qdr[i].arg2, "BX");
            fprintf(f, "    OR AX, BX\n");
            cg_store_ax_to_dest(f, qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "NOT") == 0) {
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            fprintf(f, "    CMP AX, 0\n");
            fprintf(f, "    JE NOT_TRUE_%d\n", i);
            fprintf(f, "    MOV %s, 0\n", qdr[i].res);
            fprintf(f, "    JMP NOT_END_%d\n", i);
            fprintf(f, "NOT_TRUE_%d:\n", i);
            fprintf(f, "    MOV %s, 1\n", qdr[i].res);
            fprintf(f, "NOT_END_%d:\n", i);
        }

        else if (strcmp(qdr[i].op, "DIVCHECK") == 0) {
            cg_load_operand_to_reg(f, qdr[i].res, "AX");
            fprintf(f, "    CMP AX, 0\n");
            fprintf(f, "    JE ERREUR_DIV_ZERO\n");
        }

        else if (strcmp(qdr[i].op, "BOUNDS") == 0) {
            cg_load_operand_to_reg(f, qdr[i].res, "AX");
            fprintf(f, "    CMP AX, %s\n", qdr[i].arg1);
            fprintf(f, "    JL ERREUR_BOUNDS\n");
            fprintf(f, "    CMP AX, %s\n", qdr[i].arg2);
            fprintf(f, "    JGE ERREUR_BOUNDS\n");
        }

        else if (strcmp(qdr[i].op, "[]=") == 0) {
            cg_load_index_to_si(f, qdr[i].arg2);
            cg_load_operand_to_reg(f, qdr[i].arg1, "AX");
            fprintf(f, "    MOV %s[SI], AX\n", qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "INPUT") == 0) {
            fprintf(f, "    ; INPUT %s : non implemente\n", qdr[i].res);
        }

        else if (strcmp(qdr[i].op, "OUTPUT") == 0) {
            cg_emit_output(f, qdr[i].arg1);
        }

        else {
            fprintf(f, "    ; Operation non traduite : %s %s %s %s\n",
                    qdr[i].op, qdr[i].arg1, qdr[i].arg2, qdr[i].res);
        }

        fprintf(f, "\n");
    }

    fprintf(f, "FIN_PROGRAMME:\n");
    fprintf(f, "    MOV AH, 4CH\n");
    fprintf(f, "    INT 21H\n\n");

    fprintf(f, "ERREUR_DIV_ZERO:\n");
    fprintf(f, "    LEA DX, msgDivZero\n");
    fprintf(f, "    CALL PRINT_STRING\n");
    fprintf(f, "    CALL PRINT_NEWLINE\n");
    fprintf(f, "    JMP FIN_PROGRAMME\n\n");

    fprintf(f, "ERREUR_BOUNDS:\n");
    fprintf(f, "    LEA DX, msgBounds\n");
    fprintf(f, "    CALL PRINT_STRING\n");
    fprintf(f, "    CALL PRINT_NEWLINE\n");
    fprintf(f, "    JMP FIN_PROGRAMME\n\n");

    fprintf(f, "MAIN ENDP\n\n");

    cg_emit_runtime_procedures(f);

    fprintf(f, "CODE ENDS\n");
    fprintf(f, "END MAIN\n");

    fclose(f);

    printf("\nCode assembleur 8086 complet genere avec succes dans le fichier code.asm\n");
}
