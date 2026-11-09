## Requisitos

- `make`
- `gcc` o `clang`
- `flex`
- `bison`

**Archlinux**
```bash
sudo pacman -S base-devel
```

**Ubuntu**
```bash
sudo apt install -S build-essential flex bison
```

## Compilación

Compilación con `make`.

```bash
# mostrar ayuda
make help

# compilar
make compile

# borrar artefactos de compilación
make clean
```

`make` sólo recompila si se han detectado cambios en el proyecto, por lo que se han habilitado dos comandos para recompilar forzosamente `lexer.l` y `rules.y` y ver si `flex` o `bison` (respectivamente) lanzan algún error.

```bash
make rules

make lexer # también re-ejecuta `make rules`
```

## Testeo

**Requiere que `python` esté instalado.**

*Por el momento, sólo hay soporte para tests del analizador léxico y sintáctico, que están en el directorio `tests/lex_sin`*

Se crean tests en el directorio correspondiente: `bad` si debería fallar al procesar al fichero y `good` si no. Una vez creados, se ejecuta el subcomando de `make` correspondiente:

```bash
make test
```

Este comando mostrará los resultados del test y los guardará en el fichero `.test.log`.

***Si no se han producido cambios desde la última vez que se ejecutaron los tests, `make test` no hará nada. En ese caso, se puede mirar directamente el `.test.log`***

Los tests de los que se obtenga el resultado esperado, estarán marcados con un 🟩, y los que no con un 🟥.

Además, si se espera que el test no falle y sí falla, se mostrará el mensaje de error con el que ha fallado.

## POR HACER

**Ignoramos todo lo relacionado con la Tabla de Dominio (`TdD`) porque falta verlo en teoría.**

**A tener en cuenta**

- Al declarar funciones, hay que insertarlas en la tabla de símbolos y tabla de dominio.
- Al declarar variables simples, hay que insertarlas en la tabla de símbolos con referencia REF_SIMPLE.
- Al declarar arrays, hay que insertarlas primero en la tabla de arrays (`TdA`), que devolverá una referencia. Al insertar en la tabla de símbolos, se usa esa referencia.
- Las funciones tienen que insertarse en la TdS antes de analizar el cuerpo para poder hacer recursión. **(Quizás)**.
- Hay que tener en las variables locales `niv` (para el nivel de anidamiento) y `dvar` (desplazamiento de variables) **no se actualizan solas**. Hay que actualizarlas cada vez que añadamos un ámbito / variable.

**Reglas semánticas**
 
- [ ] Todas las variables y funciones deben declararse antes de ser utilizadas.
- [x] Debe haber una función, y solo una, con el nombre main. Esta función determinará el inicio y el fin en la ejecución del programa.
- [ ] La información de los parámetros se situará, en la Tabla de Símbolos, en orden inverso a su declaración.
- [ ] El paso de parámetros se hace siempre por valor.
- [ ] Se admite la recursividad en las funciones.
- [x] El compilador solo trabaja con constantes enteras. Si el analizador léxico encuentra una constante real en el programa debe devolver su valor entero truncado
- [x] El tipo lógico, `bool`, se representa numéricamente como un entero: con el valor 0 para el caso falso y 1 para el caso verdadero.
- [ ] No existe conversión de tipos entre `int` y `bool`.
- [x] La talla de los tipos simples, entero y lógico, debe definirse mediante la constante `TALLA_TIPO_SIMPLE` en el fichero `header.h` del directorio `include`.
- [ ] Los índices de los vectores van de 0 a `cte-1`, siendo cte el número de elementos definido en su declaración. ~~El número de elementos de un vector debe ser un entero positivo.~~
- [ ] En las instrucciones read y write el identificador y la expresión respectivamente deben ser de tipo entero.
- [ ] La instrucción `for` es similar a la del C. Las expresiones opcionales son expresiones, pudiendo no aparecer explíıcitamente, y la expresión debe ser de tipo lógico y debe aparecer explícitamente.
- [ ] La expresión de la instrucción `if-else` debe ser de tipo lógico.
- [ ] La instrucción `switch` evalúa el valor del identificador y selecciona una de las tres posibles ramas de ejecución. Si el valor del identificador es menor que cero se ejecuta la rama `Less`; si es igual a cero se ejecuta la rama `Equal`; y si es mayor que cero se ejecuta la rama `Greater`.

## Autores

- Alejandro Amor Torres
- Alejandro Antelo Fashoro
- César Marqués Jiménez
- Carlos Nácher Abeledo

## Notas

### Parte 1: Analizador léxico y sintáctico.

**Reales vs parámetros**

Por culpa de ambigüedad entre `listParamAct` (que usa comas para separar parámetros) y la definición de las constantes reales (que usa comas para los decimales).

```bash
# NO FUNCIONA
echo "int main() { suma(a,2); return 0; }" | ./bin/main /dev/stdin

# FUNCIONA (espacio añadido)
# Parece que el espacio elimina la ambigüedad entre IDEN(a) COMA_ ENTERO(2) y IDEN(a) REAL(,2)
echo "int main() { suma(a, 2); return 0; }" | ./bin/main /dev/stdin
```

