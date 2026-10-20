#!/usr/bin/env python3
"""Authenticate exact checked scalar-operands source composition; run no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
INVENTORY_SHA = '199b1005327ea131682e21e4c01f54d9e0c6689b5d56b38744754427a3443b8b'
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def authenticate(row):
    if pin(row['file']) != row:
        raise ValueError('changed frozen input: ' + row['file'])


def blocks(source):
    hits = list(DECL.finditer(source))
    if not hits:
        raise ValueError('empty declaration set')
    result = {}
    for i, match in enumerate(hits):
        key = (match[1], match[2])
        if key in result:
            raise ValueError('duplicate declaration: ' + key[1])
        result[key] = source[match.start():hits[i+1].start() if i+1 < len(hits) else len(source)]
    return source[:hits[0].start()], result


def normalized(source):
    return '\n'.join(line.rstrip() for line in source.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True, help='prepared source directory')
    parser.add_argument('--api-report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase114'):
        raise ValueError('fresh Phase114 output required')
    inventory_file = HERE / 'modules01.json'
    if pin(inventory_file)['sha256'] != INVENTORY_SHA:
        raise ValueError('frozen reviewed inventory changed')
    inventory = json.loads(inventory_file.read_text())
    if inventory['overrides'] != ['p113e_private']:
        raise ValueError('unexpected override inventory')
    inputs = [inventory['base'], inventory['baseAdmission'], inventory['baseApi'],
              inventory['runtimeSource'], inventory['runtimeObject'], *inventory['modules']]
    for row in inputs:
        authenticate(row)
    parent = json.loads(Path(inventory['baseAdmission']['file']).read_text())
    if not parent.get('complete') or not parent.get('admitted'):
        raise ValueError('parent source admission incomplete')
    for key, expected in [('compiler', inventory['base']),
                          ('runtimeSource', inventory['runtimeSource']),
                          ('runtimeObject', inventory['runtimeObject'])]:
        if parent[key] != expected:
            raise ValueError('parent admission mismatch: ' + key)
    prefix, before = blocks(Path(inventory['base']['file']).read_text())
    if not prefix.startswith('import Base\n'):
        raise ValueError('parent import prefix not understood')
    expected = dict(before)
    seen = set()
    for row in inventory['modules']:
        for key, body in blocks(Path(row['file']).read_text())[1].items():
            if key in seen:
                raise ValueError('duplicate module definition: ' + key[1])
            seen.add(key)
            if key in before and key != ('def', 'p113e_private'):
                raise ValueError('unexpected parent override: ' + key[1])
            if key not in before and not key[1].startswith(('p114so_', 'P114SO')):
                raise ValueError('unexpected new declaration: ' + key[1])
            expected[key] = body
    fallback = expected['def', 'p114so_private_original'].replace(
        'def p114so_private_original(', 'def p113e_private(', 1)
    if normalized(fallback) != normalized(before['def', 'p113e_private']):
        raise ValueError('selected original renderer not exactly preserved')
    expected_text = prefix + '\n\n'.join(body.rstrip() for body in expected.values()) + '\n'
    source_dir = args.source.resolve()
    compiler_file = source_dir / 'compiler.bend'
    compiler = pin(compiler_file)
    actual_text = compiler_file.read_text()
    if actual_text != expected_text:
        raise ValueError('source differs from exact frozen composition')
    actual_prefix, actual = blocks(actual_text)
    if actual_prefix != prefix:
        raise ValueError('original import prefix changed')
    preserved = [key for key in before if key != ('def', 'p113e_private')]
    if any(normalized(actual[key]) != normalized(before[key]) for key in preserved):
        raise ValueError('original declaration changed')
    composition_file = source_dir / 'manifest.json'
    composition = json.loads(composition_file.read_text())
    if not composition.get('prepared') or composition['source'] != compiler:
        raise ValueError('source composition receipt mismatch')
    if composition['baseline'] != inventory['base'] or composition['inventory'] != pin(inventory_file):
        raise ValueError('source composition parent mismatch')
    for row in composition['inputs']:
        authenticate(row)
    api_receipt = json.loads(args.api_report.read_text())
    if not (api_receipt.get('complete') and api_receipt.get('checked') and api_receipt.get('status') == 0):
        raise ValueError('successful checked API required')
    if compiler not in api_receipt['inputs']:
        raise ValueError('checked API source mismatch')
    required = ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks', *inventory['exports']]
    if not all(name in api_receipt['exports'] for name in required):
        raise ValueError('missing checked API export')
    authenticate(api_receipt['api'])
    for row in api_receipt['inputs']:
        authenticate(row)
    out.mkdir(parents=True)
    prefix_raw = prefix.encode()
    result = dict(kind='phase114-scalar-operands-source-admission', version=1,
                  complete=True, admitted=True, targetsExecuted=False,
                  compiler=compiler, checkedApi=api_receipt['api'],
                  checkedApiReceipt=pin(args.api_report), inventory=pin(inventory_file),
                  composition=pin(composition_file), parentAdmission=inventory['baseAdmission'],
                  runtimeSource=inventory['runtimeSource'], runtimeObject=inventory['runtimeObject'],
                  modules=inventory['modules'], method=pin(__file__),
                  prefix=dict(bytes=len(prefix_raw), sha256=hashlib.sha256(prefix_raw).hexdigest(), exactlyPreserved=True),
                  declarations=dict(total=len(actual), parentPreserved=len(preserved),
                                    replaced=['p113e_private'], added=len(actual)-len(before)),
                  fallbackExactlyPreserved=True,
                  inputs=[pin(inventory_file), *inputs, pin(composition_file),
                          pin(args.api_report), api_receipt['api'], compiler],
                  executionContract='Only unchanged verified checked-source IR is admitted. Whole-private-function buffer-use audit precedes top-level pure scalar argument bypass. Runtime/public/recursive/width hooks and all other parent declarations remain exact.',
                  limitation='Checked source/factory/runtime correspondence only; this receipt does not claim ordinary-source or native semantic correctness, compiler self-hosting, performance improvement, or selected/default promotion.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, admitted=True, source=compiler, declarations=result['declarations'])))


if __name__ == '__main__':
    main()
