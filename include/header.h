#ifndef _HEADER_H
#define _HEADER_H

#include <stdio.h>
#include <stdbool.h>

enum { FALSE = 0, TRUE }; // bool backup

extern int yylex();
extern FILE *yyin;
extern int yylineno;
extern void yyerror(const char *msg);
extern bool verbose;

#endif // !_HEADER_H

