; Code assembleur 8086 genere automatiquement
; A partir des quadruplets optimises
; Les FLOAT sont geres en virgule fixe avec facteur 100

DATA SEGMENT
    tmp1 DW ?
    tmp2 DW ?
    tmp3 DW ?
    tmp4 DW ?
    tmp5 DW ?
    resultat DW ?
    total DW ?
    score DW ?
    moyenne DW ?        ; FLOAT fixe x100
    ZERO DW ?
    ONE DW ?
    N DW ?
    LIM DW ?
    PI DW ?        ; FLOAT fixe x100
    x DW ?
    y DW ?
    z DW ?
    a DW ?
    b DW ?
    c DW ?
    d DW ?
    e DW ?
    f DW ?
    g DW ?
    p DW ?        ; FLOAT fixe x100
    q DW ?        ; FLOAT fixe x100
    r DW ?        ; FLOAT fixe x100
    s DW ?        ; FLOAT fixe x100
    t34 DW ?
    t48 DW ?        ; FLOAT fixe x100
    t59 DW ?
    t60 DW ?
    t61 DW ?
    t63 DW ?
    t64 DW ?
    t66 DW ?
    t68 DW ?
    t70 DW ?
    t72 DW ?
    t73 DW ?
    t74 DW ?
    t75 DW ?
    t78 DW ?
    t79 DW ?
    t80 DW ?
    t81 DW ?
    t84 DW ?
    t86 DW ?
    t87 DW ?
    t88 DW ?
    t89 DW ?
    t90 DW ?
    t93 DW ?
    t96 DW ?
    t99 DW ?
    t102 DW ?
    t106 DW ?
    t110 DW ?
    t114 DW ?
    t118 DW ?
    t122 DW ?
    t125 DW ?        ; FLOAT fixe x100
    t128 DW ?        ; FLOAT fixe x100
    t131 DW ?        ; FLOAT fixe x100
    c135 DW ?
    t136 DW ?
    c137 DW ?
    c138 DW ?
    c139 DW ?
    c140 DW ?
    c141 DW ?
    t151 DW ?
    t159 DW ?
    t163 DW ?
    i DW ?
    c167 DW ?
    t175 DW ?
    t179 DW ?
    t183 DW ?
    t186 DW ?
    t189 DW ?
    c196 DW ?
    j DW ?
    c199 DW ?
    t201 DW ?
    k DW ?
    t209 DW ?
    t211 DW ?
    t215 DW ?
    t221 DW ?
    c228 DW ?
    c229 DW ?
    c230 DW ?
    c231 DW ?
    t242 DW ?
    t243 DW ?
    t245 DW ?
    c249 DW ?
    c252 DW ?
    c253 DW ?
    c254 DW ?
    c255 DW ?
    t257 DW ?
    t265 DW ?
    t269 DW ?
    t273 DW ?
    t276 DW ?
    t279 DW ?
    t283 DW ?
    t286 DW ?
    t291 DW ?
    t293 DW ?
    t294 DW ?
    t295 DW ?
    t298 DW ?
    t299 DW ?
    t302 DW ?        ; FLOAT fixe x100
    t304 DW ?        ; FLOAT fixe x100
    t307 DW ?        ; FLOAT fixe x100
    Tab DW 30 DUP(?)
    Mat DW 20 DUP(?)
    Vec DW 20 DUP(?) ; TABLEAU FLOAT fixe x100
    msgOut0 DB 'Resultat = $'
    msgOut1 DB 'Total = $'
    msgOut2 DB 'Score = $'
    msgOut3 DB 'Moyenne = $'
    msgDivZero DB 'Erreur : division par zero$'
    msgBounds  DB 'Erreur : indice hors limites$'
    newline    DB 13,10,'$'
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

MAIN PROC
    MOV AX, DATA
    MOV DS, AX

L0:
    ; Quad 0 : (=, 0, -, tmp1)
    MOV AX, 0
    MOV tmp1, AX

L1:
    ; Quad 1 : (=, 0, -, tmp2)
    MOV AX, 0
    MOV tmp2, AX

L2:
    ; Quad 2 : (=, 0, -, tmp3)
    MOV AX, 0
    MOV tmp3, AX

L3:
    ; Quad 3 : (=, 0, -, tmp4)
    MOV AX, 0
    MOV tmp4, AX

L4:
    ; Quad 4 : (=, 0, -, tmp5)
    MOV AX, 0
    MOV tmp5, AX

L5:
    ; Quad 5 : (=, 0, -, resultat)
    MOV AX, 0
    MOV resultat, AX

L6:
    ; Quad 6 : (=, 0, -, total)
    MOV AX, 0
    MOV total, AX

L7:
    ; Quad 7 : (=, 0, -, score)
    MOV AX, 0
    MOV score, AX

L8:
    ; Quad 8 : (=, 0.000000, -, moyenne)
    MOV AX, 0
    MOV moyenne, AX

L9:
    ; Quad 9 : (=, 0, -, ZERO)
    MOV AX, 0
    MOV ZERO, AX

L10:
    ; Quad 10 : (=, 1, -, ONE)
    MOV AX, 1
    MOV ONE, AX

L11:
    ; Quad 11 : (=, 10, -, N)
    MOV AX, 10
    MOV N, AX

