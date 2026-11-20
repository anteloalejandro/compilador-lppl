#include "helpers.h"
#include "header.h"
#include "rules.h"
#include <stdio.h>
#include <stdarg.h>

void yyerrorf(const char *restrict format, ...) {
  static char buf[1024] = "";
  va_list args;
  // inicializa lista de argumentos (empiezan a partir de format)
  va_start(args, format);
  // printf, pero inserta en buf y toma una va_list
  vsnprintf(buf, sizeof(buf), format, args);
  // man vsnprintf dice que esa función no llama a va_end, se hace a mano
  va_end(args);

  yyerror(buf);
}

void comprueba_tipo_pref(char * pref, int t_esperado, int t_obtenido) {
  if (t_esperado == t_obtenido) return;

  yyerrorf("%sEsperaba %s, %s obtenido",
           pref,
           string_tipo[t_esperado],
           string_tipo[t_obtenido]);
}

void comprueba_tipo(int t_esperado, int t_obtenido) {
  comprueba_tipo_pref("", t_esperado, t_obtenido);
}

void comprueba_tipo_l(int t_esperado, int t_obtenido) {
  comprueba_tipo_pref("LHS: ", t_esperado, t_obtenido);
}

void comprueba_tipo_r(int t_esperado, int t_obtenido) {
  comprueba_tipo_pref("RHS: ", t_esperado, t_obtenido);
}
