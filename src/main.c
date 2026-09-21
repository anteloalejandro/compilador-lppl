#include <stdio.h>
#include <string.h>
#include "header.h"

bool verbose = FALSE;
int numErrores = 0;

void yyerror(const char * msg) {
  numErrores++;  fflush(stdout);
  fprintf(stdout, "\nError en %d: %s\n", yylineno, msg);
}
int main(int argc, char **argv) {
  int i, n=1 ;

  for (i=1; i<argc; ++i) {
    if (strcmp(argv[i], "-v")==0) {
      verbose = TRUE;
      n++;
    }
  }
  if (argc == n+1) {
    if ((yyin = fopen (argv[n], "r")) == NULL) {
      fprintf(stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
      fprintf(stderr, "Uso: %s [-v] fichero\n", argv[0]);
    } else {
      yylex();
    }
  } else {
    fprintf(stderr, "Uso: %s [-v] fichero\n", argv[0]);
  }

  return (0);
} 
