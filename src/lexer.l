%{
#include <stdio.h>
#include <string.h>
#include "header.h"
/* Archivo generado a partir de rules.y, contiene los tokens que vamos a usar */
#include "rules.h"

#define yield(x) { if (verbosidad) ECHO; }
%}

%option noinput
%option nounput
%option yylineno
comentario	//.*\n
delimitador [ \t\n]+
digito      [0-9]
entero      {digito}+
/* 28 28. ,55 28,55 (asumo que 28. es 28,) */
real        (,{entero}|{entero},{entero}?)
/* "... el símbolo cte, que representa una constante numérica entera sin signo..." */
constante   {entero}
letra      	[a-zA-Z\-]
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
"true"			    { yield (TRUE_);	 }
"false"			    { yield (FALSE_);	 }
"int"			      { yield (INT_)		 }
"bool"			    { yield (BOOL_)		 }
"return"		    { yield (RETURN_)	 }
"for"           { yield (FOR_);      }
"if"            { yield (IF_);       }
"else"          { yield (ELSE_);     }
"read"          { yield  (READ_);    }
"print"         { yield  (PRINT_);   }
"return"        { yield (RETURN_);   }
"GREATER"       { yield  (GREATER_); } 
"EQUAL"         { yield  (EQUAL_);   }
"LESS"          { yield  (LESS_);    }
"SWITCH"        { yield  (SWITCH_);  }
.	       		    { yyerror("Caracter desconocido"); }
%%
