%{
#include <stdio.h>
#include <string.h>
#include "header.h"
/* Archivo generado a partir de rules.y, contiene los tokens que vamos a usar */
#include "rules.h"

#define yield(x, ...) { if (verbosidad) ECHO; __VA_ARGS__; return (x); }
%}

%option noinput
%option nounput
%option yylineno

comentario  "//".*\n
delimitador [ \t\n]+
digito      [0-9]
entero      {digito}+
/* 28 28. ,55 28,55 */
real        ({entero}(,|\.)|{entero}?(,|\.){entero})
/* "... el símbolo cte, que representa una constante numérica entera sin signo..." */
constante   ({entero}|{real})
letra       [a-zA-Z\-]
iden        [a-zA-Z]+({digito}|{letra})*

/* NOTA: Las palabras clave DEBEN ir antes para hacer matching primero */
%%
"true"          { yield (TRUE_, yylval.cte = 1); }
"false"         { yield (FALSE_, yylval.cte = 0); }
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
"!="            { yield (DESIGUAL_); }
">="            { yield (MAYORIGUAL_);}
"<="            { yield (MENORIGUAL_);}
","             { yield (COMA_);   }
";"             { yield (PUNTCOMA_); }

{delimitador}   { if (verbosidad) ECHO; }
{comentario}    { if (verbosidad) ECHO; }
{iden}          { yield (IDEN_, yylval.iden = yytext);     }
{constante}     { yield (CTE_, yylval.cte = atoi(yytext)); }

.               { yyerror("Caracter desconocido"); }
%%
