%{
  #include "header.h"
  extern int yylineno
%}

%token MAS_ MENOS_ POR_ DIV_ PARA_ PARC_ CTE_ 

%token NOT_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ IGUAL_ DESIGUAL_ 
%token AND_ OR_ EPSILON_ 

%%
expMat: exp;

exp: exp MAS_ term
   | exp MENOS_ term
   | term
   ;

term: term POR_ fac
    | term DIV_ fac
    | fac
    ;

fac: PARA_ exp PARC_
   | CTE_
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
%%
