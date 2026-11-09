#!/bin/python3

import os
import re
import subprocess
from argparse import ArgumentParser

# INICIALIZACIÓN

parser = ArgumentParser()
parser.add_argument(
    "-v", "--verbose", action="store_true",
    help="Muestra los errores de los tests que fallan"
)
args = parser.parse_args()

VERBOSE = args.verbose

cwd = __file__[:__file__.rfind(os.sep)]


main = os.path.join(".", cwd, "..", "bin", "main")
if not os.path.exists(main):
    print("DEBES COMPILAR EL PROYECTO PRIMERO")
    exit(-1)

success = "🟩"
failure = "🟥"

# HELPERS

def tab_print(s: str, level = 1, tab = " " * 4):
    for line in s.strip().splitlines():
        print(tab + line)

def get_expected_errors(path: str) -> int:
    """
    Saca el número de errores de un comentario en la cabecera de la forma:
    // ... : 10 errores
    """

    with open(path, "r") as f:
        content = f.readline()

    content = content[content.find(":")+1:]
    match = re.search(r"\d+", content)
    if match is None: return 0
    return int(match.group(0))

def test(dir: str, show_error: bool) -> int:
    failed_test_count = 0;

    for test in sorted(os.listdir(dir)):
        path = os.path.join(dir, test)
        expected_errors = get_expected_errors(path)
        result = subprocess.run(
            [main, path],
            capture_output=True,
            text=True
        )

        error_count = result.returncode;
        b = error_count == expected_errors

        print(success if b else failure, os.path.relpath(path, start=cwd), end = "")
        if error_count == -1:
            print(f" → Mal uso del compilador")
        elif error_count == -11:
            print(f" → SEGFAULT")
        elif not b:
            print(f" → Esperaba {expected_errors} errores, hubo {error_count}")
        else:
            print()

        if show_error:
            tab_print(result.stdout)
            tab_print(result.stderr)

        if not b: failed_test_count = failed_test_count + 1;

    return failed_test_count

# TESTEO

errors = 0

errors = errors + test(f"{cwd}/corpus", VERBOSE)

if errors > 0: print(f"\n{errors} tests fallidos")

exit(errors)
