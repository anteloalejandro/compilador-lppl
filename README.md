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

## Autores

- Alejandro Amor Torres
- Alejandro Antelo Fashoro
- César Marqués Jiménez
- Carlos Nácher Abeledo

## Notas

Tenemos problemitas. Resulta que hay ambigüedades en el documento que nos resolverán en algún momento. Notablemente:

- Las palabras clave, a priori, son en minúscula. Esto incluye las que están explícitamente definidas en mayúscula como `SWITCH`.

- Las constantes dice en un sitio que son enteras, y en otro que son reales. Aparentemente son reales. Ponerlas como reales tal y como indica en el PDF rompe algunos tests por la gracieta de que usa comas en lugar de puntos (por ejemplo, se confunde en las listas de parámetros de las funciones).

- El PDF indica que los símbolos de las constantes (+1, -1) no forman parte de la constante. Pero parece ser que tienen que poder ponerse, aunque no está definido en ningún lugar cómo.

- Tenemos que tener en cuenta que, como los identificadores pueden llevar `-`, es posible que no podamos diferenciar entre restas entre identificadores y un identificador separado por `-` (a-b puede ser la resta `a - b` o un identificador `a-b`). **Esto no debería dar (demasiados) problemas ahora, pero dará problemas en el analizador semántico.**

### Ejemplos

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
