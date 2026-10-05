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
letra      [a-zA-Z\-]
palabrareservada ("true"|"false"|"cte"|"int"|"bool"|"return"|"id"|"read"|"print"|"if"|"else"|"for")
variable    {letra}+{{digito}*{letra}*}*
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
"!"             { yield (NOT_);      }
"&&"            { yield (AND_);      }
"||"            { yield (OR_);       }
">"             { yield (MAYOR_);    }
"<"             { yield (MENOR_);    }
"=="            { yield (IGUAL_);    }
"!="            { yield (DESIGUAl_); }
">="            { yield (MAYORIGUAL_);}
"<="            { yield (MENORIGUAL_);}
"epsilon"       { yield (EPSILON_);  }
%%