L12:
    ; Quad 12 : (=, 5, -, LIM)
    MOV AX, 5
    MOV LIM, AX

L13:
    ; Quad 13 : (=, 3.141590, -, PI)
    MOV AX, 314
    MOV PI, AX

L14:
    ; Quad 14 : (=, 10, -, x)
    MOV AX, 10
    MOV x, AX

L15:
    ; Quad 15 : (=, 5, -, y)
    MOV AX, 5
    MOV y, AX

L16:
    ; Quad 16 : (=, 0, -, z)
    MOV AX, 0
    MOV z, AX

L17:
    ; Quad 17 : (=, 3, -, a)
    MOV AX, 3
    MOV a, AX

L18:
    ; Quad 18 : (=, 4, -, b)
    MOV AX, 4
    MOV b, AX

L19:
    ; Quad 19 : (=, 0, -, c)
    MOV AX, 0
    MOV c, AX

L20:
    ; Quad 20 : (=, 1, -, d)
    MOV AX, 1
    MOV d, AX

L21:
    ; Quad 21 : (=, 8, -, e)
    MOV AX, 8
    MOV e, AX

L22:
    ; Quad 22 : (=, 2, -, f)
    MOV AX, 2
    MOV f, AX

L23:
    ; Quad 23 : (=, 6, -, g)
    MOV AX, 6
    MOV g, AX

L24:
    ; Quad 24 : (=, 2.500000, -, p)
    MOV AX, 250
    MOV p, AX

L25:
    ; Quad 25 : (=, 4.000000, -, q)
    MOV AX, 400
    MOV q, AX

L26:
    ; Quad 26 : (=, 0.000000, -, r)
    MOV AX, 0
    MOV r, AX

L27:
    ; Quad 27 : (=, 1.000000, -, s)
    MOV AX, 100
    MOV s, AX

L28:
    ; Quad 28 supprime par optimisation

L29:
    ; Quad 29 : (=, x, -, tmp1)
    MOV AX, x
    MOV tmp1, AX

L30:
    ; Quad 30 supprime par optimisation

L31:
    ; Quad 31 : (=, y, -, tmp2)
    MOV AX, y
    MOV tmp2, AX

L32:
    ; Quad 32 supprime par optimisation

L33:
    ; Quad 33 : (=, a, -, tmp3)
    MOV AX, a
    MOV tmp3, AX

L34:
    ; Quad 34 : (=, b, -, t34)
    MOV AX, b
    MOV t34, AX

L35:
    ; Quad 35 supprime par optimisation

L36:
    ; Quad 36 supprime par optimisation

L37:
    ; Quad 37 : (=, 0, -, tmp5)
    MOV AX, 0
    MOV tmp5, AX

L38:
    ; Quad 38 supprime par optimisation

L39:
    ; Quad 39 : (=, 0, -, resultat)
    MOV AX, 0
    MOV resultat, AX

L40:
    ; Quad 40 supprime par optimisation

L41:
    ; Quad 41 : (=, y, -, total)
    MOV AX, y
    MOV total, AX

L42:
    ; Quad 42 supprime par optimisation

L43:
    ; Quad 43 : (=, e, -, score)
    MOV AX, e
    MOV score, AX

L44:
    ; Quad 44 supprime par optimisation

L45:
    ; Quad 45 : (=, q, -, p)
    MOV AX, q
    MOV p, AX

L46:
    ; Quad 46 supprime par optimisation

L47:
    ; Quad 47 : (=, p, -, r)
    MOV AX, p
    MOV r, AX

L48:
    ; Quad 48 : (=, q, -, t48)
    MOV AX, q
    MOV t48, AX

L49:
    ; Quad 49 supprime par optimisation

L50:
    ; Quad 50 : (=, t48, -, s)
    MOV AX, t48
    MOV s, AX

L51:
    ; Quad 51 supprime par optimisation

L52:
    ; Quad 52 : (=, y, -, z)
    MOV AX, y
    MOV z, AX

L53:
    ; Quad 53 supprime par optimisation

L54:
    ; Quad 54 : (=, b, -, c)
    MOV AX, b
    MOV c, AX

L55:
    ; Quad 55 supprime par optimisation

L56:
    ; Quad 56 supprime par optimisation

L57:
    ; Quad 57 supprime par optimisation

L58:
    ; Quad 58 : (=, e, -, tmp4)
    MOV AX, e
    MOV tmp4, AX

L59:
    ; Quad 59 : (=, x, -, t59)
    MOV AX, x
    MOV t59, AX

L60:
    ; Quad 60 : (=, y, -, t60)
    MOV AX, y
    MOV t60, AX

L61:
    ; Quad 61 : (+, t59, t60, t61)
    MOV AX, t59
    MOV BX, t60
    ADD AX, BX
    MOV t61, AX

L62:
    ; Quad 62 : (=, t61, -, resultat)
    MOV AX, t61
    MOV resultat, AX

L63:
    ; Quad 63 : (=, a, -, t63)
    MOV AX, a
    MOV t63, AX

L64:
    ; Quad 64 : (=, b, -, t64)
    MOV AX, b
    MOV t64, AX

L65:
    ; Quad 65 supprime par optimisation

L66:
    ; Quad 66 : (*, t63, t64, t66)
    MOV AX, t63
    MOV BX, t64
    IMUL BX
    MOV t66, AX

