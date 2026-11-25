#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libgci.h"

#define MAL_USO -1

bool verTdS = false;
bool verbosidad = false;
int numErrores = 0;

void yyerror(const char * msg) {
  numErrores++;  fflush(stdout);
  fprintf(stdout, "\nError en línea %d: %s\n", yylineno, msg);
}

int main(int argc, char **argv) {
  int i, n=1;

  // Gestiona la linea de comandos e invoca al analizador sintactico-semantico.
  char * nom_fich;

  for (i=1; i<argc; ++i) {
    if (strcmp(argv[i], "-v")==0) {
      verbosidad = true;
      n++;
    }
    if (strcmp(argv[i], "-t")==0) {
      verTdS = true;
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
  nom_fich = argv[n];
  yyparse();
  if (numErrores == 0) {
    volcarCodigo(nom_fich);
  } else {
    fprintf(stderr, "\nNumero de errores:      %d\n", numErrores);
  }

  return numErrores;
}
