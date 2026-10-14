%{
#include <stdio.h>
#include <string.h>
#include "header.h"
/* Archivo generado a partir de rules.y, contiene los tokens que vamos a usar */
#include "rules.h"

#define yield(x) { if (verbosidad) ECHO; return (x); }

bool permite_decimal = true;
%}

%option noinput
%option nounput
%option yylineno

comentario  "//".*\n
delimitador [ \t\n]+
digito      [0-9]
entero      {digito}+
/* 28 28. 28,55, el ',55' se gestiona aparte*/
real        ({entero}\.|{entero},{entero})
/* ,55 */
decimal     ,{entero}
/* "... el símbolo cte, que representa una constante numérica entera sin signo..." */
constante   ({entero}|{real})
letra       [a-zA-Z\-]
iden        [a-zA-Z]+({digito}|{letra})*

/* NOTA: Las palabras clave DEBEN ir antes para hacer matching primero */
%%
"true"          { yield (TRUE_);     }
"false"         { yield (FALSE_);    }
"int"           { yield (INT_);      }
"bool"          { yield (BOOL_);     }
"return"        { yield (RETURN_);   }
"for"           { yield (FOR_);      }
"if"            { yield (IF_);       }
"else"          { yield (ELSE_);     }
"read"          { yield  (READ_);    }
"print"         { yield  (PRINT_);   }
"greater"       { yield  (GREATER_); } 
"equal"         { yield  (EQUAL_);   }
"less"          { yield  (LESS_);    }
"switch"        { yield  (SWITCH_);  }

"+"             { permite_decimal = true; yield (MAS_);      }
"-"             { permite_decimal = true; yield (MENOS_);    }
"*"             { permite_decimal = true; yield (POR_);      }
"/"             { permite_decimal = true; yield (DIV_);      }
"("             { permite_decimal = true; yield (PARA_);     }
")"             { permite_decimal = false; yield (PARC_);     }
"["             { permite_decimal = true; yield (CORA_);     }
"]"             { permite_decimal = false; yield (CORC_);     }
"{"             { permite_decimal = true; yield (LLAVA_);    }
"}"             { permite_decimal = false; yield (LLAVC_);    }
"="             { permite_decimal = true; yield (ASIG_);     }
"!"             { permite_decimal = true; yield (NOT_);      }
"&&"            { permite_decimal = true; yield (AND_);      }
"||"            { permite_decimal = true; yield (OR_);       }
">"             { permite_decimal = true; yield (MAYOR_);    }
"<"             { permite_decimal = true; yield (MENOR_);    }
"=="            { permite_decimal = true; yield (IGUAL_);    }
"!="            { permite_decimal = true; yield (DESIGUAL_); }
">="            { permite_decimal = true; yield (MAYORIGUAL_);}
"<="            { permite_decimal = true; yield (MENORIGUAL_);}
";"             { permite_decimal = true; yield (PUNTCOMA_); }
","             {
                  permite_decimal = true;
                  yield (COMA_);
                }

{delimitador}   { if (verbosidad) ECHO; }
{comentario}    { if (verbosidad) ECHO; }
{iden}          { permite_decimal = false; yield (IDEN_);     }
{constante}     { permite_decimal = false; yield (CTE_);      }
{decimal}       {
                  if (permite_decimal) {
                    permite_decimal = false;
                    yield (CTE_);
                  } else {
                    // no se ha podido usar como decimal, así que recicla la
                    // cadena para que la use yylex en la siguiente iteración.
                    yyless(1);
                    permite_decimal = true;
                    yield (COMA_);
                  }
                }

.               { yyerror("Caracter desconocido"); }
%%
