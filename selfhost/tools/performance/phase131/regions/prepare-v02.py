"""Compose a bounded checked-Bend layout candidate; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SPEC = importlib.util.spec_from_file_location('p126_compose', ROOT / 'selfhost/tools/performance/phase126/prepare.py')
P = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(P)
PARENT = ROOT / 'selfhost/build/phase130/mode-source01/compiler.bend'
SHA = '995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', default=[])
    parser.add_argument('--override', action='append', default=[])
    args = parser.parse_args()
    assert P.pin(PARENT)['sha256'] == SHA
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131')
    modules = [HERE / 'shallow.bend', HERE / 'controls-v02.bend', HERE / 'virtual-v01.bend', *args.module]
    overrides = {'p128bl_node','p128br_reference',*args.override}
    original = PARENT.read_text()
    result, added, protected = P.compose(original, [p.read_text() for p in modules], overrides, set())
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(result)
    for i, module in enumerate(modules):
        (out / ('module%d.bend' % i)).write_bytes(module.read_bytes())
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    report = dict(complete=True, checked=False, nativeQualified=False, targetsRun=False, selected=False,
        source=P.pin(out / 'compiler.bend'), parent=P.pin(PARENT), overrides=sorted(overrides),
        added=added, protectedDeclarations=protected, physicalLines=len(result.splitlines()),
        parentLines=len(original.splitlines()),
        inputs=[P.pin(__file__), P.pin(SPEC.origin), P.pin(P.DIRECT_VERIFIER), P.pin(PARENT), *map(P.pin,modules)],
        scope='Shallow layout and bounded source specialization of verified virtual reader calls; original pointer-call gates, structural verifiers and runtime unchanged. Additional explicit modules recorded. Source preparation only.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
