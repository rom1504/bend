"""Immutable declaration composition; all compiler semantics remain in Bend."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
SPEC = importlib.util.spec_from_file_location('phase126_prepare', ROOT / 'selfhost/tools/performance/phase126/prepare.py')
P = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(P)
PARENT = ROOT / 'selfhost/build/phase127/live-bank-source01/compiler.bend'
PARENT_SHA = 'f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', required=True)
    parser.add_argument('--overrides', nargs='*', required=True)
    args = parser.parse_args()
    if P.pin(PARENT)['sha256'] != PARENT_SHA:
        raise ValueError('Changed frozen Phase127 parent')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase128'):
        raise ValueError('Fresh Phase128 directory required')
    modules = [p.resolve() for p in args.module]
    if len(set(modules)) != len(modules):
        raise ValueError('Repeated module')
    before = PARENT.read_text()
    after, added, protected = P.compose(before, [p.read_text() for p in modules], set(args.overrides), set())
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(after)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i, module in enumerate(modules):
        (out / f'module{i}.bend').write_bytes(module.read_bytes())
    report = dict(complete=True, checked=False, targetsRun=False, selected=False,
        source=P.pin(out / 'compiler.bend'), parent=P.pin(PARENT),
        overrides=args.overrides, added=added, protectedDeclarations=protected,
        physicalLines=len(after.splitlines()), parentLines=len(before.splitlines()),
        inputs=[P.pin(__file__), P.pin(SPEC.origin), P.pin(P.DIRECT_VERIFIER),
                P.pin(PARENT), P.pin(PARENT.parent / 'manifest.json'), *[P.pin(p) for p in modules]],
        scope='Checked-Bend declaration overlay only; no semantic lowering, execution or promotion.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
