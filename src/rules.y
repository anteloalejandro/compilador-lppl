%{
  #include "header.h"
  extern int yylineno;
%}

%token MAS_ MENOS_ POR_ DIV_ PARA_ PARC_ CTE_
%token CORA_ CORC_ ASIG_ IDEN_ // para expreXXX
%token NOT_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ IGUAL_ DESIGUAL_ 
%token AND_ OR_ EPSILON_ 

%%
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
            | expre, listParamAct
            ;

// BORRAR. Son definiciones temporales para que compilen las reglas
paramAct: ;
const: ;
%%
