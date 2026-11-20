%{
  #include "header.h"
  #include "libtds.h"
  #include "helpers.h"
  extern int yylineno;
%}

%union {
  int cte;
  unsigned int tipo;
  char *iden;
}

// CONSTANTES
%token <cte> FALSE_ TRUE_
%token INT_ BOOL_

// OPERADORES ARITMÉTICOS
%token MAS_ MENOS_ POR_ DIV_

// OPERADORES LÓGICOS
%token MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ IGUAL_ DESIGUAL_
%token NOT_ AND_ OR_

// OTROS OPERADORES
%token ASIG_

// PARÉNTESIS
%token PARA_ PARC_
// CORCHETES
%token CORA_ CORC_
// LLAVES
%token LLAVA_ LLAVC_

// ESTRUCTURAS DE CONTROL
%token FOR_ IF_ ELSE_ RETURN_

// SWITCH
%token SWITCH_ GREATER_ EQUAL_ LESS_

// FUNCIONES BUILT-IN
%token READ_ PRINT_ 

// TOKENS MISCELÁNEOS
%token <iden> IDEN_
%token <cte> CTE_
%token PUNTCOMA_ COMA_ 

%type <cte> const

%type <tipo> tipoSimp expre expreOP 
%type <tipo> expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi

%%
programa:
        {
          niv = 0; // nivel global
          dvar = 0;
          cargaContexto(niv);
        }
        listDecla
        {
            if (verTdS) mostrarTdS();

            SIMB s = obtTdS("main");
            if (s.t == T_ERROR) {
              yyerror("NO HAY UNA FUNCIÓN `main`");
            }
          }
        ;

listDecla: decla
         | listDecla decla
         ;

decla: declaVar
     |
     {
       niv = 1; // nivel local de la función
       dvar_copy = dvar;
       cargaContexto(niv);
     }
     declaFunc
     {
       descargaContexto(niv);
       niv = 0;
       dvar = dvar_copy;
     }
     ;

const: CTE_ { $$ = (int)$1; }
     | TRUE_ { $$ = $1; }
     | FALSE_ { $$ = $1; }
     ;

tipoSimp: BOOL_ { $$ = T_LOGICO; }
        | INT_ { $$ = T_ENTERO; }
        ;

