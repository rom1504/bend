#!/usr/bin/env python3
"""Generate identical sustained-work Bend inputs for the four compiler roles.

Run from any directory. Existing outputs are never replaced. Arguments to each
generated program are REPETITIONS WARMUPS; missing/invalid fields use 8 and 2.
The four output lines are base oracle, warm digest, measured digest, elapsed ms.
"""
import hashlib
import json
import os
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def source(case):
    imported = os.path.relpath(ROOT / case['source'], HERE).replace(os.sep, '/')
    size, seed = case['size'], case['seed']
    return f'''# Phase46 common JS/C workload. Source SHA256: {case['sha256']}
# Arguments: repetitions warmups; read last two values across IO.args ABIs.
# Input schedule repeats every 16 iterations; digest observes every return.
# Time includes measured checksum formatting/print, forcing full observation.
import Base
import {imported} as W

def p46.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{{}}:
      fallback
    case Some{{n}}:
      n

def p46.number(text: String, fallback: Nat) -> Nat:
  p46.parsed(Nat.read(text), fallback)

def p46.warm(args: List<String>) -> Nat:
  match args:
    case Nil{{}}:
      2n
    case value <> rest:
      p46.number(value, 2n)

def p46.options(args: List<String>) -> Nat & Nat:
  match args:
    case Nil{{}}:
      (8n, 2n)
    case value <> rest:
      (p46.number(value, 8n), p46.warm(rest))

def p46.arguments(args: List<String>) -> Nat & Nat:
  match args:
    case first <> second <> Nil{{}}:
      (p46.number(first, 8n), p46.number(second, 2n))
    case head <> rest:
      p46.arguments(rest)
    case Nil{{}}:
      (8n, 2n)

def p46.loop(n: Nat, +i: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      v = W.bench(U32.add({size}, U32.and(i, 1)), U32.add({seed}, U32.and(i, 15)))
      p46.loop(p, U32.inc(i), U32.xor(U32.mul(h, 16777619), U32.add(v, i)))

def p46.batch(n: Nat) -> U32:
  p46.loop(n, 0, 2166136261)

def p46.run(options: Nat & Nat) -> IO(Unit):
  (repetitions, warmups) = options
  do IO<Unit>:
    Unit <- IO.print(U32.show(W.bench({size}, {seed})))
    Unit <- IO.print(U32.show(p46.batch(warmups)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p46.batch(repetitions)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p46.run(p46.arguments(args))
'''


def main():
    cases = json.loads((HERE / 'cases.json').read_text())
    outputs = []
    for case in cases:
        assert re.fullmatch(r'[a-z][a-z0-9-]*', case['name'])
        assert all(type(case[key]) is int and 0 <= case[key] <= 0xffffffff
                   for key in ('size', 'seed', 'expected'))
        data = (ROOT / case['source']).read_bytes()
        assert hashlib.sha256(data).hexdigest() == case['sha256'], case['name']
        output = HERE / (case['name'] + '-batch.bend')
        if output.exists():
            raise FileExistsError('Refusing to replace existing output: ' + str(output))
        outputs.append((output, source(case)))
    assert len({file for file, _ in outputs}) == len(outputs)
    for file, text in outputs:
        with file.open('x') as stream:
            stream.write(text)
        print(file.relative_to(ROOT))


if __name__ == '__main__':
    main()
