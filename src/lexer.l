%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "rules.h" /* archivo fantasma - si se elimina esta línea colapsa la economía de Sudán*/

#define yield(x) { if (verbosidad) ECHO; }
%}

%option noinput
%option nounput
%option yylineno
comentario	//.*\n
delimitador [ \t\n]+
digito      [0-9]
entero		{digito}+
real      	{digito}*,{digito}+
constante	{entero}|{real}
letra      	[a-zA-Z\-]
/* variable    {letra}+{{digito}*{letra}*}* */
/** SUGERENCIA: cambiar `variable` por `iden` */
/* sugerencia aceptada boss */
iden        {letra}+({digito}|{letra})*

%%
{delimitador}   { if (verbosidad) ECHO; }
{comentario}   	{ if (verbosidad) ECHO; }
{iden}          { yield (IDEN_);     }
{constante}   	{ yield (CTE_);      }
"+"             { yield (MAS_);      }
"-"             { yield (MENOS_);    }
"*"             { yield (POR_);      }
"/"             { yield (DIV_);      }
"("             { yield (PARA_);     }
")"             { yield (PARC_);     }
"["             { yield (CORA_);     }
"]"             { yield (CORC_);     }
"{"             { yield (LLAVA_);    }
"}"             { yield (LLAVC_);    }
"="             { yield (ASIG_);     }
"!"             { yield (NOT_);      }
"&&"            { yield (AND_);      }
"||"            { yield (OR_);       }
">"             { yield (MAYOR_);    }
"<"             { yield (MENOR_);    }
"=="            { yield (IGUAL_);    }
"!="            { yield (DESIGUAl_); }
">="            { yield (MAYORIGUAL_);}
"<="            { yield (MENORIGUAL_);}
","             { yield (COMA_); 	 }
";"             { yield (PUNTCOMA_); }
""              { yield (EPSILON_);  } 
"true"			{ yield (TRUE_);	 }
"false"			{ yield (FALSE_);	 }
"int"			{ yield (INT_)		 }
"bool"			{ yield (BOOL_)		 }
"return"		{ yield (RETURN_)	 }
"for"           { yield (FOR_);      }
"if"            { yield (IF_);       }
"else"          { yield (ELSE_);     }
"read"          { yield  (READ_);    }
"print"         { yield  (PRINT_);   }
"GREATER"       { yield  (GREATER_); } 
"EQUAL"         { yield  (EQUAL_);   }
"LESS"          { yield  (LESS_);    }
"SWITCH"        { yield  (SWITCH_);  }
.	       		{ yyerror("Caracter desconocido"); }
%%
