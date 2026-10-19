#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"

#define MAL_USO -1

bool verTds = false;
bool verbosidad = false;
int numErrores = 0;

void yyerror(const char * msg) {
  numErrores++;  fflush(stdout);
  fprintf(stdout, "\nError en línea %d: %s\n", yylineno, msg);
}

int main(int argc, char **argv) {
  int i, n=1 ;

  for (i=1; i<argc; ++i) {
    if (strcmp(argv[i], "-v")==0) {
      verbosidad = true;
      n++;
    }
    if (strcmp(argv[i], "-t")==0) {
      verTds = true;
      n++;
    }
  }

  if (argc != n+1) {
    fprintf(stderr, "Uso: %s [-v] fichero\n", argv[0]);
    return MAL_USO;
  }

  if ((yyin = fopen (argv[n], "r")) == NULL) {
    fprintf(stderr, "El fichero '%s' no es valido\n", argv[n]);
    fprintf(stderr, "Uso: %s [-v] fichero\n", argv[0]);
    return MAL_USO;
  }

  if (verbosidad) fprintf(stdout, "%3d.- ", yylineno);
  if (verTds) mostrarTdS();
  yyparse();
  if (numErrores > 0) {
    fprintf(stderr, "\nNumero de errores:      %d\n", numErrores);
  }

  return numErrores;
}
