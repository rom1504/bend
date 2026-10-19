#!/usr/bin/env python3
"""Authenticate optional immediate keep/sink expansion; execute no targets."""
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


A = module('immediate_accessor_admission', HERE.parent / 'accessors/admit.py')
S = module('immediate_static_admission', HERE.parent / 'static/admit.py')


def validate(source, runtime, header, with_float, with_static, liveness, abi):
    if A.digest(runtime) != abi['runtimeSha256'] or A.digest(header) != abi['headerSha256']:
        raise ValueError('Requires the exact qualified runtime04 and ABI11101 header')
    baseline = A.BASE.read_text()
    if A.digest(baseline) != abi['baselineSha256']:
        raise ValueError('Frozen Phase111 baseline changed')
    verifier = (ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend').read_text()
    if A.digest(verifier) != abi['verifierSha256']:
        raise ValueError('Original verifier changed')
    S.exact(source, verifier)
    S.exact(source, (ROOT / 'selfhost/tools/performance/phase111/segment/model.bend').read_text())
    for name in ['emit.bend', 'entry-float.bend' if with_float else 'entry-accessors.bend']:
        S.exact(source, (HERE / name).read_text())
    for name in ['original.bend', 'emit.bend']:
        S.exact(source, (HERE.parent / 'accessors' / name).read_text())
    original = A.declaration(source, 'p112a_original_stmt').replace('def p112a_original_stmt(', 'def p111q_stmt(', 1)
    if original != A.declaration(baseline, 'p111q_stmt'):
        raise ValueError('Original renderer fallback changed')
    if with_float:
        S.exact(source, (HERE.parent / 'float/emit.bend').read_text())
        helper = 'p112fp_after_accessors'
        if A.declaration(source, helper) != A.declaration((HERE.parent / 'float/entry-accessors.bend').read_text(), helper):
            raise ValueError('Floating fallback adapter changed')
    for name in ['p111q_tmp', 'p111q_label', 'p111q_value', 'p111q_stmts', 'p111q_stmts_head']:
        if A.declaration(source, name) != A.declaration(baseline, name):
            raise ValueError('Original value/control renderer changed: ' + name)
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
    parser.add_argument('--float', action='store_true', dest='with_float')
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
    validate(source, runtime, header, args.with_float, args.static, args.liveness, abi)
    variants = [
        ('runtime-byte', source, runtime + '\n', header),
        ('abi-version', source, runtime, header.replace('11101', '11102', 1)),
        ('signed-predicate', source.replace('" =w cultl "', '" =w csltl "', 1), runtime, header),
        ('inclusive-boundary', source.replace('" =w cultl "', '" =w culel "', 1), runtime, header),
        ('admit-ctr-tag', source.replace('144115188075855872', '216172782113783808', 1), runtime, header),
        ('wrong-fast-result', source.replace('u => word,u => "0"', 'u => "0",u => word', 1), runtime, header),
        ('temporary-reuse', source.replace('p111q_value(word,ids),n),chunks},U32.add(n,3)', 'p111q_value(word,ids),n),chunks},n', 1), runtime, header),
    ]
    refusals = []
    for name, src, rt, hdr in variants:
        if (src, rt, hdr) == (source, runtime, header):
            raise ValueError('Mutation did not apply: ' + name)
        try:
            validate(src, rt, hdr, args.with_float, args.static, args.liveness, abi)
        except ValueError as error:
            refusals.append(dict(name=name, refused=True, error=str(error)))
        else:
            raise ValueError('Mutation unexpectedly admitted: ' + name)
    paths = [Path(__file__), HERE / 'emit.bend', HERE / ('entry-float.bend' if args.with_float else 'entry-accessors.bend'),
             HERE.parent / 'accessors/admit.py', HERE.parent / 'static/admit.py', abi_path,
             A.BASE, args.source, args.runtime, header_path,
             ROOT / 'selfhost/tools/performance/phase111/segment/model.bend',
             ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend',
             HERE.parent / 'accessors/original.bend', HERE.parent / 'accessors/emit.bend']
    if args.with_float:
        paths += [HERE.parent / 'float/emit.bend', HERE.parent / 'float/entry-accessors.bend']
    if args.static:
        paths += [HERE.parent / 'static' / name for name in S.MODULES + (['liveness-entry.bend'] if args.liveness else [])]
    inputs = [A.pin(path) for path in paths]
    report = dict(kind='phase112-immediate-source-admission', complete=True, targetsRun=False,
                  abiVersion=11101, originalModelAndVerifierUnchanged=True, predicate='unsigned term < 2^57',
                  float=args.with_float, static=args.static, liveness=args.liveness,
                  source=A.pin(args.source), runtime=A.pin(args.runtime), inputs=inputs, refusals=refusals,
                  scope='Immediate-only backend expansion with exact runtime fallback. Source authentication is separate from native observations and runtime-object provenance.')
    for item in inputs:
        if A.pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, refusals=len(refusals), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