declaVar: tipoSimp IDEN_ PUNTCOMA_
        {
          if (insTdS($2, VARIABLE, $1, niv, dvar, REF_SIMPLE)) {
            dvar += TALLA_TIPO_SIMPLE;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        | tipoSimp IDEN_ ASIG_ const PUNTCOMA_
        {
          if (insTdS($2, VARIABLE, $1, niv, dvar, REF_SIMPLE)) {
            dvar += TALLA_TIPO_SIMPLE;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        | tipoSimp IDEN_ CORA_ CTE_ CORC_ PUNTCOMA_
        {
          int elems = $4;
          if (elems == 0) {
            yyerror("La talla del array debe ser superior a 0");
            elems = 0;
          }

          // reserva espacio para los elementos dado su tipo.
          int ref = insTdA($1, elems);

          if (insTdS($2, VARIABLE, $1, niv, dvar, ref)) {
            dvar += TALLA_TIPO_SIMPLE * elems;
          } else {
            yyerrorf("Identificador <%s> repetido", $2);
          }
        }
        ;

declaVarLocal: 
             | declaVarLocal declaVar
             ;

listParamForm: tipoSimp IDEN_
             | tipoSimp IDEN_ COMA_ listParamForm
             ;

paramForm:
         | listParamForm
         ;

bloque: LLAVA_ declaVarLocal listInst RETURN_ expre PUNTCOMA_ LLAVC_
      ;

declaFunc: tipoSimp IDEN_ PARA_ paramForm PARC_ bloque 
         ;

listInst:
        | listInst inst
        ;

inst: LLAVA_ listInst LLAVC_
    | instExpre
    | instEntSal
    | instSelec
    | instIter
    | instSwitch
    ;

instSwitch: SWITCH_ IDEN_ LLAVA_ Less Equal Greater LLAVC_
          {
            SIMB s = obTDS($2);
            if (s.t == T_ERROR) {
              yyerrorf("Identificador <%s> no declarado", $2);
            } else if (s.t != T_ENTERO || s.ref != REF_SIMPLE) {
              yyerror("El identificador del switch debe ser de tipo entero");
            }
          }
          ;

Less: LESS_ inst
    ;

Equal: EQUAL_ inst
     ;

Greater: GREATER_ inst
       ;

instExpre: expre PUNTCOMA_
         | PUNTCOMA_
         ;

instEntSal: READ_ PARA_ IDEN_ PARC_ PUNTCOMA_
          {
            SIMB s = obtTdS($3);
            if (s.t == T_ERROR) {
              yyerrorf("Identificador <%s> no declarado", $3);
            } else if (s.t != T_ENTERO || s.ref != REF_SIMPLE) {
              yyerror("El identificador del read debe ser de tipo entero");
            }
          }
          | PRINT_ PARA_ expre PARC_ PUNTCOMA_
          {
            SIMB s = obtTdS($3);
            if (s.t == T_ERROR) {
              yyerrorf("Identificador <%s> no declarado", $3);
            } else if (s.t != T_ENTERO) {
              yyerror("La expresión del print debe ser de tipo entero");
            }
          }
          ;

instSelec: IF_ PARA_ expre PARC_ inst ELSE_ inst
        {
          if ($3 != T_ERROR && $3 != T_LOGICO){
            yyerror("La expresión del 'if' debe ser lógica");
          }
        }
         ;

instIter: FOR_ PARA_ expreOP PUNTCOMA_ expre PUNTCOMA_ expreOP PARC_ inst
        {
          if ($5 != T_ERROR && $5 != T_LOGICO){
            yyerror("La expresión del 'for' debe ser lógica");
          }
        }
        ;

expreOP:  {$$ = T_VACIO;}
       | expre {
          if ($1 != T_ERROR && $1 != T_ENTERO && $1 != T_LOGICO){
            yyerror("La 'expreOP' del for debe ser de tipo simple");  
            $$ = T_ERROR;
          } else {
            $$ = $1;
          }
       }
       ;

expre: expreLogic { $$ = T_LOGICO; }
     | IDEN_ ASIG_ expre
      {
        SIMB s = obtTdS($1);
        SIMB s2 = obtTdS($3);
        if (s.t == T_ERROR ) {
          yyerrorf("Identificador <%s> no declarado", $1);
        }else if (s2.t == T_ERROR) {
          yyerrorf("Identificador <%s> no declarado", $3);
        }else if ((s.t == BOOL_ && s2.t == INT_) || (s.t == INT_ && s2.t == BOOL_)) {
          yyerror("No se puede asignar un valor entero a un booleano");
        }
      }
     | IDEN_ CORA_ expre CORC_ ASIG_ expre
      {
        SIMB s = obtTdS($1);
        if (s.t == T_ERROR) {
          yyerrorf("Identificador <%s> no declarado", $1);
        } 
          // Y esto qué es?
          else if ($2 == CORA_ && s.ref == 3) 
          {
            DIM d = obtTdA(s.ref);
            if ($3 >= d.talla) {
            yyerror("El índice del vector está fuera de rango");
            }
            if ($6 != T_ERROR && $6 != s.t) {
              yyerror("El tipo de la expresión no coincide con el tipo del identificador");
            }
          } else {
            yyerror("El identificador debe ser un vector");
        }

        // en C, las asignaciones devuelven el valor que asignan
        $$ = $6;
      }
      
     ;

expreLogic: expreIgual
          {
            comprueba_tipo(T_LOGICO, $1);

            // aunque dé error, tiramos palante
            $$ = T_LOGICO;
          }
          | expreLogic opLogic expreIgual
          {
            comprueba_tipo_l(T_LOGICO, $1);
            comprueba_tipo_r(T_LOGICO, $3);

            $$ = T_LOGICO;
          }
          ;

expreIgual: expreRel
          {
            comprueba_tipo(T_LOGICO, $1);

            // aunque dé error, tiramos palante
            $$ = T_LOGICO;
          }
          | expreIgual opIgual expreRel
          {
            comprueba_tipo_l(T_LOGICO, $1);
            comprueba_tipo_r(T_LOGICO, $3);

            $$ = T_LOGICO;
          }
          ;

expreRel: expreAd
        {
          // NOTA: no hay conversión de tipos,
          // así que tiene pinta de que aquí siempre da error
          // porque expreAd siempre es T_ENTERO y expreRel debe ser T_LOGICO.
          // Sin embargo, eso haría que todas las comparaciones fallasen al menos una vez.
          comprueba_tipo(T_ENTERO, $1);
          // El tipo de expreRel en esta producción tiene que ser entero
          // para poder hacer comparaciones en la siguiente producción.
          // NOTA: Si permitirmos comparaciones relativas entre booleanos, $$ = $1.
          $$ = T_ENTERO; 
        }
        | expreRel opRel expreAd
        {
          comprueba_tipo_l(T_ENTERO, $1);
          comprueba_tipo_r(T_ENTERO, $3);

          $$ = T_LOGICO;
        }
        ;

expreAd: expreMul
       | expreAd opAd expreMul
       ;

expreMul: expreUna
        | expreMul opMul expreUna
        ;

expreUna: expreSufi
        | opUna expreUna
        ;

expreSufi: const
         | PARA_ expre PARC_
         | IDEN_
         | IDEN_ CORA_ expre CORC_
         | IDEN_ PARA_ paramAct PARC_
         ;

listParamAct: expre
            | expre COMA_ listParamAct
            ;

paramAct:
        | listParamAct
        ;

opUna: MAS_
     | MENOS_
     | NOT_
     ;

opMul: POR_
     | DIV_
     ;
opAd: MAS_
    | MENOS_
    ;

opRel: MAYOR_
     | MENOR_
     | MAYORIGUAL_
     | MENORIGUAL_
     ;

opIgual: IGUAL_
       | DESIGUAL_
       ;

opLogic: AND_
       | OR_
       ;
%%
