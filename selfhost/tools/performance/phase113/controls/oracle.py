#!/usr/bin/env python3
"""Independent finite expectations; never imports or executes a Bend compiler.

The scalar recurrence uses mathematical integers reduced modulo 2**32. Product
and ownership expectations are literal observations of specified source inputs.
Outputs are complete IO.print transcripts, including final LF and empty stderr.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def recurrence(n, seed):
    for _ in range(n):
        seed = (1664525 * seed + 1013904223) % (2**32)
    return seed


def transcript(values):
    return "".join(str(x)+"\n" for x in values)


def expectations():
    # Arithmetic only; no compiler's AST, IR, generated code or candidate output.
    closed = [recurrence(n,s) for n,s in ((0,0),(1,0),(31,0),(257,7),(100001,123))]
    branches = []
    for high, x in ((True,0),(False,0),(True,2**32-1),(False,2**32-1)):
        y = (x-1 if high else x*17) % (2**32)
        branches.append(((y+9) % (2**32)) ^ 85)
    values = {
        "scalar-closed-loop": closed,
        "tail-argument-permutation": [123,231,312,312],
        "closed-branch-suffix": branches,
        "scalar-shadow-nested-arguments": [567,12],
        "array-scalar-return": [107,17,7],
        "array-shared-swaps": [5,9,9,5],
        "string-field-alias": ["leftλ","λtfel",20,"λtfel","leftλ"],
        "owned-capture-call": ["key=🙂41","key=🙂","key=🙂7","key=🙂"],
        "non-tail-reconstruction": [0,0,57],
        "product-escape-branch": ["L=α7","R=β12"],
        "lazy-branch-no-overflow": [7],
    }
    result = {name:dict(status=0,stdout=transcript(v),stderr="") for name,v in values.items()}
    result["strict-unused-overflow"] = dict(status=1, stdout="", stderr="bend: a Nat past the largest immediate 2^48-1\n")
    return result


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="write new oracle files; refuses existing files")
    args=parser.parse_args()
    expected=expectations()
    for name, value in expected.items():
        path=HERE/"expected"/(name+".json")
        stdout=HERE/"expected"/(name+".stdout")
        if args.write:
            if path.exists() or stdout.exists():
                raise ValueError("Oracle output already exists: "+name)
            path.parent.mkdir(exist_ok=True)
            path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+"\n")
            stdout.write_text(value["stdout"])
        else:
            assert json.loads(path.read_text()) == value, "Expectation changed: "+name
            assert stdout.read_text() == value["stdout"], "Stdout changed: "+name
    print(json.dumps(dict(complete=True, cases=len(expected), targetsRun=False, method=pin(Path(__file__)))))


if __name__ == "__main__":
    main()
