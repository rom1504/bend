#!/usr/bin/env python3
"""Bind an already checked API to its exact frontend declaration closure. No targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, require, verify, write_json

ROOTS = ['p88_cache_prepare', 'p86_plan']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assembly', type=Path, required=True)
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assembly = json.loads(args.assembly.read_text())
    receipt = json.loads(args.receipt.read_text())
    require(assembly.get('kind') == 'phase171-api-source' and assembly.get('complete') and
            assembly.get('protectedUnchanged'), 'Successful protected assembly required')
    require(receipt.get('kind') == 'bend-checked-hosted-api' and receipt.get('complete') and
            receipt.get('checked') and not receipt.get('error'), 'Successful checked acquisition required')
    require(assembly['source'] == receipt['source'], 'Acquisition does not match assembly')
    require(assembly['exports'] == receipt['exports'], 'Acquisition export contract differs')
    require(all(name in receipt['exports'] for name in ROOTS), 'Frontend exports absent')
    extractor_file = ROOT / 'experiments/phase147/tools/prepare.py'
    spec = importlib.util.spec_from_file_location('phase173_frontend_extract', extractor_file)
    extractor = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(extractor)
    source_module = ROOT / 'selfhost/tools/build/source.py'
    inputs = [pin(__file__), pin(extractor_file), pin(source_module), pin(args.assembly),
              pin(args.receipt), assembly['source'], assembly['binding'], receipt['api']]
    inputs.extend(assembly['inputs'])
    inputs.extend(receipt['inputs'])
    binding = json.loads(Path(assembly['binding']['file']).read_text())
    require(binding.get('kind') == 'phase171-prepared-base' and binding.get('version') == 1,
            'Prepared Base binding required')
    inputs.extend(binding[key] for key in ['assets', 'base', 'carrier', 'engine'])
    for item in inputs:
        verify(item)
    body, rows = extractor.extract([('frontend', Path(assembly['source']['file']).read_bytes())], ROOTS)
    declarations = [{key: row[key] for key in ['kind', 'name', 'bytes', 'sha256']} for row in rows]
    encoded = json.dumps(declarations, ensure_ascii=False, separators=(',', ':')).encode()
    fingerprint = dict(sha256=hashlib.sha256(encoded).hexdigest(), declarations=len(rows), bytes=len(body))
    upstream = receipt['upstream']
    boundary_files = {str(ROOT/'selfhost/tools/build/hosted.mjs'),
                      str(ROOT/'selfhost/tools/stage0-library.mjs'), binding['engine']['file']}
    boundary = sorted((item for item in receipt['inputs'] if
                       item['file'].startswith(upstream['file'] + '/') or item['file'] in boundary_files),
                      key=lambda item: item['file'])
    required_boundary = boundary_files | {upstream['file'] + '/bend2/' + name for name in
                                          ['bend.ts', 'comp.ts', 'base.bend']}
    require(required_boundary.issubset({item['file'] for item in boundary}), 'Acquisition ABI inputs absent')
    boundary_bytes = json.dumps(dict(upstream=upstream, inputs=boundary), ensure_ascii=False,
                               separators=(',', ':')).encode()
    boundary_hash = hashlib.sha256(boundary_bytes).hexdigest()
    for item in inputs:
        verify(item)
    out = fresh_output(args.out, ROOT)
    report = dict(kind='phase173-frontend-binding', version=1, complete=True, targetsRun=False,
                  roots=ROOTS, fingerprint=fingerprint, declarations=declarations,
                  acquisitionBoundary=dict(upstream=upstream, inputs=boundary, sha256=boundary_hash),
                  assembly=pin(args.assembly), acquisition=pin(args.receipt),
                  source=assembly['source'], api=receipt['api'], binding=assembly['binding'],
                  base=binding['base'], carrier=binding['carrier'], stamp=binding['stamp'],
                  engine=binding['engine'], inputs=inputs,
                  scope='Conservative exact source-declaration identity only. Checked API acquisition '
                        'is separately authenticated; this tool does not execute or verify Bend.')
    write_json(out/'binding.json', report)
    print(json.dumps(dict(binding=pin(out/'binding.json'), fingerprint=fingerprint, targetsRun=False)))


if __name__ == '__main__':
    main()
