#ifndef _HEADER_H
#define _HEADER_H

#include <stdio.h>
#include <stdbool.h>

#define TALLA_TIPO_SIMPLE 1
#define TALLA_SEGENLANCES 2

enum { FALSE = 0, TRUE }; // bool backup

extern int yylex();
extern int yyparse();
extern void yyerror(const char *msg);

extern FILE *yyin;                           /* Fichero de entrada           */
extern int yylineno;                       /* Contador del numero de linea */
extern char *yytext;                         /* Patron detectado             */

extern bool verbosidad;                   /* Flag si se desea una traza       */
extern int numErrores;              /* Contador del numero de errores        */
extern bool verTdS;

#endif // !_HEADER_H

