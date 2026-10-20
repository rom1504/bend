#!/usr/bin/env python3
"""Exact candidate31 + fixed-transport source admission; no targets executed."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
INVENTORY_SHA = '6ee601762afd81803e5d5eec25687f2ab952b669515b09413c599365b34cd5e5'
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
                inventory['runtimeObject'], inventory['runtimeHeader'], inventory['controls'], *inventory['modules']]:
        authenticate(row)
    baseline_receipt = json.loads(Path(inventory['baseAdmission']['file']).read_text())
    if not baseline_receipt.get('complete') or not baseline_receipt.get('admitted'):
        raise ValueError('baseline admission incomplete')
    for key, expected in [('compiler', inventory['base']), ('runtimeSource', inventory['runtimeSource']),
                          ('runtimeObject', inventory['runtimeObject'])]:
        if baseline_receipt[key] != expected:
            raise ValueError('baseline admission mismatch: ' + key)
    for row in baseline_receipt['inputs']:
        authenticate(row)
    runtime, obj = pin(args.runtime_source), pin(args.runtime_object)
    if runtime != inventory['runtimeSource'] or obj != inventory['runtimeObject']:
        raise ValueError('exact admitted runtime source/object required')
    expected = declarations(Path(inventory['base']['file']).read_text())
    original = dict(expected)
    allowed = set(inventory['overrides'])
    for row in inventory['modules']:
        for key, body in declarations(Path(row['file']).read_text()).items():
            if key in expected and key[1] not in allowed:
                raise ValueError('undeclared override: ' + key[1])
            expected[key] = body
    for old, new in [('p111q_stmt', 'p114t_original_stmt'), ('p113a_verify', 'p114t_original_verify')]:
        renamed = original['def', old].replace('def ' + old + '(', 'def ' + new + '(', 1)
        if expected['def', new] != renamed:
            raise ValueError('fallback is not exact: ' + old)
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
    # Source correspondence challenges only; never executed malformed IR.
    mutations = []
    for name in ['p111q_stmt', 'p113a_verify', 'p114t_original_stmt', 'p114t_original_verify',
                 'p114t_expand', 'p114t_captures', 'p114t_frame', 'p114t_negative_bytes',
                 'p114t_buffer', 'p114t_segment_names', 'p114t_expanded',
                 'p111_verify_program', 'p113d_verify']:
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
    result = dict(kind='phase114-fixed-transport-admission', version=1, complete=True, admitted=True,
                  targetsExecuted=False, compiler=compiler, checkedApi=api_receipt['api'],
                  checkedApiReceipt=pin(args.api_report), runtimeSource=runtime, runtimeObject=obj,
                  method=pin(__file__), inventory=pin(inventory_file), baselineAdmission=inventory['baseAdmission'],
                  modules=inventory['modules'], exactDeclarations=len(expected), mutations=mutations,
                  executionContract=inventory['executionContract'],
                  limitation='Exact source/runtime correspondence for the checked factory. Structural verification is not an arbitrary pointer-separation or ownership proof. No native/performance qualification, no jump/return rewrite, and no G raw-string builder expansion.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected), mutations=len(mutations))))


if __name__ == '__main__':
    main()