L67:
    ; Quad 67 supprime par optimisation

L68:
    ; Quad 68 : (=, e, -, t68)
    MOV AX, e
    MOV t68, AX

L69:
    ; Quad 69 supprime par optimisation

L70:
    ; Quad 70 : (=, f, -, t70)
    MOV AX, f
    MOV t70, AX

L71:
    ; Quad 71 supprime par optimisation

L72:
    ; Quad 72 : (+, t68, t70, t72)
    MOV AX, t68
    MOV BX, t70
    ADD AX, BX
    MOV t72, AX

L73:
    ; Quad 73 : (=, x, -, t73)
    MOV AX, x
    MOV t73, AX

L74:
    ; Quad 74 : (=, y, -, t74)
    MOV AX, y
    MOV t74, AX

L75:
    ; Quad 75 : (+, t73, t74, t75)
    MOV AX, t73
    MOV BX, t74
    ADD AX, BX
    MOV t75, AX

L76:
    ; Quad 76 supprime par optimisation

L77:
    ; Quad 77 : (=, t75, -, tmp1)
    MOV AX, t75
    MOV tmp1, AX

L78:
    ; Quad 78 : (=, a, -, t78)
    MOV AX, a
    MOV t78, AX

L79:
    ; Quad 79 : (=, b, -, t79)
    MOV AX, b
    MOV t79, AX

L80:
    ; Quad 80 : (*, t78, t79, t80)
    MOV AX, t78
    MOV BX, t79
    IMUL BX
    MOV t80, AX

L81:
    ; Quad 81 : (=, 0, -, t81)
    MOV AX, 0
    MOV t81, AX

L82:
    ; Quad 82 supprime par optimisation

L83:
    ; Quad 83 : (=, t80, -, tmp2)
    MOV AX, t80
    MOV tmp2, AX

L84:
    ; Quad 84 : (=, e, -, t84)
    MOV AX, e
    MOV t84, AX

L85:
    ; Quad 85 supprime par optimisation

L86:
    ; Quad 86 : (=, 0, -, t86)
    MOV AX, 0
    MOV t86, AX

L87:
    ; Quad 87 : (=, t84, -, t87)
    MOV AX, t84
    MOV t87, AX

L88:
    ; Quad 88 : (=, g, -, t88)
    MOV AX, g
    MOV t88, AX

L89:
    ; Quad 89 : (+, t87, t88, t89)
    MOV AX, t87
    MOV BX, t88
    ADD AX, BX
    MOV t89, AX

L90:
    ; Quad 90 : (=, x, -, t90)
    MOV AX, x
    MOV t90, AX

L91:
    ; Quad 91 : (BOUNDS, 0, 30, 0)
    MOV AX, 0
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L92:
    ; Quad 92 : ([]=, t90, 0, Tab)
    MOV SI, 0
    SHL SI, 1
    MOV AX, t90
    MOV Tab[SI], AX

L93:
    ; Quad 93 : (=, y, -, t93)
    MOV AX, y
    MOV t93, AX

L94:
    ; Quad 94 : (BOUNDS, 0, 30, 1)
    MOV AX, 1
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L95:
    ; Quad 95 : ([]=, t93, 1, Tab)
    MOV SI, 1
    SHL SI, 1
    MOV AX, t93
    MOV Tab[SI], AX

L96:
    ; Quad 96 : (=, a, -, t96)
    MOV AX, a
    MOV t96, AX

L97:
    ; Quad 97 : (BOUNDS, 0, 30, 2)
    MOV AX, 2
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L98:
    ; Quad 98 : ([]=, t96, 2, Tab)
    MOV SI, 2
    SHL SI, 1
    MOV AX, t96
    MOV Tab[SI], AX

L99:
    ; Quad 99 : (=, b, -, t99)
    MOV AX, b
    MOV t99, AX

L100:
    ; Quad 100 supprime par optimisation

L101:
    ; Quad 101 : (BOUNDS, 0, 30, 3)
    MOV AX, 3
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L102:
    ; Quad 102 : (=, 0, -, t102)
    MOV AX, 0
    MOV t102, AX

L103:
    ; Quad 103 : (BOUNDS, 0, 30, 4)
    MOV AX, 4
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L104:
    ; Quad 104 : ([]=, 0, 4, Tab)
    MOV SI, 4
    SHL SI, 1
    MOV AX, 0
    MOV Tab[SI], AX

L105:
    ; Quad 105 : (BOUNDS, 0, 30, 0)
    MOV AX, 0
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L106:
    ; Quad 106 : (=, Tab[0], -, t106)
    MOV SI, 0
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t106, AX

L107:
    ; Quad 107 : (BOUNDS, 0, 20, 0)
    MOV AX, 0
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L108:
    ; Quad 108 : ([]=, t106, 0, Mat)
    MOV SI, 0
    SHL SI, 1
    MOV AX, t106
    MOV Mat[SI], AX

L109:
    ; Quad 109 : (BOUNDS, 0, 30, 1)
    MOV AX, 1
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L110:
    ; Quad 110 : (=, Tab[1], -, t110)
    MOV SI, 1
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t110, AX

L111:
    ; Quad 111 : (BOUNDS, 0, 20, 1)
    MOV AX, 1
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L112:
    ; Quad 112 : ([]=, t110, 1, Mat)
    MOV SI, 1
    SHL SI, 1
    MOV AX, t110
    MOV Mat[SI], AX

