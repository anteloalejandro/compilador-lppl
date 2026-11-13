#include "helpers.h"
#include "header.h"
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

