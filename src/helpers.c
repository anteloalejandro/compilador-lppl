#include "helpers.h"
#include "header.h"
#include "libtds.h"
#include <stdio.h>
#include <stdarg.h>

// Traduce los tipos de libtds.h a strings
const char *string_tipo[] = {
  "T_VACIO",
  "T_ENTERO",
  "T_LOGICO",
  "T_ARRAY",
  "T_ERROR"
};

void yyerrorf(const char *restrict format, ...) {
  static char buf[MAX_YYERRORF_CHARS] = "";
  va_list args;
  // inicializa lista de argumentos (empiezan a partir de format)
  va_start(args, format);
  // printf, pero inserta en buf y toma una va_list
  vsnprintf(buf, sizeof(buf), format, args);
  // man vsnprintf dice que esa función no llama a va_end, se hace a mano
  va_end(args);

  yyerror(buf);
}

bool comprueba_tipo_pref(char * pref, int t_esperado, int t_obtenido) {
  if (t_esperado == t_obtenido) return true;

  yyerrorf(
    "%sEsperaba %s -- %s obtenido",
    pref,
    string_tipo[t_esperado],
    string_tipo[t_obtenido]
  );

  return false;
}

bool comprueba_tipo(int t_esperado, int t_obtenido) {
  return comprueba_tipo_pref("", t_esperado, t_obtenido);
}

bool comprueba_tipo_l(int t_esperado, int t_obtenido) {
  return comprueba_tipo_pref("LHS: ", t_esperado, t_obtenido);
}

bool comprueba_tipo_r(int t_esperado, int t_obtenido) {
  return comprueba_tipo_pref("RHS: ", t_esperado, t_obtenido);
}

bool comprueba_tipo_simple_pref(char * pref, int tipo) {
  if (tipo == T_LOGICO || tipo == T_ENTERO) return true;

  yyerrorf(
    "%sEsperaba %s o %s -- %s obtenido",
    pref,
    string_tipo[T_LOGICO],
    string_tipo[T_ENTERO],
    string_tipo[tipo]
  );

  return false;
}

bool comprueba_tipo_simple(int tipo) {
  return comprueba_tipo_simple_pref("", tipo);
}

bool comprueba_tipo_simple_l(int tipo) {
  return comprueba_tipo_simple_pref("LHS: ", tipo);
}

bool comprueba_tipo_simple_r(int tipo) {
  return comprueba_tipo_simple_pref("RHS: ", tipo);
}

int reconcilia_tipos(int tipo_a, int tipo_b) {
  int tipo;

  if (tipo_a == tipo_b) {
    // Si ambos lados tienen el mismo tipo, le damos ese tipo.
    tipo = tipo_a;
  } else {
    if (tipo_a != T_ERROR && tipo_b != T_ERROR) {
      // Si tienen tipo distinto y sin error, le damos tipo T_ERROR.
      tipo = T_ERROR;
    } else {
      // Si tienen tipo distinto y uno de ellos es T_ERROR,
      // le damos el tipo del que no es error.
      tipo = tipo_a == T_ERROR ? tipo_b : tipo_a;
    }
  }

  return tipo;
}