L113:
    ; Quad 113 : (BOUNDS, 0, 30, 2)
    MOV AX, 2
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L114:
    ; Quad 114 : (=, Tab[2], -, t114)
    MOV SI, 2
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t114, AX

L115:
    ; Quad 115 : (BOUNDS, 0, 20, 2)
    MOV AX, 2
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L116:
    ; Quad 116 : ([]=, t114, 2, Mat)
    MOV SI, 2
    SHL SI, 1
    MOV AX, t114
    MOV Mat[SI], AX

L117:
    ; Quad 117 : (BOUNDS, 0, 30, 3)
    MOV AX, 3
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L118:
    ; Quad 118 : (=, Tab[3], -, t118)
    MOV SI, 3
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t118, AX

L119:
    ; Quad 119 supprime par optimisation

L120:
    ; Quad 120 : (BOUNDS, 0, 20, 3)
    MOV AX, 3
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L121:
    ; Quad 121 : (BOUNDS, 0, 30, 4)
    MOV AX, 4
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L122:
    ; Quad 122 : (=, 0, -, t122)
    MOV AX, 0
    MOV t122, AX

L123:
    ; Quad 123 : (BOUNDS, 0, 20, 4)
    MOV AX, 4
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L124:
    ; Quad 124 : ([]=, 0, 4, Mat)
    MOV SI, 4
    SHL SI, 1
    MOV AX, 0
    MOV Mat[SI], AX

L125:
    ; Quad 125 : (=, p, -, t125)
    MOV AX, p
    MOV t125, AX

L126:
    ; Quad 126 : (BOUNDS, 0, 20, 0)
    MOV AX, 0
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L127:
    ; Quad 127 : ([]=, t125, 0, Vec)
    MOV SI, 0
    SHL SI, 1
    MOV AX, t125
    MOV Vec[SI], AX

L128:
    ; Quad 128 : (=, q, -, t128)
    MOV AX, q
    MOV t128, AX

L129:
    ; Quad 129 : (BOUNDS, 0, 20, 1)
    MOV AX, 1
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L130:
    ; Quad 130 : ([]=, t128, 1, Vec)
    MOV SI, 1
    SHL SI, 1
    MOV AX, t128
    MOV Vec[SI], AX

L131:
    ; Quad 131 : (=, r, -, t131)
    MOV AX, r
    MOV t131, AX

L132:
    ; Quad 132 supprime par optimisation

L133:
    ; Quad 133 : (BOUNDS, 0, 20, 2)
    MOV AX, 2
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L134:
    ; Quad 134 : ([]=, t131, 2, Vec)
    MOV SI, 2
    SHL SI, 1
    MOV AX, t131
    MOV Vec[SI], AX

L135:
    ; Quad 135 : (>, x, y, c135)
    MOV AX, x
    MOV BX, y
    CMP AX, BX
    JG TRUE_135
    MOV c135, 0
    JMP END_CMP_135
TRUE_135:
    MOV c135, 1
END_CMP_135:

L136:
    ; Quad 136 : (=, b, -, t136)
    MOV AX, b
    MOV t136, AX

L137:
    ; Quad 137 : (<, a, t136, c137)
    MOV AX, a
    MOV BX, t136
    CMP AX, BX
    JL TRUE_137
    MOV c137, 0
    JMP END_CMP_137
TRUE_137:
    MOV c137, 1
END_CMP_137:

L138:
    ; Quad 138 : (AND, c135, c137, c138)
    MOV AX, c135
    MOV BX, c137
    AND AX, BX
    MOV c138, AX

L139:
    ; Quad 139 : (==, z, 0, c139)
    MOV AX, z
    MOV BX, 0
    CMP AX, BX
    JE TRUE_139
    MOV c139, 0
    JMP END_CMP_139
TRUE_139:
    MOV c139, 1
END_CMP_139:

L140:
    ; Quad 140 : (NOT, c139, -, c140)
    MOV AX, c139
    CMP AX, 0
    JE NOT_TRUE_140
    MOV c140, 0
    JMP NOT_END_140
NOT_TRUE_140:
    MOV c140, 1
NOT_END_140:

L141:
    ; Quad 141 : (OR, c138, c140, c141)
    MOV AX, c138
    MOV BX, c140
    OR AX, BX
    MOV c141, AX

L142:
    ; Quad 142 : (BZ, c141, -, 155)
    MOV AX, c141
    CMP AX, 0
    JE L155

L143:
    ; Quad 143 supprime par optimisation

L144:
    ; Quad 144 supprime par optimisation

L145:
    ; Quad 145 supprime par optimisation

L146:
    ; Quad 146 supprime par optimisation

L147:
    ; Quad 147 supprime par optimisation

L148:
    ; Quad 148 supprime par optimisation

L149:
    ; Quad 149 supprime par optimisation

L150:
    ; Quad 150 supprime par optimisation

L151:
    ; Quad 151 : (=, resultat, -, t151)
    MOV AX, resultat
    MOV t151, AX

L152:
    ; Quad 152 : (BOUNDS, 0, 30, 5)
    MOV AX, 5
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L153:
    ; Quad 153 : ([]=, t151, 5, Tab)
    MOV SI, 5
    SHL SI, 1
    MOV AX, t151
    MOV Tab[SI], AX

