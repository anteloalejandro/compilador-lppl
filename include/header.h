#ifndef _HEADER_H
#define _HEADER_H

#include <stdio.h>
#include <stdbool.h>

enum { FALSE = 0, TRUE }; // bool backup

extern int yylex();
extern int yyparse();
extern void yyerror(const char *msg);

extern FILE *yyin;                           /* Fichero de entrada           */
extern int yylineno;                       /* Contador del numero de linea */
extern char *yytext;                         /* Patron detectado             */

extern bool verbosidad;                   /* Flag si se desea una traza       */
extern int numErrores;              /* Contador del numero de errores        */

#endif // !_HEADER_H

