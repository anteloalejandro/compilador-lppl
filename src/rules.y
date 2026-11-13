%{
  #include "header.h"
  #include "libtds.h"
  #include "helpers.h"
  extern int yylineno;
%}

%union {
  int cte;
  unsigned int tipo;
  char *iden;
}

// CONSTANTES
%token <cte> FALSE_ TRUE_
%token INT_ BOOL_

// OPERADORES ARITMÉTICOS
%token MAS_ MENOS_ POR_ DIV_

// OPERADORES LÓGICOS
%token MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ IGUAL_ DESIGUAL_
%token NOT_ AND_ OR_

// OTROS OPERADORES
%token ASIG_

// PARÉNTESIS
%token PARA_ PARC_
// CORCHETES
%token CORA_ CORC_
// LLAVES
%token LLAVA_ LLAVC_

// ESTRUCTURAS DE CONTROL
%token FOR_ IF_ ELSE_ RETURN_

// SWITCH
%token SWITCH_ GREATER_ EQUAL_ LESS_

// FUNCIONES BUILT-IN
%token READ_ PRINT_ 

// TOKENS MISCELÁNEOS
%token <iden> IDEN_
%token <cte> CTE_
%token PUNTCOMA_ COMA_ 

%type <cte> const

%type <tipo> tipoSimp

%%
programa: listDecla {
            if (verTdS) mostrarTdS();

            SIMB s = obtTdS("main");
            if (s.t == T_ERROR) {
              yyerror("NO HAY UNA FUNCIÓN `main`");
            }
          }
        ;

listDecla: decla
         | listDecla decla
         ;

decla: declaVar
     | declaFunc
     ;

const: CTE_ { $$ = (int)$1; }
     | TRUE_ { $$ = $1; }
     | FALSE_ { $$ = $1; }
     ;

tipoSimp: BOOL_ { $$ = T_LOGICO; }
        | INT_ { $$ = T_ENTERO; }
        ;

declaVar: tipoSimp IDEN_ PUNTCOMA_
        {
          if (insTdS($2, VARIABLE, $1, niv, dvar, REF_SIMPLE)) {
            dvar += TALLA_TIPO_SIMPLE;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        | tipoSimp IDEN_ ASIG_ const PUNTCOMA_
        {
          if (insTdS($2, VARIABLE, $1, niv, dvar, REF_SIMPLE)) {
            dvar += TALLA_TIPO_SIMPLE;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        | tipoSimp IDEN_ CORA_ CTE_ CORC_ PUNTCOMA_
        {
          int elems = $4;
          if (elems == 0) {
            yyerror("La talla del array debe ser superior a 0");
            elems = 0;
          }

          // reserva espacio para los elementos dado su tipo.
          int ref = insTdA($1, elems);

          if (insTdS($2, VARIABLE, $1, niv, dvar, ref)) {
            dvar += TALLA_TIPO_SIMPLE * elems;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        ;

declaVarLocal: 
             | declaVarLocal declaVar
             ;

listParamForm: tipoSimp IDEN_
             | tipoSimp IDEN_ COMA_ listParamForm
             ;

paramForm:
         | listParamForm
         ;

bloque: LLAVA_ declaVarLocal listInst RETURN_ expre PUNTCOMA_ LLAVC_
      ;

declaFunc: tipoSimp IDEN_ PARA_ paramForm PARC_ bloque 
         ;

listInst:
        | listInst inst
        ;

inst: LLAVA_ listInst LLAVC_
    | instExpre
    | instEntSal
    | instSelec
    | instIter
    | instSwitch
    ;

instSwitch: SWITCH_ IDEN_ LLAVA_ Less Equal Greater LLAVC_
          ;

Less: LESS_ inst
    ;

Equal: EQUAL_ inst
     ;

Greater: GREATER_ inst
       ;

instExpre: expre PUNTCOMA_
         | PUNTCOMA_
         ;

instEntSal: READ_ PARA_ IDEN_ PARC_ PUNTCOMA_
          | PRINT_ PARA_ expre PARC_ PUNTCOMA_
          ;

instSelec: IF_ PARA_ expre PARC_ inst ELSE_ inst
         ;

instIter: FOR_ PARA_ expreOP PUNTCOMA_ expre PUNTCOMA_ expreOP PARC_ inst
        ;

expreOP:
       | expre
       ;

expre: expreLogic
     | IDEN_ ASIG_ expre
     | IDEN_ CORA_ expre CORC_ ASIG_ expre
     ;

expreLogic: expreIgual
          | expreLogic opLogic expreIgual
          ;

expreIgual: expreRel
          | expreIgual opIgual expreRel
          ;

expreRel: expreAd
        | expreRel opRel expreAd
        ;

expreAd: expreMul
       | expreAd opAd expreMul
       ;

expreMul: expreUna
        | expreMul opMul expreUna
        ;

expreUna: expreSufi
        | opUna expreUna
        ;

expreSufi: const
         | PARA_ expre PARC_
         | IDEN_
         | IDEN_ CORA_ expre CORC_
         | IDEN_ PARA_ paramAct PARC_
         ;

listParamAct: expre
            | expre COMA_ listParamAct
            ;

paramAct:
        | listParamAct
        ;

opUna: MAS_
     | MENOS_
     | NOT_
     ;

opMul: POR_
     | DIV_
     ;
opAd: MAS_
    | MENOS_
    ;

opRel: MAYOR_
     | MENOR_
     | MAYORIGUAL_
     | MENORIGUAL_
     ;

opIgual: IGUAL_
       | DESIGUAL_
       ;

opLogic: AND_
       | OR_
       ;
%%