L154:
    ; Quad 154 : (BR, -, -, 166)
    JMP L166

L155:
    ; Quad 155 supprime par optimisation

L156:
    ; Quad 156 : (=, 0, -, resultat)
    MOV AX, 0
    MOV resultat, AX

L157:
    ; Quad 157 supprime par optimisation

L158:
    ; Quad 158 supprime par optimisation

L159:
    ; Quad 159 : (=, score, -, t159)
    MOV AX, score
    MOV t159, AX

L160:
    ; Quad 160 supprime par optimisation

L161:
    ; Quad 161 supprime par optimisation

L162:
    ; Quad 162 supprime par optimisation

L163:
    ; Quad 163 : (=, total, -, t163)
    MOV AX, total
    MOV t163, AX

L164:
    ; Quad 164 : (BOUNDS, 0, 30, 6)
    MOV AX, 6
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L165:
    ; Quad 165 : ([]=, t163, 6, Tab)
    MOV SI, 6
    SHL SI, 1
    MOV AX, t163
    MOV Tab[SI], AX

L166:
    ; Quad 166 : (=, 0, -, i)
    MOV AX, 0
    MOV i, AX

L167:
    ; Quad 167 : (<=, i, 5, c167)
    MOV AX, i
    MOV BX, 5
    CMP AX, BX
    JLE TRUE_167
    MOV c167, 0
    JMP END_CMP_167
TRUE_167:
    MOV c167, 1
END_CMP_167:

L168:
    ; Quad 168 : (BZ, c167, -, 195)
    MOV AX, c167
    CMP AX, 0
    JE L195

L169:
    ; Quad 169 supprime par optimisation

L170:
    ; Quad 170 : (=, i, -, tmp1)
    MOV AX, i
    MOV tmp1, AX

L171:
    ; Quad 171 supprime par optimisation

L172:
    ; Quad 172 : (=, tmp1, -, tmp2)
    MOV AX, tmp1
    MOV tmp2, AX

L173:
    ; Quad 173 supprime par optimisation

L174:
    ; Quad 174 supprime par optimisation

L175:
    ; Quad 175 : (=, tmp2, -, t175)
    MOV AX, tmp2
    MOV t175, AX

L176:
    ; Quad 176 supprime par optimisation

L177:
    ; Quad 177 supprime par optimisation

L178:
    ; Quad 178 : (=, 0, -, tmp5)
    MOV AX, 0
    MOV tmp5, AX

L179:
    ; Quad 179 : (=, tmp4, -, t179)
    MOV AX, tmp4
    MOV t179, AX

