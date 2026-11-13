#ifndef _HELPERS_H
#define _HELPERS_H

// Saca el valor de `{constante}`, tal y como están definidas en src/lexer.l
float parse_constante(char *input);

// yyerror con formato estilo printf
void yyerrorf(const char *format, ...);

#endif // _HELPERS_H
