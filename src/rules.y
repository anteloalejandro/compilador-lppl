%{
  #include "header.h"
  #include "helpers.h"
  #include "libtds.h"

  int dvar_copy;
  int desp_param;
%}

%union {
  int cte;
  int tipo;
  struct constante {
    int cte;
    int tipo;
  } constante;
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

%type <constante> const

%type <tipo> tipoSimp expre expreOP 
%type <tipo> expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi
%type <tipo> opUna // para diferenciar entre +/- y !.
%type <tipo> listParamAct paramAct // la coma también es un operador

%type <tipo> paramForm listParamForm bloque

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
     | declaFunc
     ;

const: CTE_ { $$ = (struct constante){ .cte = $1, .tipo = T_ENTERO }; }
     | TRUE_ { $$ = (struct constante){ .cte = $1, .tipo = T_LOGICO }; }
     | FALSE_ { $$ = (struct constante){ .cte = $1, .tipo = T_LOGICO }; }
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
          comprueba_tipo($1, $4.tipo);

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
			 { 
			   $$ = insTdD(-1, $1);
               if (insTdS($2, PARAMETRO, $1, niv, desp_param, REF_SIMPLE)) {
                 desp_param -= TALLA_TIPO_SIMPLE;
               } else {
                 yyerrorf("Identificador de parámetro <%s> repetido", $2);
               }
             }
             | tipoSimp IDEN_ COMA_ listParamForm
             {
               $$ = insTdD($4, $1);
               if (insTdS($2, PARAMETRO, $1, niv, desp_param, REF_SIMPLE)) {
                 desp_param -= TALLA_TIPO_SIMPLE;
               } else {
                 yyerrorf("Identificador de parámetro <%s> repetido", $2);
               }
             }
             ;

paramForm: { $$ = insTdD(-1, T_VACIO); }
         | listParamForm { $$ = $1; } 
         ;

bloque: LLAVA_ declaVarLocal listInst RETURN_ expre PUNTCOMA_ LLAVC_
      {
        $$ = $5;
      }
      ;

declaFunc: tipoSimp IDEN_ 
		 {
	   		niv = 1; // nivel local de la función
	   		dvar_copy = dvar;
	   		dvar = 0;
	   		desp_param = -(TALLA_SEGENLANCES + TALLA_TIPO_SIMPLE);
	   		cargaContexto(niv);
	 	 } 
			PARA_ paramForm PARC_ 
		 {
		   	if (!insTdS($2, FUNCION, $1, niv - 1, dvar, $5)) {
				yyerrorf("Identificador de función <%s> repetido", $2);
			}
		 }
		 bloque 
		 {
		   INF inf = obtTdD(-1);
		   if (inf.tipo != T_ERROR && $7 != T_ERROR && inf.tipo != $7) {
		     yyerrorf("El tipo de retorno en <%s> no coincide con su declaración", $2);
		   }
		   if (verTdS) mostrarTdS();
		   descargaContexto(niv);
		   niv = 0;
		   dvar = dvar_copy;
		 }
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
            SIMB s = obtTdS($2);
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
            if ($3 != T_ENTERO) {
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

expre: expreLogic { $$ = $1; }
     | IDEN_ ASIG_ expre
     {
       SIMB s = obtTdS($1);
       if (s.t == T_ERROR) {
         yyerrorf("Identificador <%s> no declarado", $1);
       } else {
         comprueba_tipo(s.t, $3);
       }
     }
     | IDEN_ CORA_ expre CORC_ ASIG_ expre
      {
        SIMB s = obtTdS($1);
        if (s.t == T_ERROR) {
          yyerrorf("Identificador <%s> no declarado", $1);
        } else if (s.t != T_ARRAY) {
          yyerrorf("<%s> no es de tipo T_ARRAY", $1);
        }

        if ($3 != T_ENTERO) {
          yyerrorf("El subíndice de <%s> debe ser un entero", $1);
        }
        if ($6 != s.t) {
          DIM d = obtTdA(s.ref);
          yyerrorf("<%s> es un %s[], se ha intentado asignar un %s",
            $1,
            string_tipo[d.telem],
            string_tipo[s.t]
          );
        }

        // NOTA: No sabemos el valor de expre en este punto,
        // porque puede ser un `const` (sabemos su valor)
        // o otra cosa (no sabemos su valor).
        // DIM d = obtTdA(s.ref);
        // if ($3 == 0 || $3 >= d.nelem) {
        //   yyerror("El subíndice de %s es %d, debe estar en el rango (0..%d)", $1, $3, d.nelem);
        // }

        // en C, las asignaciones devuelven el valor que asignan
        $$ = $6;
      }
      
     ;

expreLogic: expreIgual { $$ = $1; }
          | expreLogic opLogic expreIgual
          {
            // expreLogic puede ser tipo entero o lógico por ambas producciones.
            int t_lhs = comprueba_tipo_simple_l($1) ? $1 : T_ERROR;

            // expreIgual puede ser tipo entero o lógico por ambas producciones.
            int t_rhs = comprueba_tipo_simple_r($3) ? $3 : T_ERROR;

            int t_prod = reconcilia_tipos(t_lhs, t_rhs);

            $$ = t_prod;
          }
          ;

expreIgual: expreRel { $$ = $1; }
          | expreIgual opIgual expreRel
          {
            // expreIgual puede ser tipo entero si viene de expreRel,
            // o tipo lógico por por expreRel o la segunda producción.
            int t_lhs = comprueba_tipo_simple_l($1) ? $1 : T_ERROR;

            // expreRel puede ser tipo entero si viene de expreAd,
            // o tipo lógico por la segunda producción.
            int t_rhs = comprueba_tipo_simple_r($3) ? $3 : T_ERROR;

            // La producción tendrá tipo T_ERROR si:
            // - Ambos lados dan error
            // - Los tipos no se pueden reconciliar (entero + bool)
            // Si una de los lados da error, pero el otro no,
            // le damos el tipo del lado sin error (recuperación de errores).
            int t_prod = reconcilia_tipos(t_lhs, t_rhs);

            $$ = t_prod;
          }
          ;

expreRel: expreAd { $$ = $1; }
        | expreRel opRel expreAd
        {
          comprueba_tipo_l(T_ENTERO, $1);
          comprueba_tipo_r(T_ENTERO, $3);

          // NOTA: Si consideramos que se pueden comparar
          // dos bool también, habría que cambiar esto.
          $$ = T_LOGICO;
        }
        ;

expreAd: expreMul { $$ = $1; }
       | expreAd opAd expreMul
       {
         comprueba_tipo_l(T_ENTERO, $1);
         comprueba_tipo_r(T_ENTERO, $3);

         $$ = T_ENTERO;
       }
       ;

expreMul: expreUna { $$ = $1; }
        | expreMul opMul expreUna
        {
          comprueba_tipo_l(T_ENTERO, $1);
          comprueba_tipo_r(T_ENTERO, $3);

          $$ = T_ENTERO;
        }
        ;

expreUna: expreSufi { $$ = $1; }
        | opUna expreUna
        {
          // expreUna puede ser ENTERO (+/- expreUna)
          // o LOGICO (! expreUna)
          comprueba_tipo($1, $2);
          $$ = $1;
        }
        ;

expreSufi: const { $$ = $1.tipo; }
         | PARA_ expre PARC_ { $$ = $2; }
         | IDEN_
         {
           SIMB s = obtTdS($1);
           if (s.t == T_ERROR) {
             yyerrorf("<%s> no ha sido declarado", $1);
           }

           $$ = s.t;
         }
         | IDEN_ CORA_ expre CORC_
         {
           SIMB s = obtTdS($1);

           if (s.t == T_ERROR) {
             yyerrorf("<%s> no ha sido declarado", $1);
           } else if (s.t != T_ARRAY) {
             yyerrorf("<%s> debería ser un T_ARRAY, pero es un %s", $1, string_tipo[s.t]);
           }

           if ($3 != T_ENTERO) {
             yyerror("El subíndice debe ser T_ENTERO");
           }

           $$ = s.t;
         }
         | IDEN_ PARA_ paramAct PARC_
		     {
           SIMB s = obtTdS($1);
           if (s.t == T_ERROR) {
             yyerrorf("<%s> no ha sido declarado", $1);
             $$ = T_ERROR;
           } else {
             INF inf = obtTdD(s.ref);
             if (inf.tipo == T_ERROR) {
               yyerrorf("<%s> no es una función", $1);
               $$ = T_ERROR;
             } else if (!cmpDom(s.ref, $3)) {
               yyerrorf("Error en los parámetros de la llamada a <%s>", $1);
               $$ = T_ERROR;
             } else {
               $$ = inf.tipo;
             }
           }
         }
         ;

listParamAct: expre
            {
              $$ = insTdD(-1, $1);
            }
            | expre COMA_ listParamAct
            {
              // En C, la coma es un operador que devuelve
              // el valor de su lado derecho.
              // No aplica conversión de tipos de por sí.
              $$ = insTdD($3, $1);
            }
            ;

paramAct: { $$ = insTdD(-1, T_VACIO); }
        | listParamAct { $$ = $1; }
        ;

opUna: MAS_ { $$ = T_ENTERO; }
     | MENOS_ { $$ = T_ENTERO; }
     | NOT_ { $$ = T_LOGICO; }
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
