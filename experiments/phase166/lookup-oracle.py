#!/usr/bin/env python3
"""Independent literal-result oracle; no compiler or lookup implementation used."""
import argparse
import json

MASK = (1 << 32) - 1


def term(tag, name, ident, quant, begin, end):
    return [tag, name, ident & MASK, quant, [], [], begin, end]


def row(name, ident):
    return [name, "Def", ident & MASK, 3, term("Var", "T", ident, 1, 11, 19),
            term("U32", "", ident, 0, 23, 29), [], False, True]


def absent():
    return ["", "Absent", 0, 0, term("Absent", "", 0, 0, 0, 0),
            term("Absent", "", 0, 0, 0, 0), [], False, False]


def expected_values(i):
    # Literal results, independently specified from the lookup fixture contract.
    names = [("alpha", 1), ("λ.树", 3), ("", 4), None,
             ("costarring", 5), ("liquid", 6), None,
             ("costarring", 5), ("liquid", 6), None,
             ("p111q_value", 17), None, None, ("p111q_values", 18), None,
             ("解析.λ名字", 20), None, ("p113d_candidate", 19)]
    return [absent() if item is None else row(item[0], i + item[1]) for item in names]


def text_words(text):
    for char in text:
        yield 42
        yield ord(char)
    yield 41


def term_words(value):
    tag, name, ident, quant, kids, removed, begin, end = value
    assert not kids and not removed
    yield 31
    yield from text_words(tag)
    yield from text_words(name)
    yield from (ident, quant, 61, 51, begin, end)


def result_words(values):
    for value in values:
        name, kind, arity, templates, typ, body, ctors, native, unsafe = value
        assert not ctors
        yield from (12, 21)
        yield from text_words(name)
        yield from text_words(kind)
        yield from (arity, templates)
        yield from term_words(typ)
        yield from term_words(body)
        yield from (11, int(native), int(unsafe))
    yield 11


def mix(h, word):
    return ((h ^ word) * 16777619) & MASK


def expected(rounds):
    result = 2166136261
    for i in range(rounds):
        values = expected_values(i)
        h, g = 2166136261, 5381
        for word in result_words(values):
            h, g = mix(h, word), (g * 33 + word) & MASK
        for word in (len(values), h, g):
            result = mix(result, word)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--rounds", type=int)
    mode.add_argument("--values", type=int)
    args = parser.parse_args()
    if args.values is not None:
        assert 0 <= args.values <= MASK
        print(json.dumps(expected_values(args.values), ensure_ascii=False))
    else:
        assert 0 <= args.rounds <= 100000
        print(expected(args.rounds))
