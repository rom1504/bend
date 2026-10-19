#!/usr/bin/env python3
"""Bind one closed frozen-six-rank region/fusion/failstop profile. Executes no target."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE_METHOD_SHA = '8450e9e120574e1dc5a4dca51f4860258516aa1b0c2eef9e6f9313ea98ff93d9'
INVENTORY_SHA = '674d60ddbfede41b29bff7e5bba68a21577d24522e04f9481e485a36cc62d58a'
VERIFIER_SHA = 'c2131760ea5e064394368101c12e59ae79142be453da297822ed6904dd3c51c0'
MODEL_SHA = '316c864bf43232de9cf7fa4fe145c3e761e23afa9bf29e498565e3d55814c5a4'
PREFIXES = ('p112t_', 'p112q_', 'p112w_', 'p112e_', 'p112f_', 'p112r_', 'P112Region', 'P112Tail', 'P112Worker', 'P112Fusion')


def checked(path, sha):
    raw = path.read_bytes()
    if hashlib.sha256(raw).hexdigest() != sha:
        raise ValueError('Pinned input changed: ' + str(path))
    return raw


def validate(base, source, expected):
    actual = base.declarations(source)
    wrong = [name for name, body in expected.items() if actual.get(name) != body]
    extras = [name for name in actual if name[1].startswith(PREFIXES) and name not in expected]
    if wrong or extras:
        raise ValueError('Exact conjunctive declaration mismatch: ' + repr(wrong + extras))


def mutate(source, name, before, after):
    pattern = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
    matches = list(pattern.finditer(source))
    selected = [(i, match) for i, match in enumerate(matches) if match.group(1) == name]
    if len(selected) != 1:
        raise ValueError('Missing mutation declaration: ' + name)
    i, match = selected[0]
    end = matches[i + 1].start() if i + 1 < len(matches) else len(source)
    body = source[match.start():end]
    if before not in body:
        raise ValueError('Mutation did not apply: ' + name)
    return source[:match.start()] + body.replace(before, after, 1) + source[end:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime-source', type=Path, required=True)
    parser.add_argument('--runtime-object', type=Path, required=True)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base_path = HERE / 'admit-failstop.py'
    checked(base_path, BASE_METHOD_SHA)
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('p112_conjunction_base', base_path)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    source_pin, object_pin, compiler_pin = map(base.pin, [args.runtime_source, args.runtime_object, args.compiler])
    if source_pin['sha256'] != base.SOURCE_SHA or object_pin['sha256'] != base.OBJECT_SHA:
        raise ValueError('Requires exact selected CPU runtime04 source and object')
    inventory_path = HERE / 'conjunction-regions02.json'
    inventory = json.loads(checked(inventory_path, INVENTORY_SHA))
    fusion = inventory['fusionInventory']
    checked(ROOT / fusion['file'], fusion['sha256'])
    region = inventory['regionInventory']
    checked(ROOT / region['file'], region['sha256'])
    expected, module_paths = {}, []
    for item in inventory['modules']:
        path = ROOT / item['file']
        raw = checked(path, item['sha256'])
        if len(raw) != item['bytes']:
            raise ValueError('Module byte length mismatch')
        expected.update(base.declarations(raw.decode()))
        module_paths.append(path)
    verifier = ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend'
    model = ROOT / 'selfhost/tools/performance/phase111/segment/model.bend'
    expected.update(base.declarations(checked(verifier, VERIFIER_SHA).decode()))
    expected.update(base.declarations(checked(model, MODEL_SHA).decode()))
    source = args.compiler.read_text()
    validate(base, source, expected)
    changes = [
        ('worker-bound', 'p112w_plan', 'U32.is_le(arity,32)', 'U32.is_le(arity,33)'),
        ('fusion-bound', 'p112f_target', 'U32.is_le(arity,8)', 'U32.is_le(arity,32)'),
        ('failure-admission', 'p112w_scan', 'p112t_failure(body)', 'True{}'),
        ('secondary-pointer', 'p112t_buffer_args', 'String.eq(name,"scratch")', 'String.eq(name,"state")'),
        ('early-scalar-gate', 'p112w_scan_next', 'p112t_scalar_safe(stmt)', 'True{}'),
        ('actual-emission-hook', 'p111q_segment_chunks', 'p112r_segment_chunks', 'p112f_segment_chunks'),
        ('region-arity-bound', 'p112r_plan', 'U32.is_le(arity,8)', 'U32.is_le(arity,9)'),
        ('region-rank-bound', 'p112r_index', ',1,6)', ',1,7)'),
        ('region-frozen-emission', 'p112r_private_chunks', 'p112w_private(segment,ids,plan)', 'p112w_private(segment,ids,p112w_plan(segment,missing()))'),
        ('region-immutable-pass', 'p112r_pass', 'rest,index,old,symbols,rank,', 'rest,index,missing(),symbols,rank,'),
    ]
    variants = [(name, mutate(source, declaration, before, after)) for name, declaration, before, after in changes]
    variants.append(('extra-fusion-helper', source + '\n@unsafe\ndef p112f_unadmitted() -> U32:\n  0\n'))
    refusals = []
    for name, variant in variants:
        try:
            validate(base, variant, expected)
        except ValueError as error:
            refusals.append(dict(name=name, refused=True, reason=str(error)))
        else:
            raise ValueError('Mutated composition was admitted: ' + name)
    if args.out.exists():
        raise ValueError('Use a fresh admission output')
    inputs = [base.pin(path) for path in [base_path, inventory_path, ROOT / fusion['file'], ROOT / region['file'], verifier, model, *module_paths]]
    companions = []
    if 'def p112fp_expand(' in source:
        companions.append('phase112-float-source-admission')
    if 'def p112s_emit_lowered(' in source:
        companions.append('phase112-static-source-admission')
    record = dict(kind='phase112-cpu-failstop-worker-admission', profile=inventory['profile'],
                  admitted=True, targetsExecuted=False, runtimeSource=source_pin, runtimeObject=object_pin,
                  compiler=compiler_pin, method=base.pin(__file__), inputs=inputs,
                  exactDeclarations=len(expected),
                  declarationHashes={kind + ' ' + name: hashlib.sha256(body.encode()).hexdigest()
                                     for (kind, name), body in expected.items()},
                  contract=dict(abiVersion=11101, capabilities=1, threads=1, gpu='off',
                                privateArityMax=8, fusionArityMax=8, dependencyPasses=6,
                                firstAdmissionFrozen=True, publicUsesFinalReady=True, resultWords=1,
                                earlyRefusal=True, failureReturnUnreachable=True,
                                secondaryRuntimePointers='canonical scratch or exact authenticated fusion scratch'),
                  refusals=refusals, requiredCompanionReceiptKinds=companions,
                  limitations=['Runner must require this exact compiler source and runtime object.',
                               'Detected float/static profiles require their separate receipts on this same source.',
                               'Other source lowering changes and executable semantics remain separate qualification.'])
    for item in [source_pin, object_pin, compiler_pin, *inputs]:
        if base.pin(item['file']) != item:
            raise ValueError('Input changed during admission: ' + item['file'])
    args.out.mkdir(parents=True)
    (args.out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, profile=record['profile'], exactDeclarations=len(expected), refusals=len(refusals))))


if __name__ == '__main__':
    main()
