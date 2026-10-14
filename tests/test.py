#!/bin/python3

import os
import subprocess
from argparse import ArgumentParser

# INICIALIZACIÓN

parser = ArgumentParser()
parser.add_argument(
    "-v", "--verbose", action="store_true",
    help="Muestra los errores también en los tests 'bad'"
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
    for line in s.splitlines():
        print(tab + line)

def test(dir: str, expect_failure: bool, show_error: bool) -> bool:
    test_success = True

    for test in os.listdir(dir):
        path = os.path.join(dir, test)
        result = subprocess.run(
            [main, path],
            capture_output=True,
            text=True
        )

        # expected_failure ; return_code == 0 ; b
        # -----------------;------------------;--
        # F                ; F                ; F
        # F                ; T                ; T
        # T                ; F                ; T
        # T                ; T                ; F
        b = expect_failure ^ result.returncode == 0

        print(success if b else failure, os.path.relpath(path, start=cwd))

        if show_error:
            tab_print(result.stderr)
            print()

        test_success = test_success and b

    return test_success

# TESTEO

good_dir = os.path.join(cwd, "lex_sin", "good")
bad_dir = os.path.join(cwd, "lex_sin", "bad")

result = True

result = result and test(good_dir, False, True)
result = result and test(bad_dir, True, VERBOSE)

exit(0 if result else 1)
