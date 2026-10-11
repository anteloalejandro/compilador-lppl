%{
  #include "header.h"
  extern int yylineno;
%}

%token MAS_ MENOS_ POR_ DIV_ PARA_ PARC_ CTE_
%token CORA_ CORC_ ASIG_ IDEN_ LLAVA_ LLAVC_// para expreXXX
%token NOT_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ IGUAL_ DESIGUAL_ GREATER_ EQUAL_ LESS_
%token AND_ OR_ EPSILON_ PUNTCOMA_
%token FOR_ IF_ ELSE_ READ_ PRINT_ SWITCH_
%token COMA_ 

%%

listInst: EPSILON_
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

expreOP: EPSILON_
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

listParamAct: expre
            | expre COMA_ listParamAct
            ;

// BORRAR. Son definiciones temporales para que compilen las reglas
paramAct: ;
const: ;
%%
