%{
  #include "header.h"
  extern int yylineno;
%}

// CONSTANTES
%token FALSE_ TRUE_ INT_ BOOL_

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
%token CTE_ IDEN_
%token PUNTCOMA_ COMA_ 

%%
programa: listDecla
        ;

listDecla: decla
         | listDecla decla
         ;

decla: declaVar
     | declaFunc
     ;

const: CTE_
     | TRUE_
     | FALSE_
     ;

tipoSimp: BOOL_
        | INT_
        ;

declaVar: tipoSimp IDEN_ PUNTCOMA_
        | tipoSimp IDEN_ ASIG_ const PUNTCOMA_
        | tipoSimp IDEN_ CORA_ CTE_ CORC_ PUNTCOMA_
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
