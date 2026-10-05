%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "rules.h"

#define yield(x) { if (verbosidad) ECHO; }
%}

%option noinput
%option nounput
%option yylineno
delimitador [ \t\n]
digito      [0-9]
entero      {digito}+

%%
{delimitador}   { if (verbosidad) ECHO; }
"+"             { yield (MAS_);      }
"-"             { yield (MENOS_);    }
"*"             { yield (POR_);      }
"/"             { yield (DIV_);      }
"("             { yield (APAR_);     }
")"             { yield (CPAR_);     }
{entero}        { yield (CTE_);      }
.	       { yyerror("Caracter desconocido"); }
%%
