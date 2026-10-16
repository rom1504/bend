#!/usr/bin/env python3
"""Reuse frozen release gates with the current Phase98 baseline; root runs targets."""
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase99_release_baseline', HERE.parent / 'qualification/reuse.py')
Q = importlib.util.module_from_spec(spec); spec.loader.exec_module(Q)
previous_baseline, previous_freeze = Q.support.baseline, Q.support.freeze_methods


def baseline(bindings):
    result = previous_baseline(bindings)
    for file in sorted(HERE.iterdir()):
        if file.is_file(): bindings.bind(file)
    return result


def freeze(out, bindings):
    previous_freeze(out, bindings)
    for file in sorted(HERE.iterdir()):
        if file.is_file():
            bindings.bind(file)
            target = out / 'methods/phase99-release' / file.name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(file.read_bytes()); bindings.bind(target)


Q.support.baseline, Q.support.freeze_methods = baseline, freeze


def main():
    names = ['admit', 'final-controls', 'batch-continuity']
    assert len(sys.argv) > 1 and sys.argv[1] in names, names
    name = sys.argv.pop(1); path = Q.FROZEN / (name + '.py')
    spec = importlib.util.spec_from_file_location('phase99_release_' + name.replace('-', '_'), path)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    module.main()


if __name__ == '__main__': main()
