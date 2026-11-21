"""Produce a source-only candidate. The parent may already contain other orthogonal changes."""
import argparse
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
HOOK = b'case P134Main{}: x187_build_finish(x187_build_seq(x181_program_main(),build))'
ANCHOR = b'@unsafe\ndef x187_output('


def prepare(parent, out):
    old = parent.read_bytes()
    additions = (HERE / 'reverse-fixup.bend').read_bytes().rstrip() + b'\n\n'
    assert old.count(ANCHOR) == old.count(HOOK) == 1 and b'def x201f_' not in old
    source = old.replace(ANCHOR, additions + ANCHOR).replace(HOOK, HOOK.replace(b'x187_build_finish', b'x201f_finish'))
    with out.open('xb') as f:
        f.write(source)
    print(len(source), hashlib.sha256(source).hexdigest())


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    prepare(a.source, a.out)
