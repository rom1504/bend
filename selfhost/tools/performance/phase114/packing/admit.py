#!/usr/bin/env python3
"""Source-only exact candidate31 plus guarded unary-packing admission."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
INVENTORY_SHA = '0a8351f6ff541bf3e84afaf6b26cdfe30d8602271dd8921f60a0baaac6b34ce4'
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
    wrong = [name for (kind, name), body in expected.items() if actual[kind, name] != body]
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
    file = HERE / 'modules01.json'
    if pin(file)['sha256'] != INVENTORY_SHA:
        raise ValueError('inventory changed')
    inventory = json.loads(file.read_text())
    for row in [inventory['base'], inventory['baseAdmission'], inventory['runtimeSource'],
                inventory['runtimeObject'], inventory['ordinaryControls'],
                *inventory['modules'], *inventory['matureReferences']]:
        authenticate(row)
    base = json.loads(Path(inventory['baseAdmission']['file']).read_text())
    if not base.get('complete') or not base.get('admitted') or base['compiler'] != inventory['base']:
        raise ValueError('baseline admission incomplete/mismatched')
    for row in base['inputs']:
        authenticate(row)
    runtime, obj = pin(args.runtime_source), pin(args.runtime_object)
    if runtime != inventory['runtimeSource'] or obj != inventory['runtimeObject']:
        raise ValueError('exact runtime source/object required')
    if base['runtimeSource'] != runtime or base['runtimeObject'] != obj:
        raise ValueError('baseline runtime mismatch')
    expected = declarations(Path(inventory['base']['file']).read_text())
    original = expected['def', 'p111_constructor']
    for row in inventory['modules']:
        for key, body in declarations(Path(row['file']).read_text()).items():
            if key in expected and key[1] not in inventory['overrides']:
                raise ValueError('undeclared override: ' + key[1])
            expected[key] = body
    if expected['def', 'p114p_original_constructor'].replace('def p114p_original_constructor(', 'def p111_constructor(', 1) != original:
        raise ValueError('ordinary fallback is not exact original constructor')
    actual = declarations(args.compiler.read_text())
    validate(actual, expected)
    compiler = pin(args.compiler)
    checked = json.loads(args.api_report.read_text())
    if not checked.get('complete') or not checked.get('checked') or checked.get('status') != 0:
        raise ValueError('successful checked API required')
    if compiler not in checked['inputs']:
        raise ValueError('checked compiler mismatch')
    authenticate(checked['api'])
    for name in ['p113a_lower_request', 'p113a_verify', 'p113a_admitted_chunks']:
        if name not in checked['exports']:
            raise ValueError('missing checked export: ' + name)
    mutations = []
    for name in ['p111_constructor', 'p114p_ordinary', 'p114p_single', 'p114p_original_constructor',
                 'p111v_counted_call', 'p111_verify_program', 'p113d_verify', 'p113a_verify']:
        changed = dict(actual)
        changed['def', name] += '\n0'
        try:
            validate(changed, expected)
        except ValueError:
            mutations.append(dict(name=name, refused=True))
        else:
            raise ValueError('source mutation accepted: ' + name)
    out.mkdir(parents=True)
    result = dict(kind='phase114-guarded-unary-packing-admission', version=1,
                  complete=True, admitted=True, targetsExecuted=False,
                  compiler=compiler, runtimeSource=runtime, runtimeObject=obj,
                  checkedApi=checked['api'], checkedApiReceipt=pin(args.api_report),
                  method=pin(__file__), inventory=pin(file), baseAdmission=inventory['baseAdmission'],
                  modules=inventory['modules'], exactDeclarations=len(expected), mutations=mutations,
                  contract=inventory['scope'],
                  limitation='Source/runtime binding only; no arbitrary reflected graph ownership certificate, concurrent qualification, or performance claim. Other compiler overlays need a new conjunctive receipt.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected), mutations=len(mutations))))


if __name__ == '__main__':
    main()
