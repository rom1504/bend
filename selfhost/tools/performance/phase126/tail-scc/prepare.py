"""Exact declaration composition onto an authenticated parent; no compiler run."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
METHOD = ROOT / 'selfhost/tools/performance/phase126/prepare.py'
spec = importlib.util.spec_from_file_location('p126_prepare', METHOD)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def verify(record):
    if P.pin(record['file']) != record:
        raise ValueError('Changed input: ' + record['file'])


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--parent', type=Path, required=True)
    ap.add_argument('--modules', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    parent = json.loads(args.parent.read_text())
    inventory = json.loads(args.modules.read_text())
    if not (parent.get('complete') and inventory.get('complete')):
        raise ValueError('Complete parent and frozen inventory required')
    if P.pin(args.parent) != inventory['parentManifest'] or parent['source'] != inventory['parent']:
        raise ValueError('Exact frozen parent required')
    if inventory['overrides'] != ['p113pl_plan']:
        raise ValueError('Only p113pl_plan may be replaced')
    pins = [P.pin(__file__), P.pin(METHOD), P.pin(args.modules), P.pin(args.parent),
            parent['source'], *parent['inputs'], *inventory['modules'], inventory['originalPlan']]
    for item in pins:
        verify(item)
    text = Path(parent['source']['file']).read_text()
    original = Path(inventory['originalPlan']['file']).read_text()
    if P.norm(P.blocks(text)['p113pl_plan']) != P.norm(P.blocks(original)['p113pl_plan']):
        raise ValueError('Original candidate plan changed')
    modules = [Path(x['file']).read_text() for x in inventory['modules']]
    result, added, protected = P.compose(text, modules, {'p113pl_plan'}, set())
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase126'):
        raise ValueError('Fresh Phase126 output required')
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(result)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i, item in enumerate(inventory['modules']):
        (out / f'module{i}.bend').write_bytes(Path(item['file']).read_bytes())
    report = dict(kind='phase126-tail-scc-source', complete=True, checked=False, targetsRun=False,
                  source=P.pin(out / 'compiler.bend'), parent=parent['source'],
                  parentManifest=P.pin(args.parent), moduleInventory=P.pin(args.modules),
                  modules=inventory['modules'], overrides=['p113pl_plan'], moduleOverrides=[],
                  added=added, protectedDeclarations=protected, inputs=pins,
                  allOtherOriginalDeclarationsUnchanged=True,
                  scope='Exact existing-IR tail SCC candidate factory; same original verifier, runtime and emitter. No target runs or new native qualification.')
    if 'runtimeExtension' in parent:
        report['runtimeExtension'] = parent['runtimeExtension']
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
