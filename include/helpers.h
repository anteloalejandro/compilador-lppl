#ifndef _HELPERS_H
#define _HELPERS_H

#include <stdbool.h>

#define MAX_YYERRORF_CHARS 1024

extern const char *string_tipo[];

// yyerror con formato estilo printf
void yyerrorf(const char *format, ...);

// Lanza un error formateado si `t_esperado != t_obtenido`.
bool comprueba_tipo(char * expr, int t_esperado, int t_obtenido);

// Lanza un error formateado si `t_esperado != t_obtenido`.
// Para el lado izquierdo de expresiones binarias.
bool comprueba_tipo_l(char * expr, int t_esperado, int t_obtenido);

// Lanza un error formateado si `t_esperado != t_obtenido`.
// Para el lado derecho de expresiones binarias.
bool comprueba_tipo_r(char * expr, int t_esperado, int t_obtenido);

// Lanza un error formateado si el tipo no es T_LOGICO o T_BOOL.
// Para el lado izquierdo de expresiones binarias.
bool comprueba_tipo_simple_l(char * expr, int tipo);

// Lanza un error formateado si el tipo no es T_LOGICO o T_BOOL.
// Para el lado derecho de expresiones binarias.
bool comprueba_tipo_simple_r(char * expr, int tipo);

bool comprueba_tipo_simple(int tipo);

#endif // _HELPERS_H
