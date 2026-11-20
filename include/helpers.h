#ifndef _HELPERS_H
#define _HELPERS_H

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
void comprueba_tipo_pref(char * pref, int t_esperado, int t_obtenido);

// Lanza un error formateado si `t_esperado != t_obtenido`
void comprueba_tipo(int t_esperado, int t_obtenido);

// Lanza un error formateado con prefijo "LHS: " `t_esperado != t_obtenido`
void comprueba_tipo_l(int t_esperado, int t_obtenido);

// Lanza un error formateado con prefijo "RHS: " `t_esperado != t_obtenido`
void comprueba_tipo_r(int t_esperado, int t_obtenido);

#endif // _HELPERS_H
