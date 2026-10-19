#include "helpers.h"
#include <stdlib.h>
#include <math.h>

float parse_constante(char *input) {
  // INFO: man 3 strtol
  int entero = strtol(input, &input, 10);
  float decimal = 0;

  if (*input == '.' || *input == ',') {
    char *end = ++input;
    decimal = strtol(input, &end, 10);

    int digitos_decimales = end - input;

    decimal /= pow(10, digitos_decimales);
  }

  return entero + decimal;
}
