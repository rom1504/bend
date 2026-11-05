#!/usr/bin/env python3
"""Add exact source-relative bendc effect inputs; no compiler or target runs."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
VENDOR = ROOT / 'selfhost/build/phase158/current'
MANIFEST = ROOT / 'selfhost/build/phase158/current-manifest.json'
MANIFEST_SHA = 'b63a33e71ea3d3ee23c8a052f9e718cc8e9125b14b8a857dc6bf1525502fc983'
MAIN_SHA = '72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99'
MODULES = {'bendc.bend', 'check.bend', 'core.bend', 'asm.bend', 'rt/rtjs.bend', 'rt/rtchan.bend'}
EFFECTS = {'rt/hub.c', 'rt/hub.js', 'rt/cc.c', 'rt/cc.js'}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin(path):
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source-tree', type=Path, action='append', required=True)
    p.add_argument('--out', type=Path, required=True, help='Fresh directory for additive receipt')
    a = p.parse_args()
    out = a.out.resolve()
    area = ROOT / 'selfhost/build/phase165'
    require(out.is_relative_to(area) and not out.exists(), 'output must be fresh under phase165')
    require(pin(MANIFEST)['sha256'] == MANIFEST_SHA, 'vendor manifest pin mismatch')
    entries = {e['file']: e for e in json.loads(MANIFEST.read_text())['files']}
    assets = {}
    for name in sorted(EFFECTS):
        source = VENDOR / name
        identity = pin(source)
        require(all(identity[k] == entries[name][k] for k in ('bytes', 'sha256')), 'effect pin mismatch: ' + name)
        data = source.read_bytes()
        # These exact pinned C/JS files contain no further source-relative include/import.
        require(not re.search(rb'(?m)^\s*#\s*include\s*"', data), 'unhandled local C include')
        require(not re.search(rb'(?m)^\s*import\b', data), 'unhandled JS import')
        assets[name] = (data, identity)
    trees = []
    for raw in a.source_tree:
        tree = raw.resolve()
        require(tree.is_relative_to(area) and tree.is_dir(), 'source tree outside private phase165 area')
        files = {str(f.relative_to(tree)) for f in tree.rglob('*.bend')}
        require(files == MODULES, 'unexpected Bend module inventory')
        require(pin(tree / 'bendc.bend')['sha256'] == MAIN_SHA, 'main compiler module changed')
        inputs = [pin(tree / n) for n in sorted(MODULES)]
        refs = []
        for name in sorted(MODULES):
            for line, text in enumerate((tree / name).read_text().splitlines(), 1):
                match = re.fullmatch(r'\s*import "(\./[^"\n]+)"\s*', text)
                if match:
                    path = Path(name).parent / match[1][2:]
                    require('..' not in path.parts, 'effect import escapes source tree')
                    refs.append({'module': name, 'line': line, 'effect': str(path)})
        require({r['effect'] for r in refs} == EFFECTS and len(refs) == 10, 'foreign import inventory changed')
        require(all(not (tree / n).exists() for n in EFFECTS), 'refuse overwriting an existing effect')
        trees.append({'tree': str(tree), 'bendInputs': inputs, 'foreignImports': refs})
    # Validate the complete plan before adding any files. Existing receipts are untouched.
    out.mkdir(parents=True)
    for record in trees:
        tree = Path(record['tree'])
        for name, (data, _) in assets.items():
            (tree / name).write_bytes(data)
        record['added'] = [pin(tree / n) for n in sorted(EFFECTS)]
        for identity in record['bendInputs']:
            require(pin(Path(identity['file'])) == identity, 'Bend bytes changed')
        for identity in record['added']:
            name = str(Path(identity['file']).relative_to(tree))
            require(all(identity[k] == assets[name][1][k] for k in ('bytes', 'sha256')), 'copied effect mismatch')
    receipt = {'kind': 'phase165-additive-source-effects', 'complete': True, 'targetsRun': False,
               'method': pin(Path(__file__).resolve()), 'vendorManifest': pin(MANIFEST),
               'inputs': [identity for _, identity in assets.values()], 'trees': trees,
               'scope': 'Complete four-file source-relative effect import closure for pinned six-module bendc C/JS emission. Existing Bend modules, Base assets and preparation manifests unchanged. Machine runtime remains separately pinned by acquisition; optional -o/--native external toolchain support is not claimed.'}
    path = out / 'report.json'
    path.write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'complete': True, 'trees': len(trees), 'addedPerTree': len(EFFECTS), 'receipt': pin(path)}))


if __name__ == '__main__':
    main()
