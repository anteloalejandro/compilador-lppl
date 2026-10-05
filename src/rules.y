%{
  #include "header.h"
  extern int yylineno
%}

%token MAS_ MENOS_ POR_ DIV_ PARA_ PARC_ CTE_  
%token CORA_ CORC_ ASIG_ IDEN_ // para expreXXX

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

// BORRAR. Son definiciones temporales para que compilen las reglas
paramAct: ;
const: ;
opMul: ;
opRel: ;
opIgual: ;
opUna: ;
opLogic: ;
opAd: ;
%%
