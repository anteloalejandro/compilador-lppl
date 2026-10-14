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
