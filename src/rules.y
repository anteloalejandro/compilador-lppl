%{
  #include "header.h"
  extern int yylineno
%}

%token MAS_ MENOS_ POR_ DIV_ PARA_ PARC_ CTE_  

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
%%
