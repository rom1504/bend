#!/usr/bin/env python3
"""Exact checked combined01 + complete-bridge admission; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
INVENTORY_SHA = '80628d45cdc06aafa958871e728f64e1392b1413ebda330b393c5ae80b265804'
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def authenticate(row):
    if pin(row['file']) != row:
        raise ValueError('changed frozen input: ' + row['file'])


def code(text):
    return '\n'.join(line.rstrip() for line in text.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def declarations(text):
    hits = list(DECL.finditer(text))
    result = {}
    for i, match in enumerate(hits):
        key = (match.group(1), match.group(2))
        if key in result:
            raise ValueError('duplicate declaration: ' + str(key))
        end = hits[i + 1].start() if i + 1 < len(hits) else len(text)
        result[key] = code(text[match.start():end])
    if not result:
        raise ValueError('empty source')
    return result


def validate(actual, expected):
    if actual.keys() != expected.keys():
        raise ValueError('declaration set changed')
    wrong = [name for (kind, name), value in expected.items() if actual[kind, name] != value]
    if wrong:
        raise ValueError('changed final declarations: ' + ', '.join(wrong[:12]))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--compiler', type=Path, required=True)
    ap.add_argument('--api-report', type=Path, required=True)
    ap.add_argument('--runtime-source', type=Path, required=True)
    ap.add_argument('--runtime-object', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase114'):
        raise ValueError('fresh Phase114 output required')
    inventory_file = HERE / 'modules01.json'
    if pin(inventory_file)['sha256'] != INVENTORY_SHA:
        raise ValueError('source inventory changed')
    inventory = json.loads(inventory_file.read_text())
    for row in [inventory['base'], inventory['baseAdmission'], inventory['runtimeSource'],
                inventory['runtimeObject'], inventory['controls'], inventory['ordinaryControls'],
                inventory['census'], *inventory['modules']]:
        authenticate(row)
    parent = json.loads(Path(inventory['baseAdmission']['file']).read_text())
    if not parent.get('complete') or not parent.get('admitted'):
        raise ValueError('parent admission incomplete')
    for key, expected in [('compiler', inventory['base']), ('runtimeSource', inventory['runtimeSource']),
                          ('runtimeObject', inventory['runtimeObject'])]:
        if parent[key] != expected:
            raise ValueError('parent admission mismatch: ' + key)
    for row in [*parent['inputs'], *parent['modules'], parent['recipe'], parent['method'],
                parent['checkedApi'], parent['checkedApiReceipt']]:
        authenticate(row)
    runtime, obj = pin(args.runtime_source), pin(args.runtime_object)
    if runtime != inventory['runtimeSource'] or obj != inventory['runtimeObject']:
        raise ValueError('exact admitted runtime source/object required')
    expected = declarations(Path(inventory['base']['file']).read_text())
    allowed = set(inventory['overrides'])
    for row in inventory['modules']:
        for key, body in declarations(Path(row['file']).read_text()).items():
            if key in expected and key[1] not in allowed:
                raise ValueError('undeclared override: ' + key[1])
            expected[key] = body
    actual = declarations(args.compiler.read_text())
    validate(actual, expected)
    compiler = pin(args.compiler)
    api_receipt = json.loads(args.api_report.read_text())
    if not api_receipt.get('complete') or not api_receipt.get('checked') or api_receipt.get('status') != 0:
        raise ValueError('successful checked API required')
    if compiler not in api_receipt['inputs']:
        raise ValueError('checked API compiler mismatch')
    authenticate(api_receipt['api'])
    for export in ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks', *inventory['exports']]:
        if export not in api_receipt['exports']:
            raise ValueError('missing checked API export: ' + export)
    mutations = []
    for name in ['p114b_target', 'p114b_loads', 'p114b_args', 'p114b_bridge', 'p114b_scan',
                 'p114b_narrow', 'p114b_general', 'p114b_public_segment', 'p113e_public_chunk',
                 'p114t_local_name', 'p113d_verify', 'p113e_base_scalar_safe', 'p111_verify_program']:
        key = ('def', name)
        changed = dict(actual)
        changed[key] += '\n0'
        try:
            validate(changed, expected)
        except ValueError:
            mutations.append(dict(name=name, refused=True))
        else:
            raise ValueError('source mutant admitted: ' + name)
    out.mkdir(parents=True)
    result = dict(kind='phase114-complete-bridge-admission', version=1, complete=True, admitted=True,
                  targetsExecuted=False, compiler=compiler, checkedApi=api_receipt['api'],
                  checkedApiReceipt=pin(args.api_report), runtimeSource=runtime, runtimeObject=obj,
                  method=pin(__file__), inventory=pin(inventory_file), parentAdmission=inventory['baseAdmission'],
                  modules=inventory['modules'], exactDeclarations=len(expected), mutations=mutations,
                  executionContract=inventory['executionContract'],
                  limitation='Exact checked-factory/compiler/runtime correspondence. Original final verifier and rt_return remain. No arbitrary reflected IR ownership/separation proof and no native/performance qualification; different combined profiles require a new exact admission.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected), mutations=len(mutations))))


if __name__ == '__main__':
    main()
