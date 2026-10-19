#!/usr/bin/env python3
"""Authenticate the actual composed hook and every selected fallback layer."""
import argparse
import json
import re
from pathlib import Path
import importlib.util

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('immediate_admission_v1', HERE / 'admit.py')
V1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V1)
A, S, ROOT = V1.A, V1.S, V1.ROOT


def layer(source, name, path, omitted=()):
    """Compare declarations directly in actual source, without a projection."""
    expected = path.read_text()
    declarations = []
    for kind, symbol in re.findall(r'(?m)^(def|type|law) ([A-Za-z0-9_.]+)\b', expected):
        if symbol in omitted:
            continue
        actual = S.declaration(source, kind, symbol)
        wanted = S.declaration(expected, kind, symbol)
        if actual != wanted:
            raise ValueError('Changed composition layer ' + name + ': ' + symbol)
        declarations.append(dict(kind=kind, name=symbol, sha256=A.digest(actual)))
    return dict(name=name, module=A.pin(path), declarations=declarations)


def validate(source, runtime, header, with_float, with_static, liveness, abi):
    # V1 already checks the active immediate entry, complete float emitter,
    # float fallback adapter, accessors, original model/verifier and frontend.
    V1.validate(source, runtime, header, with_float, with_static, liveness, abi)
    layers = [layer(source, 'immediate emitter', HERE / 'emit.bend'),
              layer(source, 'active statement hook', HERE / ('entry-float.bend' if with_float else 'entry-accessors.bend'))]
    if with_float:
        layers += [layer(source, 'floating emitter', HERE.parent / 'float/emit.bend'),
                   layer(source, 'floating fallback adapter', HERE.parent / 'float/entry-accessors.bend', ('p111q_stmt',))]
    layers += [layer(source, 'accessor emitter', HERE.parent / 'accessors/emit.bend'),
               layer(source, 'original statement fallback', HERE.parent / 'accessors/original.bend')]
    if with_static:
        layers += [layer(source, 'static/' + name, HERE.parent / 'static' / name)
                   for name in S.MODULES + (['liveness-entry.bend'] if liveness else [])]
    layers += [layer(source, 'original structured model', ROOT / 'selfhost/tools/performance/phase111/segment/model.bend'),
               layer(source, 'original structured verifier', ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend')]
    return layers


def mutate(source, symbol, before, after):
    old = A.declaration(source, symbol)
    if old.count(before) != 1:
        raise ValueError('Mutation requires one exact match in ' + symbol)
    return source.replace(old, old.replace(before, after, 1), 1)


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
    layers = validate(source, runtime, header, args.with_float, args.static, args.liveness, abi)
    variants = [
        ('runtime-byte', source, runtime + '\n', header),
        ('abi-version', source, runtime, header.replace('11101', '11102', 1)),
        ('signed-predicate', mutate(source, 'p112i_text', '" =w cultl "', '" =w csltl "'), runtime, header),
        ('inclusive-boundary', mutate(source, 'p112i_text', '" =w cultl "', '" =w culel "'), runtime, header),
        ('admit-ctr-tag', mutate(source, 'p112i_text', '144115188075855872', '216172782113783808'), runtime, header),
        ('wrong-fast-result', mutate(source, 'p112i_text', 'u => word,u => "0"', 'u => "0",u => word'), runtime, header),
        ('temporary-reuse', mutate(source, 'p112i_emit', 'U32.add(n,3)', 'n'), runtime, header),
        ('active-hook-bypass', mutate(source, 'p111q_stmt', 'p112i_expand(stmt,ids,code)', 'P112IEmission{False{},code}'), runtime, header),
        ('accessor-register-offset', mutate(source, 'p112a_expand', 'U32.add(40, U32.mul(index, 8))', 'U32.add(48, U32.mul(index, 8))'), runtime, header),
        ('original-verifier-state-capacity', mutate(source, 'p111v_segment', '"parameter",3,2088', '"parameter",3,2096'), runtime, header),
    ]
    if args.with_float:
        variants += [
            ('float-equality', mutate(source, 'p112fp_binary', 'case 30: "ceqs"', 'case 30: "cnes"'), runtime, header),
            ('float-fallback-adapter', mutate(source, 'p112fp_after_accessors', 'p112a_stmt(3,stmt,ids,code)', 'p112a_stmt(0,stmt,ids,code)'), runtime, header),
            ('immediate-float-dispatch', mutate(source, 'p112i_after_float', 'p112fp_expand(stmt,code)', 'P112FPEmission{False{},code}'), runtime, header),
        ]
    if args.static:
        variants += [('skip-static-original-verifier', mutate(source, 'p112s_verify', 'p111_verify_program(program)', '""'), runtime, header)]
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
    paths = [Path(__file__), HERE / 'admit.py', HERE.parent / 'accessors/admit.py', HERE.parent / 'static/admit.py',
             abi_path, A.BASE, args.source, args.runtime, header_path]
    paths += [Path(item['module']['file']) for item in layers]
    inputs = [A.pin(path) for path in dict.fromkeys(paths)]
    report = dict(kind='phase112-immediate-source-admission', methodVersion=2, complete=True, targetsRun=False,
                  abiVersion=11101, originalModelAndVerifierUnchanged=True, predicate='unsigned term < 2^57',
                  float=args.with_float, static=args.static, liveness=args.liveness,
                  source=A.pin(args.source), runtime=A.pin(args.runtime), inputs=inputs,
                  composition=layers, refusals=refusals, projectionUsed=False,
                  supersedesHookCheck='The active immediate hook is checked directly. Every non-hook declaration of the selected float entry is exact; the superseded float p111q_stmt is not an active declaration.',
                  scope='Conjunctive source/ABI admission only; native controls, selected worker admission, and compiled runtime provenance remain separate.')
    for item in inputs:
        if A.pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, methodVersion=2, refusals=len(refusals), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
