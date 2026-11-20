#ifndef _HELPERS_H
#define _HELPERS_H

#include <stdbool.h>

#define MAX_YYERRORF_CHARS 1024

// Traduce los tipos de libtds.h a strings
const char *string_tipo[] = {
  "T_VACIO",
  "T_ENTERO",
  "T_LOGICO",
  "T_ARRAY",
  "T_ERROR"
};

// yyerror con formato estilo printf
void yyerrorf(const char *format, ...);

// Lanza un error formateado con prefijo `pref` si `t_esperado != t_obtenido`
bool comprueba_tipo_pref(char * pref, int t_esperado, int t_obtenido);

// Lanza un error formateado si `t_esperado != t_obtenido`
bool comprueba_tipo(int t_esperado, int t_obtenido);

// Lanza un error formateado con prefijo "LHS: " si `t_esperado != t_obtenido`
bool comprueba_tipo_l(int t_esperado, int t_obtenido);

// Lanza un error formateado con prefijo "RHS: " si `t_esperado != t_obtenido`
bool comprueba_tipo_r(int t_esperado, int t_obtenido);

// Lanza un error formateado con prefijo `pref` si el tipo no es T_LOGICO o T_BOOL
bool comprueba_tipo_simple_pref(char * pref, int tipo);

// Lanza un error formateado si el tipo no es T_LOGICO o T_BOOL
bool comprueba_tipo_simple(int tipo);

// Lanza un error formateado con prefijo "LHS: " si el tipo no es T_LOGICO o T_BOOL
bool comprueba_tipo_simple_l(int tipo);

// Lanza un error formateado con prefijo "RHS: " si el tipo no es T_LOGICO o T_BOOL
bool comprueba_tipo_simple_r(int tipo);

// Intenta reconciliar los tipos de `tipo_a` y `tipo_b`:
// - Si los tipos son iguales, devuelve el tipo.
// - Si ninguno es T_ERROR, pero los tipos no coinciden, devuelve T_ERROR.
// - Si uno sólo de los dos es T_ERROR, se devuelve el tipo del otro.
int reconcilia_tipos(int tipo_a, int tipo_b);

#endif // _HELPERS_H
