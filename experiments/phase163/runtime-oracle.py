#!/usr/bin/env python3
"""Independent expected digest; never loads or executes a compiler/program."""
import argparse
import json


def text_words(text):
    for char in text:
        yield 42
        yield ord(char)
    yield 41


def term_words(tag, name, ident, quant, begin, end):
    yield 31
    yield from text_words(tag)
    yield from text_words(name)
    yield ident
    yield quant
    yield 61  # empty children
    yield 51  # empty removed-name list
    yield begin
    yield end


def row_words(name, ident, absent=False):
    yield 21
    yield from text_words(name)
    yield from text_words("Absent" if absent else "Def")
    yield ident
    yield 0 if absent else 3
    if absent:
        yield from term_words("Absent", "", 0, 0, 0, 0)
        yield from term_words("Absent", "", 0, 0, 0, 0)
    else:
        yield from term_words("Var", "T", ident, 1, 11, 19)
        yield from term_words("U32", "", ident, 0, 23, 29)
    yield 11  # empty constructor list
    yield 0   # native
    yield 0 if absent else 1  # unsafe


def result_words(kind, repeat):
    for step in reversed(range(repeat)):
        i = 8 * step
        if kind == "reverse":
            rows = [("", i + 4, False), ("λ.树", i + 3, False),
                    ("alpha", i + 2, False), ("alpha", i + 1, False)]
        else:
            rows = [("alpha", i + 1, False), ("λ.树", i + 3, False),
                    ("", i + 4, False), ("", 0, True),
                    ("costarring", i + 5, False), ("liquid", i + 6, False),
                    ("", 0, True), ("costarring", i + 5, False),
                    ("liquid", i + 6, False), ("", 0, True)]
        for row in rows:
            yield 12
            yield from row_words(*row)
    yield 11


def expected(kind, repeat):
    if not 0 <= repeat <= 100000:
        raise ValueError("repeat must be 0..100000 for this bounded fixture oracle")
    h, g = 2166136261, 5381
    for word in result_words(kind, repeat):
        h = ((h ^ word) * 16777619) & 0xFFFFFFFF
        g = (g * 33 + word) & 0xFFFFFFFF
    return [(4 if kind == "reverse" else 10) * repeat, h, g]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=["reverse", "lookup"])
    parser.add_argument("repeat", type=int)
    args = parser.parse_args()
    print(json.dumps(expected(args.kind, args.repeat), separators=(",", ":")))
