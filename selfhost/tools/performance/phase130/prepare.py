"""Compose exact Bend declarations over qualified Phase128; no semantic lowering."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
SPEC = importlib.util.spec_from_file_location('p126_compose', ROOT / 'selfhost/tools/performance/phase126/prepare.py')
P = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(P)
PARENT = ROOT / 'selfhost/build/phase128/native-source02/compiler.bend'
SHA = '6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', required=True)
    parser.add_argument('--overrides', nargs='*', required=True)
    args = parser.parse_args()
    assert P.pin(PARENT)['sha256'] == SHA
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase130')
    modules = [p.resolve() for p in args.module]
    assert len(modules) == len(set(modules))
    original = PARENT.read_text()
    result, added, protected = P.compose(original, [p.read_text() for p in modules], set(args.overrides), set())
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(result)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i, module in enumerate(modules):
        (out / ('module%d.bend' % i)).write_bytes(module.read_bytes())
    report = dict(complete=True, checked=False, nativeQualified=False, targetsRun=False, selected=False,
                  source=P.pin(out / 'compiler.bend'), parent=P.pin(PARENT), overrides=args.overrides,
                  added=added, protectedDeclarations=protected,
                  inputs=[P.pin(__file__), P.pin(SPEC.origin), P.pin(P.DIRECT_VERIFIER), P.pin(PARENT),
                          *[P.pin(p) for p in modules]], physicalLines=len(result.splitlines()),
                  parentLines=len(original.splitlines()),
                  scope='Exact declaration composition only; new checked API, semantic gates and native qualification required.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
