#!/usr/bin/env python3
"""Authenticate optional floating backend expansion; no targets are executed."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


A = module('float_accessor_admission', HERE.parent / 'accessors/admit.py')
S = module('float_static_admission', HERE.parent / 'static/admit.py')


def validate(source, runtime, header, with_static, liveness, abi):
    if A.digest(runtime) != abi['runtimeSha256'] or A.digest(header) != abi['headerSha256']:
        raise ValueError('Requires the exact qualified runtime04 and ABI11101 header')
    baseline = A.BASE.read_text()
    if A.digest(baseline) != abi['baselineSha256']:
        raise ValueError('Frozen Phase111 baseline changed')
    verifier = (ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend').read_text()
    if A.digest(verifier) != abi['verifierSha256']:
        raise ValueError('Original verifier changed')
    A.exact_definitions(source, verifier)
    S.exact(source, (ROOT / 'selfhost/tools/performance/phase111/segment/model.bend').read_text())
    for name in ['emit.bend', 'entry-accessors.bend']:
        S.exact(source, (HERE / name).read_text())
    for name in ['original.bend', 'emit.bend']:
        A.exact_definitions(source, (HERE.parent / 'accessors' / name).read_text())
    original = A.declaration(source, 'p112a_original_stmt').replace('def p112a_original_stmt(', 'def p111q_stmt(', 1)
    if original != A.declaration(baseline, 'p111q_stmt'):
        raise ValueError('Original renderer fallback changed')
    if with_static:
        S.validate(source, runtime, header, liveness, abi)
    else:
        for name in ['p111_emit_lowered', 'p111_emit_admitted', 'p111_emit_plan',
                     'p111_compile_prepared', 'p111_compile_source', 'p111_runtime_admission']:
            if A.declaration(source, name) != A.declaration(baseline, name):
                raise ValueError('Checked public rendering boundary changed: ' + name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, default=ROOT / 'selfhost/build/phase111/runtime-source04/runtime.c')
    parser.add_argument('--static', action='store_true')
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
    validate(source, runtime, header, args.static, args.liveness, abi)
    variants = [
        ('runtime-byte', source, runtime + '\n', header),
        ('abi-version', source, runtime, header.replace('11101', '11102', 1)),
        ('wrong-equality', source.replace('case 30: "ceqs"', 'case 30: "cnes"', 1), runtime, header),
        ('wrong-operand-width', source.replace('" =l loadl "', '" =l loadw "', 1), runtime, header),
        ('missing-zero-extension', source.replace('" =l extuw "', '" =l copy "', 1), runtime, header),
        ('wrong-literal-arity', source.replace('p112fp_supported(id,count)', 'p112fp_supported(id,2)', 1), runtime, header),
    ]
    refusals = []
    for name, src, rt, hdr in variants:
        if (src, rt, hdr) == (source, runtime, header):
            raise ValueError('Mutation did not apply: ' + name)
        try:
            validate(src, rt, hdr, args.static, args.liveness, abi)
        except ValueError as error:
            refusals.append(dict(name=name, refused=True, error=str(error)))
        else:
            raise ValueError('Mutation unexpectedly admitted: ' + name)
    paths = [Path(__file__), HERE / 'emit.bend', HERE / 'entry-accessors.bend',
             HERE.parent / 'accessors/admit.py', HERE.parent / 'static/admit.py', abi_path,
             A.BASE, args.source, args.runtime, header_path,
             ROOT / 'selfhost/tools/performance/phase111/segment/model.bend',
             ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend',
             HERE.parent / 'accessors/original.bend', HERE.parent / 'accessors/emit.bend']
    if args.static:
        paths += [HERE.parent / 'static' / name for name in S.MODULES + (['liveness-entry.bend'] if args.liveness else [])]
    inputs = [A.pin(path) for path in paths]
    report = dict(kind='phase112-float-source-admission', complete=True, targetsRun=False,
                  abiVersion=11101, originalModelAndVerifierUnchanged=True, intrinsicIds=[23,*range(26,36)],
                  static=args.static, liveness=args.liveness, source=A.pin(args.source), runtime=A.pin(args.runtime),
                  inputs=inputs, refusals=refusals,
                  scope='Verified-call backend expansion only. Source/ABI authentication does not replace native raw-bit controls or compiled-runtime provenance.')
    for item in inputs:
        if A.pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, refusals=len(refusals), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