L180:
    ; Quad 180 : (BOUNDS, 0, 30, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L181:
    ; Quad 181 : ([]=, t179, i, Tab)
    MOV SI, i
    SHL SI, 1
    MOV AX, t179
    MOV Tab[SI], AX

L182:
    ; Quad 182 : (BOUNDS, 0, 30, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L183:
    ; Quad 183 : (=, Tab[i], -, t183)
    MOV SI, i
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t183, AX

L184:
    ; Quad 184 : (BOUNDS, 0, 20, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L185:
    ; Quad 185 : ([]=, t183, i, Mat)
    MOV SI, i
    SHL SI, 1
    MOV AX, t183
    MOV Mat[SI], AX

L186:
    ; Quad 186 : (+, resultat, tmp5, t186)
    MOV AX, resultat
    MOV BX, tmp5
    ADD AX, BX
    MOV t186, AX

L187:
    ; Quad 187 : (=, t186, -, resultat)
    MOV AX, t186
    MOV resultat, AX

L188:
    ; Quad 188 : (BOUNDS, 0, 30, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L189:
    ; Quad 189 : (+, total, Tab[i], t189)
    MOV AX, total
    MOV SI, i
    SHL SI, 1
    MOV BX, Tab[SI]
    ADD AX, BX
    MOV t189, AX

L190:
    ; Quad 190 : (=, t189, -, total)
    MOV AX, t189
    MOV total, AX

L191:
    ; Quad 191 supprime par optimisation

L192:
    ; Quad 192 : (=, tmp4, -, b)
    MOV AX, tmp4
    MOV b, AX

L193:
    ; Quad 193 : (AINC, i, -, -)
    INC i

L194:
    ; Quad 194 : (BR, -, -, 167)
    JMP L167

L195:
    ; Quad 195 : (=, 0, -, i)
    MOV AX, 0
    MOV i, AX

L196:
    ; Quad 196 : (<=, i, 3, c196)
    MOV AX, i
    MOV BX, 3
    CMP AX, BX
    JLE TRUE_196
    MOV c196, 0
    JMP END_CMP_196
TRUE_196:
    MOV c196, 1
END_CMP_196:

L197:
    ; Quad 197 : (BZ, c196, -, 227)
    MOV AX, c196
    CMP AX, 0
    JE L227

L198:
    ; Quad 198 : (=, 0, -, j)
    MOV AX, 0
    MOV j, AX

L199:
    ; Quad 199 : (<=, j, 2, c199)
    MOV AX, j
    MOV BX, 2
    CMP AX, BX
    JLE TRUE_199
    MOV c199, 0
    JMP END_CMP_199
TRUE_199:
    MOV c199, 1
END_CMP_199:

L200:
    ; Quad 200 : (BZ, c199, -, 225)
    MOV AX, c199
    CMP AX, 0
    JE L225

L201:
    ; Quad 201 : (+, i, j, t201)
    MOV AX, i
    MOV BX, j
    ADD AX, BX
    MOV t201, AX

L202:
    ; Quad 202 : (=, t201, -, k)
    MOV AX, t201
    MOV k, AX

L203:
    ; Quad 203 supprime par optimisation

L204:
    ; Quad 204 : (=, k, -, tmp1)
    MOV AX, k
    MOV tmp1, AX

L205:
    ; Quad 205 supprime par optimisation

L206:
    ; Quad 206 : (=, tmp1, -, tmp2)
    MOV AX, tmp1
    MOV tmp2, AX

L207:
    ; Quad 207 supprime par optimisation

L208:
    ; Quad 208 supprime par optimisation

L209:
    ; Quad 209 : (=, tmp2, -, t209)
    MOV AX, tmp2
    MOV t209, AX

L210:
    ; Quad 210 supprime par optimisation

L211:
    ; Quad 211 : (=, tmp4, -, t211)
    MOV AX, tmp4
    MOV t211, AX

L212:
    ; Quad 212 : (BOUNDS, 0, 20, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L213:
    ; Quad 213 : ([]=, t211, k, Mat)
    MOV SI, k
    SHL SI, 1
    MOV AX, t211
    MOV Mat[SI], AX

L214:
    ; Quad 214 : (BOUNDS, 0, 20, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L215:
    ; Quad 215 : (=, Mat[k], -, t215)
    MOV SI, k
    SHL SI, 1
    MOV AX, Mat[SI]
    MOV t215, AX

L216:
    ; Quad 216 : (BOUNDS, 0, 30, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L217:
    ; Quad 217 : ([]=, t215, k, Tab)
    MOV SI, k
    SHL SI, 1
    MOV AX, t215
    MOV Tab[SI], AX

L218:
    ; Quad 218 : (BOUNDS, 0, 30, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L219:
    ; Quad 219 supprime par optimisation

L220:
    ; Quad 220 : (=, Tab[k], -, d)
    MOV SI, k
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV d, AX

L221:
    ; Quad 221 : (+, score, d, t221)
    MOV AX, score
    MOV BX, d
    ADD AX, BX
    MOV t221, AX

L222:
    ; Quad 222 : (=, t221, -, score)
    MOV AX, t221
    MOV score, AX

L223:
    ; Quad 223 : (AINC, j, -, -)
    INC j

L224:
    ; Quad 224 : (BR, -, -, 199)
    JMP L199

L225:
    ; Quad 225 : (AINC, i, -, -)
    INC i

L226:
    ; Quad 226 : (BR, -, -, 196)
    JMP L196

L227:
    ; Quad 227 : (=, 0, -, i)
    MOV AX, 0
    MOV i, AX

L228:
    ; Quad 228 : (<, i, LIM, c228)
    MOV AX, i
    MOV BX, LIM
    CMP AX, BX
    JL TRUE_228
    MOV c228, 0
    JMP END_CMP_228
TRUE_228:
    MOV c228, 1
END_CMP_228:

L229:
    ; Quad 229 : (==, i, N, c229)
    MOV AX, i
    MOV BX, N
    CMP AX, BX
    JE TRUE_229
    MOV c229, 0
    JMP END_CMP_229
TRUE_229:
    MOV c229, 1
END_CMP_229:

L230:
    ; Quad 230 : (NOT, c229, -, c230)
    MOV AX, c229
    CMP AX, 0
    JE NOT_TRUE_230
    MOV c230, 0
    JMP NOT_END_230
NOT_TRUE_230:
    MOV c230, 1
NOT_END_230:

L231:
    ; Quad 231 : (AND, c228, c230, c231)
    MOV AX, c228
    MOV BX, c230
    AND AX, BX
    MOV c231, AX

L232:
    ; Quad 232 : (BZ, c231, -, 248)
    MOV AX, c231
    CMP AX, 0
    JE L248

L233:
    ; Quad 233 supprime par optimisation

L234:
    ; Quad 234 : (=, i, -, tmp1)
    MOV AX, i
    MOV tmp1, AX

L235:
    ; Quad 235 supprime par optimisation

L236:
    ; Quad 236 : (=, tmp1, -, tmp2)
    MOV AX, tmp1
    MOV tmp2, AX

L237:
    ; Quad 237 supprime par optimisation

L238:
    ; Quad 238 : (=, tmp2, -, tmp3)
    MOV AX, tmp2
    MOV tmp3, AX

L239:
    ; Quad 239 : (BOUNDS, 0, 30, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L240:
    ; Quad 240 : ([]=, tmp3, i, Tab)
    MOV SI, i
    SHL SI, 1
    MOV AX, tmp3
    MOV Tab[SI], AX

L241:
    ; Quad 241 : (BOUNDS, 0, 30, i)
    MOV AX, i
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L242:
    ; Quad 242 : (=, Tab[i], -, t242)
    MOV SI, i
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t242, AX

L243:
    ; Quad 243 : (+, resultat, t242, t243)
    MOV AX, resultat
    MOV BX, t242
    ADD AX, BX
    MOV t243, AX

L244:
    ; Quad 244 : (=, t243, -, resultat)
    MOV AX, t243
    MOV resultat, AX

L245:
    ; Quad 245 : (+, i, 1, t245)
    MOV AX, i
    MOV BX, 1
    ADD AX, BX
    MOV t245, AX

L246:
    ; Quad 246 : (=, t245, -, i)
    MOV AX, t245
    MOV i, AX

L247:
    ; Quad 247 : (BR, -, -, 228)
    JMP L228

L248:
    ; Quad 248 : (=, 0, -, i)
    MOV AX, 0
    MOV i, AX

L249:
    ; Quad 249 : (<, i, 3, c249)
    MOV AX, i
    MOV BX, 3
    CMP AX, BX
    JL TRUE_249
    MOV c249, 0
    JMP END_CMP_249
TRUE_249:
    MOV c249, 1
END_CMP_249:

L250:
    ; Quad 250 : (BZ, c249, -, 289)
    MOV AX, c249
    CMP AX, 0
    JE L289

L251:
    ; Quad 251 : (=, 0, -, j)
    MOV AX, 0
    MOV j, AX

L252:
    ; Quad 252 : (<, j, 4, c252)
    MOV AX, j
    MOV BX, 4
    CMP AX, BX
    JL TRUE_252
    MOV c252, 0
    JMP END_CMP_252
TRUE_252:
    MOV c252, 1
END_CMP_252:

L253:
    ; Quad 253 : (==, i, j, c253)
    MOV AX, i
    MOV BX, j
    CMP AX, BX
    JE TRUE_253
    MOV c253, 0
    JMP END_CMP_253
TRUE_253:
    MOV c253, 1
END_CMP_253:

L254:
    ; Quad 254 : (NOT, c253, -, c254)
    MOV AX, c253
    CMP AX, 0
    JE NOT_TRUE_254
    MOV c254, 0
    JMP NOT_END_254
NOT_TRUE_254:
    MOV c254, 1
NOT_END_254:

L255:
    ; Quad 255 : (AND, c252, c254, c255)
    MOV AX, c252
    MOV BX, c254
    AND AX, BX
    MOV c255, AX

L256:
    ; Quad 256 : (BZ, c255, -, 286)
    MOV AX, c255
    CMP AX, 0
    JE L286

L257:
    ; Quad 257 : (+, i, j, t257)
    MOV AX, i
    MOV BX, j
    ADD AX, BX
    MOV t257, AX

L258:
    ; Quad 258 : (=, t257, -, k)
    MOV AX, t257
    MOV k, AX

L259:
    ; Quad 259 supprime par optimisation

L260:
    ; Quad 260 : (=, k, -, tmp1)
    MOV AX, k
    MOV tmp1, AX

L261:
    ; Quad 261 supprime par optimisation

L262:
    ; Quad 262 : (=, tmp1, -, tmp2)
    MOV AX, tmp1
    MOV tmp2, AX

L263:
    ; Quad 263 supprime par optimisation

L264:
    ; Quad 264 supprime par optimisation

L265:
    ; Quad 265 : (=, tmp2, -, t265)
    MOV AX, tmp2
    MOV t265, AX

L266:
    ; Quad 266 supprime par optimisation

L267:
    ; Quad 267 supprime par optimisation

L268:
    ; Quad 268 : (=, 0, -, tmp5)
    MOV AX, 0
    MOV tmp5, AX

L269:
    ; Quad 269 : (=, tmp4, -, t269)
    MOV AX, tmp4
    MOV t269, AX

L270:
    ; Quad 270 : (BOUNDS, 0, 30, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L271:
    ; Quad 271 : ([]=, t269, k, Tab)
    MOV SI, k
    SHL SI, 1
    MOV AX, t269
    MOV Tab[SI], AX

L272:
    ; Quad 272 : (BOUNDS, 0, 30, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 30
    JGE ERREUR_BOUNDS

L273:
    ; Quad 273 : (=, Tab[k], -, t273)
    MOV SI, k
    SHL SI, 1
    MOV AX, Tab[SI]
    MOV t273, AX

L274:
    ; Quad 274 : (BOUNDS, 0, 20, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L275:
    ; Quad 275 : ([]=, t273, k, Mat)
    MOV SI, k
    SHL SI, 1
    MOV AX, t273
    MOV Mat[SI], AX

L276:
    ; Quad 276 : (+, total, tmp5, t276)
    MOV AX, total
    MOV BX, tmp5
    ADD AX, BX
    MOV t276, AX

L277:
    ; Quad 277 : (=, t276, -, total)
    MOV AX, t276
    MOV total, AX

L278:
    ; Quad 278 : (BOUNDS, 0, 20, k)
    MOV AX, k
    CMP AX, 0
    JL ERREUR_BOUNDS
    CMP AX, 20
    JGE ERREUR_BOUNDS

L279:
    ; Quad 279 : (+, score, Mat[k], t279)
    MOV AX, score
    MOV SI, k
    SHL SI, 1
    MOV BX, Mat[SI]
    ADD AX, BX
    MOV t279, AX

L280:
    ; Quad 280 supprime par optimisation

L281:
    ; Quad 281 supprime par optimisation

L282:
    ; Quad 282 : (=, t279, -, b)
    MOV AX, t279
    MOV b, AX

L283:
    ; Quad 283 : (+, j, 1, t283)
    MOV AX, j
    MOV BX, 1
    ADD AX, BX
    MOV t283, AX

L284:
    ; Quad 284 : (=, t283, -, j)
    MOV AX, t283
    MOV j, AX

L285:
    ; Quad 285 : (BR, -, -, 252)
    JMP L252

L286:
    ; Quad 286 : (+, i, 1, t286)
    MOV AX, i
    MOV BX, 1
    ADD AX, BX
    MOV t286, AX

L287:
    ; Quad 287 : (=, t286, -, i)
    MOV AX, t286
    MOV i, AX

L288:
    ; Quad 288 : (BR, -, -, 249)
    JMP L249

L289:
    ; Quad 289 supprime par optimisation

L290:
    ; Quad 290 supprime par optimisation

L291:
    ; Quad 291 : (=, resultat, -, t291)
    MOV AX, resultat
    MOV t291, AX

L292:
    ; Quad 292 supprime par optimisation

L293:
    ; Quad 293 : (=, total, -, t293)
    MOV AX, total
    MOV t293, AX

L294:
    ; Quad 294 : (=, 0, -, t294)
    MOV AX, 0
    MOV t294, AX

L295:
    ; Quad 295 : (=, t293, -, t295)
    MOV AX, t293
    MOV t295, AX

L296:
    ; Quad 296 supprime par optimisation

L297:
    ; Quad 297 : (=, t295, -, total)
    MOV AX, t295
    MOV total, AX

L298:
    ; Quad 298 : (+, score, resultat, t298)
    MOV AX, score
    MOV BX, resultat
    ADD AX, BX
    MOV t298, AX

L299:
    ; Quad 299 : (=, t298, -, t299)
    MOV AX, t298
    MOV t299, AX

L300:
    ; Quad 300 supprime par optimisation

L301:
    ; Quad 301 : (=, t299, -, score)
    MOV AX, t299
    MOV score, AX

L302:
    ; Quad 302 : (+, p, q, t302)
    MOV AX, p
    MOV BX, q
    ADD AX, BX
    MOV t302, AX

L303:
    ; Quad 303 supprime par optimisation

L304:
    ; Quad 304 : (=, t302, -, t304)
    MOV AX, t302
    MOV t304, AX

L305:
    ; Quad 305 supprime par optimisation

L306:
    ; Quad 306 : (=, t304, -, moyenne)
    MOV AX, t304
    MOV moyenne, AX

L307:
    ; Quad 307 : (/, moyenne, 2.000000, t307)
    MOV AX, moyenne
    MOV BX, 100
    IMUL BX
    MOV BX, 200
    IDIV BX
    MOV t307, AX

L308:
    ; Quad 308 supprime par optimisation

L309:
    ; Quad 309 : (=, t307, -, moyenne)
    MOV AX, t307
    MOV moyenne, AX

L310:
    ; Quad 310 : (OUTPUT, "Resultat = ",resultat, -, -)
    LEA DX, msgOut0
    CALL PRINT_STRING
    MOV AX, resultat
    CALL PRINT_INT
    CALL PRINT_NEWLINE

L311:
    ; Quad 311 : (OUTPUT, "Total = ",total, -, -)
    LEA DX, msgOut1
    CALL PRINT_STRING
    MOV AX, total
    CALL PRINT_INT
    CALL PRINT_NEWLINE

L312:
    ; Quad 312 : (OUTPUT, "Score = ",score, -, -)
    LEA DX, msgOut2
    CALL PRINT_STRING
    MOV AX, score
    CALL PRINT_INT
    CALL PRINT_NEWLINE

L313:
    ; Quad 313 : (OUTPUT, "Moyenne = ",moyenne, -, -)
    LEA DX, msgOut3
    CALL PRINT_STRING
    MOV AX, moyenne
    CALL PRINT_FIXED
    CALL PRINT_NEWLINE

FIN_PROGRAMME:
    MOV AH, 4CH
    INT 21H

ERREUR_DIV_ZERO:
    LEA DX, msgDivZero
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP FIN_PROGRAMME

ERREUR_BOUNDS:
    LEA DX, msgBounds
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP FIN_PROGRAMME

MAIN ENDP


; =====================================================
; Procedures d'affichage
; =====================================================

PRINT_STRING PROC
    MOV AH, 09H
    INT 21H
    RET
PRINT_STRING ENDP

PRINT_NEWLINE PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    RET
PRINT_NEWLINE ENDP

PRINT_INT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CMP AX, 0
    JNE PI_NOT_ZERO
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP PI_DONE
PI_NOT_ZERO:
    CMP AX, 0
    JGE PI_POSITIVE
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    NEG AX
PI_POSITIVE:
    MOV CX, 0
    MOV BX, 10
PI_DIV_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PI_DIV_LOOP
PI_PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PI_PRINT_LOOP
PI_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_INT ENDP

PRINT_FIXED PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CMP AX, 0
    JGE PF_POSITIVE
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    NEG AX
PF_POSITIVE:
    XOR DX, DX
    MOV BX, 100
    DIV BX
    PUSH DX
    CALL PRINT_INT
    MOV DL, '.'
    MOV AH, 02H
    INT 21H
    POP AX
    XOR DX, DX
    MOV BX, 10
    DIV BX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    MOV AX, DX
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_FIXED ENDP

CODE ENDS
END MAIN
