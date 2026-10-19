#!/usr/bin/env python3
"""Bind typed static source, original verifier and exact ABI; run no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase111/full-source05/compiler.bend'
MODULES = ['model.bend', 'plan.bend', 'verify.bend', 'original.bend',
           'emit.bend', 'lower.bend', 'entry.bend']


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def declaration(source, kind, name):
    pattern = r'(?m)^(?:@unsafe\n)?' + kind + ' ' + re.escape(name) + r'\b'
    found = list(re.finditer(pattern, source))
    if len(found) != 1:
        raise ValueError('Missing or repeated declaration: ' + kind + ' ' + name)
    start = found[0].start()
    end = source.find('\n\n', start)
    return source[start:end if end >= 0 else len(source)].strip()


def exact(source, module):
    for kind, name in re.findall(r'(?m)^(def|type|law) ([A-Za-z0-9_.]+)\b', module):
        if declaration(source, kind, name) != declaration(module, kind, name):
            raise ValueError('Changed audited declaration: ' + kind + ' ' + name)


def validate(source, runtime, header, liveness, abi):
    if digest(runtime) != abi['runtimeSha256'] or digest(header) != abi['headerSha256']:
        raise ValueError('Requires exact qualified runtime04 and ABI11101 header')
    baseline = BASE.read_text()
    if digest(baseline) != abi['baselineSha256']:
        raise ValueError('Frozen baseline changed')
    verifier = (ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend').read_text()
    if digest(verifier) != abi['verifierSha256']:
        raise ValueError('Original structural verifier changed')
    exact(source, verifier)
    for name in ['p111_emit_lowered', 'p111_emit_plan', 'p111_compile_prepared',
                 'p111_compile_source', 'p111_runtime_admission', 'p111_runtime_effects',
                 'p111_runtime_names', 'p111q_descriptor', 'p111q_tables']:
        if declaration(source, 'def', name) != declaration(baseline, 'def', name):
            raise ValueError('Changed checked request or ABI boundary: ' + name)
    for name in MODULES + (['liveness-entry.bend'] if liveness else []):
        exact(source, (HERE / name).read_text())
    for old, new in [('p111_live', 'p112s_live_fallback'), ('p111_let', 'p112s_let_fallback')]:
        fallback = declaration(source, 'def', new).replace('def ' + new + '(', 'def ' + old + '(', 1)
        if fallback != declaration(baseline, 'def', old):
            raise ValueError('Non-static lowerer fallback changed: ' + old)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, default=ROOT / 'selfhost/build/phase111/runtime-source04/runtime.c')
    parser.add_argument('--liveness', action='store_true')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Use a fresh Phase112 receipt directory')
    abi_path = HERE.parent / 'accessors/abi.json'
    abi = json.loads(abi_path.read_text())
    header_path = args.runtime.with_name('runtime.h')
    source, runtime, header = args.source.read_text(), args.runtime.read_text(), header_path.read_text()
    validate(source, runtime, header, args.liveness, abi)
    variants = [
        ('runtime-byte', source, runtime + '\n', header),
        ('abi-version', source, runtime, header.replace('11101', '11102', 1)),
        ('static-base', source.replace('U32.add(51413504,offset)', 'U32.add(51413505,offset)', 1), runtime, header),
        ('budget-increase', source.replace('U32.sub(65536,size)', 'U32.sub(65537,size)', 1), runtime, header),
        ('skip-static-verifier', source.replace('p112s_emit_verified(bundle,p112s_verify(bundle))', 'p112s_emit_verified(bundle,"")', 1), runtime, header),
        ('skip-original-verifier', source.replace('p111_first(p111_verify_program(program),p112s_image_error(bundle))', 'p112s_image_error(bundle)', 1), runtime, header),
    ]
    refusals = []
    for name, src, rt, hdr in variants:
        if (src, rt, hdr) == (source, runtime, header):
            raise ValueError('Mutation did not apply: ' + name)
        try:
            validate(src, rt, hdr, args.liveness, abi)
        except ValueError as error:
            refusals.append(dict(name=name, refused=True, error=str(error)))
        else:
            raise ValueError('Mutated source unexpectedly admitted: ' + name)
    paths = [Path(__file__), abi_path, BASE, args.source, args.runtime, header_path,
             ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend']
    paths += [HERE / name for name in MODULES + (['liveness-entry.bend'] if args.liveness else [])]
    inputs = [pin(path) for path in paths]
    report = dict(kind='phase112-static-source-admission', complete=True, targetsRun=False,
                  abiVersion=11101, staticBase=51413504, wordBudget=65536, liveness=args.liveness,
                  source=pin(args.source), runtime=pin(args.runtime), inputs=inputs,
                  refusals=refusals, originalVerifierUnchanged=True,
                  scope='Source and ABI authentication only. Other selected optimizations and the compiled runtime object require their separate receipts and semantic checks.')
    for item in inputs:
        if pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, refusals=len(refusals), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
