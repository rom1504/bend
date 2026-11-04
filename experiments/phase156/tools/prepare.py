#!/usr/bin/env python3
"""Exact checked-source extraction and root-owned plans; no target execution."""
import argparse
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, write_json
spec = importlib.util.spec_from_file_location('extract156', ROOT/'experiments/phase147/tools/prepare.py')
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


def rewrite(data, mapping):
    # Replace only whole identifier tokens, outside strings/chars/comments.
    pattern = re.compile(r'''"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\#[^\n]*|\b[A-Za-z_][A-Za-z0-9_.]*\b''')
    return pattern.sub(lambda m: mapping.get(m.group(), m.group()), data.decode()).encode()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--stage', choices=['controls', 'request'], required=True)
    parser.add_argument('--module', action='append', default=[])
    parser.add_argument('--export', action='append', default=[])
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    manifest = ROOT/'selfhost/src/compiler.json'
    qfile = ROOT/'implementation/phase152/qualification.json'
    qualified = json.loads(qfile.read_text())
    canonical = assembly.maintained_assemble(manifest, ROOT/'selfhost', 'qbe')
    require(hashlib.sha256(canonical).hexdigest() == qualified['source']['sha256'], 'Qualified canonical source changed')
    _, original = assembly.blocks(canonical)
    original = [r for r in original if r['name'] != 'main']
    overrides, extra, replacements = [], [], set()
    inputs = [pin(__file__), pin(E.__file__), pin(assembly.__file__), pin(manifest), pin(qfile)]
    original_names = {r['name'] for r in original}
    for name in args.module:
        path = ROOT/name
        _, rows = assembly.blocks(path.read_bytes())
        inputs.append(pin(path))
        for row in rows:
            if row['name'] in original_names:
                require(row['name'] in ('p113pl_bind_flat','p143cp_seed_ready','p143cb_resume_state'), 'Unexpected replacement')
                require(row['name'] not in replacements, 'Duplicate override')
                overrides.append(row)
                replacements.add(row['name'])
            else:
                extra.append(row)
    # Preserve original implementations in a renamed dependency closure. Share
    # types and unaffected helpers; the inverse mapping must reproduce exact bytes.
    functions = {}
    for row in original:
        if row['kind'] != 'type': functions.setdefault(row['name'], []).append(row)
    affected = set(replacements)
    while True:
        added = {name for name, rows in functions.items()
                 if any(E.referenced_words(row['data']) & affected for row in rows)} - affected
        if not added: break
        affected |= added
    mapping = {name: 'p156o_'+name for name in affected}
    reverse = {v:k for k,v in mapping.items()}
    clones = []
    for row in original:
        if row['name'] in affected and row['kind'] != 'type':
            changed = rewrite(row['data'], mapping)
            require(rewrite(changed, reverse) == row['data'], 'Clone inverse differs')
            clones.append(changed)
    candidate = b''.join(r['data'] for r in original if r['name'] not in replacements)
    candidate += b'\n'+b'\n'.join(r['data'] for r in overrides+extra)
    parts = [('candidate', candidate), ('original-ancestors', b'\n'.join(clones))]
    exports = list(dict.fromkeys(args.export))
    roots = list(exports)
    if args.stage == 'request': roots.append('main')
    require(bool(roots), 'Explicit roots required')
    body, declarations = E.extract(parts, roots, 2_600_000)
    out = fresh_output(args.out, ROOT)
    (out/'compiler.bend').write_bytes(body)
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1, exports=exports,
        protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],
        scope='Private Phase156 source-controlled transfer; no installed image selection.'))
    checked, native = out/'checked-api', out/'native'
    jobs = [E.guard('phase156-check',checked,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs',
        'acquire','--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
        '--engine',ROOT/'selfhost/.assets/bin/bun','--out',checked],180,2048,256)]
    if args.stage == 'request':
        jobs.append(E.guard('phase156-native',native,['python3','-B',ROOT/'selfhost/tools/build/native.py',
            '--assets',ROOT/'selfhost/manifests/assets-native.json','--host','native','--stage','N2','--target','qbe','--mode','cache',
            '--image',ROOT/'selfhost/build/phase152/native-n2/program','--image-receipt',ROOT/'selfhost/build/phase152/native-n2/report.json',
            '--source',out/'compiler.bend','--out',native,'--retain-ir','--seconds','300'],320,2048,512))
    report = dict(kind='phase156-transfer-preparation',complete=True,targetsRun=False,stage=args.stage,
        canonicalSource=qualified['source'],source=pin(out/'compiler.bend'),inputs=inputs,
        replacements=sorted(replacements),clonedNames=sorted(affected),declarations=declarations,
        exports=exports,apiReport=str(checked/'report.json'),binary=str(native/'program'),buildReport=str(native/'report.json'),jobs=jobs)
    write_json(out/'manifest.json',report);write_json(out/'jobs.json',jobs)
    print(json.dumps(dict(source=report['source'],declarations=len(declarations),clonedNames=len(affected),replacements=sorted(replacements))))


if __name__ == '__main__': main()
