#!/usr/bin/env python3
"""Run an unchanged frozen gate with Phase99's explicit current-Phase98 baseline.

The ordinary reuse.py entry remains preferred. This exposes four frozen gates
that it does not list; no acceptance condition or target resource bound changes.
Only the coordinator executes target-bearing modes.
"""
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REUSE = HERE.parent / 'phase99/qualification/reuse.py'
spec = importlib.util.spec_from_file_location('phase102_qualification_reuse', REUSE)
Q = importlib.util.module_from_spec(spec)
spec.loader.exec_module(Q)

old_baseline = Q.support.baseline
old_freeze = Q.support.freeze_methods


def baseline(bindings):
    bindings.bind(__file__)
    return old_baseline(bindings)


def freeze(out, bindings):
    old_freeze(out, bindings)
    bindings.bind(__file__)
    target = out / 'methods/phase102/qualification-method.py'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(Path(__file__).read_bytes())
    bindings.bind(target)


def main():
    names = {'request-v2', 'final-controls', 'batch-continuity', 'admit'}
    assert len(sys.argv) > 1 and sys.argv[1] in names, sorted(names)
    name = sys.argv.pop(1)
    Q.support.baseline = baseline
    Q.support.freeze_methods = freeze
    method = Q.FROZEN / (name + '.py')
    spec = importlib.util.spec_from_file_location('phase102_frozen_' + name.replace('-', '_'), method)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.main()


if __name__ == '__main__':
    main()
