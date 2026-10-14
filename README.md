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
- Las constantes dice en un sitio que son enteras, y en otro que son reales. Aparente son reales. Ponerlas como reales tal y como indica en el PDF rompe básicamente todos los tests, por la gracieta de que usa comas en lugar de puntos (por ejemplo, se confunde en las listas de parámetros de las funcioens).
- El PDF indica que los símbolos de las constantes (+1, -1) no forman parte de la constante. Pero parece ser que tienen que poder ponerse, aunque no está definido en ningún lugar cómo.
- Tenemos que tener en cuenta que, como los identificadores pueden llevar `-`, es posible que no podamos diferenciar entre restas entre identificadores y un identificador separado por `-` (a-b puede ser la resta `a - b` o un identificador `a-b`).

Muchos tests, aplicando preventivamente estos cambios... Petan.
