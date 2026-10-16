#!/usr/bin/env python3
"""Reuse the pinned Phase98 archive algorithm with Phase99 roots/schema names."""
import ast
import hashlib
from pathlib import Path

PARENT = Path(__file__).resolve().parents[1] / 'phase98/evidence.py'
PARENT_SHA256 = '2afa092b9219e9ac8d5640d2167abd668d3e2cf4f2dacb331e90867f9c4ce35b'


def main():
    raw = PARENT.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == PARENT_SHA256, 'Archive parent method changed'
    original = raw.decode()
    assert 'phase99' not in original and 'Phase99' not in original
    derived = original.replace('phase98', 'phase99').replace('Phase98', 'Phase99')
    # Changes are phase names in string literals; the archive algorithm is exact.
    class RestoreNames(ast.NodeTransformer):
        def visit_Constant(self, node):
            if isinstance(node.value, str):
                node.value = node.value.replace('phase99', 'phase98').replace('Phase99', 'Phase98')
            return node
    assert ast.dump(RestoreNames().visit(ast.parse(derived))) == ast.dump(ast.parse(original))
    namespace = dict(__file__=str(Path(__file__).resolve()), __name__='phase99_evidence')
    exec(compile(derived, str(PARENT), 'exec'), namespace)
    namespace['main']()


if __name__ == '__main__': main()