**Operaciones unarias en la asignación**

La definición de `declaVar` es:

```yacc
declaVar: tipoSimp IDEN_ PUNTCOMA_
        | tipoSimp IDEN_ ASIG_ const PUNTCOMA_
        | tipoSimp IDEN_ CORA_ CTE_ CORC_ PUNTCOMA_
        ;
```

Por lo que al declarar variables, en el lado derecho de la asignación, **sólo se pueden utilizar constantes**, es decir, constantes numéricas (el token `CTE_`), `true` o `false`.

Como, de acuerdo a la especificación, las constantes numéricas no pueden incluir el símbolo, expresiones como `int x = -1;` no son válidas, mientras que `int main() { x = -1; return 0; }` sí que lo es porque la asignación, a diferencia de la declaración, sí que permite cualquier tipo de expresión (unarias incluidas).

Esto parece ser un efecto secundario de que el lenguaje, originalmente, no admitía expresiones de ningún tipo, pero si admitía que las constantes numéricas tuviesen signo. En algún punto se cambió esto último, pero siguen sin admitirse expresiones de ningún tipo, ni siquiera las unarias.

Lo más probable es que esto no sea un problema y los profesores lo hayan tenido en cuenta en sus tests, pero a saber.

**¿Identificador o resta?**

Las expresiones (`expre`) pueden contener, entre otras cosas, un identificador o cualquier número de expresiones binarias, las cuales pueden contener a su vez identificadores. Por ejemplo, `valor + 2 * x` es una expresión que contiene operaciones binarias e identificadores, y `valor` es una expresión que sólo contiene un identificador.

El problema es que el símbolo `-` se puede usar para la resta o como carácter válido dentro de un identificador. Los siguientes son (a priori) identificadores válidos:

- `x`
- `x-`
- `x-y`
- `x-y-z`

Los dos últimos son indistinguibles de `x - y` y `x - y - z` si quitamos el espaciado. En ningún momento requerimos que haya espaciado entre expresiones, por lo que no podemos saber si `x-y` es una resta o un identificador.

Ahora mismo, el analizador parece interpretarlo como un identificador, dado el siguiente ejemplo:

```bash
# read sólo permite identificadores, debe fallar
echo "int main() { read(x+y); return 0; }" | ./bin/main /dev/stdin

# aquí funciona (lo interpreta como identificador)
echo "int main() { read(x-y); return 0; }" | ./bin/main /dev/stdin

# aquí falla otra vez por el espaciado
echo "int main() { read(x - y); return 0; }" | ./bin/main /dev/stdin
```

No hay ningún caso en el que sólo se permitan expresiones que no incluyan identificadores, así que de momento no es particularmente problemático. Será más problemático cuando hagamos el análisis semántico y todos los pasos del compilador que vienen después.

### Parte 2: Analizador semántico

**Valores semánticos de los tokens**

En `lexer.l`, además de definir cómo se forman los tokens, podemos definir los **valores semánticos** que van a tener.

El valor semántico de un token se define en `yylval.valor`, donde valor es el tipo de valor semántico que hemos definido en la `%union` de `rules.y`.

Normalmente, calcularemos el valor semántico a partir del texto que corresponde al token, que se puede obtener mediante la variable `yytext`.

Ahora la macro `yield(x)` acepta como segundo argumento un bloque o línea arbitraria en C.

Podemos aprovechar esta macro para establecer los valores semánticos de los distintos tokens. Por ejemplo, para la constante:

```c
yield(CTE_, yylval.cte = atoi(yytext));
// más o menos equivalente a...
yylval.cte = atoi(yytext);
yield(CTE_);
```

**Asignar el tipo de valor semántico a un token o regla**

**No debemos** asignar un valor semántico **sin definir** primero qué valores semánticos existen y cuál de esos se le asigna al token / regla.

Los valores semánticos disponibles se asignan mediante `%union`, que es idéntica una `union` en C. Por ejemplo:

```yacc
%union {
  int cte;
  char * iden;
}
```

De entre esos valores semánticos, debemos indicarle a `bison` cual va a usar nuestro token o regla.
- Regla: `%type tipo_valor regla1 regla2 ...`
- Token: `%token tipo_valor token1 token2 ...`

Por ejemplo:

```yacc
%token <cte> FALSE_ TRUE_ INT_ BOOL_
%type <cte> bool
```

*Sólo asignar un tipo por ítem, así que si hacen falta múltiples se debe usar un `struct`.*

Este tipo de dato es el que se usará cuando hacemos referencia al ítem en la EDTS.

```yacc
bool: TRUE_  { $$ = $1; } // $$ y $1 son cte
    | FALSE_ { $$ = $1; } // $$ y $1 son cte
    ;
```

`$$` es el valor semántico de la parte izquierda de la producción. Nunca vale nada, y sólo usaremos para darle el valor semántico a dicha producción. **Sólo se puede asignar valor a `$$` en la última acción semántica**

*El valor semántico de los tokens **debe darse** en `lexer.l`.*
