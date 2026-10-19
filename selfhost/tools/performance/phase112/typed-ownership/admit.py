#!/usr/bin/env python3
"""Bind checked scalar-fact reuse and exact unknown ownership fallback."""
import argparse
import importlib.util
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('typed_immediate_admission', HERE.parent / 'immediates/admit-v3.py')
I = importlib.util.module_from_spec(spec)
spec.loader.exec_module(I)
A, S, ROOT = I.A, I.S, I.ROOT
spec = importlib.util.spec_from_file_location('typed_float_admission', HERE.parent / 'float/admit.py')
F = importlib.util.module_from_spec(spec)
spec.loader.exec_module(F)
HELPERS = ['nk_kind', 'nk_value', 'nk_binding', 'nk_typed_bindings',
           'nf_scalar_kind', 'nf_opaque_kinds', 'nf_kind_tele', 'nf_kind_head', 'nf_worker_kinds',
           'nd_entry_params', 'nd_entry_args', 'nc_live_uses', 'nc_remove_env', 'nc_word',
           'jd_arity', 'jd_domains', 'jd_domains_head', 'jd_raise', 'jd_raise_head',
           'jd_live_arity', 'jd_live_arity_head',
           'p111_params', 'p111_env_words', 'p111_values', 'p111_store', 'p111_frame', 'p111_segment',
           'p111_entry', 'p111_compile_defs', 'p111_uint', 'p111_value', 'p111_field_env']


def validate(source, runtime, header, abi, immediate=False):
    if immediate:
        layers = I.validate(source, runtime, header, True, True, True, abi)
    else:
        # This is the actual gap-if composition. Authenticate the unchanged
        # float hook directly; no immediate hook or projected source is used.
        F.validate(source, runtime, header, True, True, abi)
        layers = [I.layer(source, 'floating emitter', HERE.parent / 'float/emit.bend'),
                  I.layer(source, 'active statement hook', HERE.parent / 'float/entry-accessors.bend'),
                  I.layer(source, 'accessor emitter', HERE.parent / 'accessors/emit.bend'),
                  I.layer(source, 'original statement fallback', HERE.parent / 'accessors/original.bend')]
        layers += [I.layer(source, 'static/' + name, HERE.parent / 'static' / name)
                   for name in S.MODULES + ['liveness-entry.bend']]
        layers += [I.layer(source, 'original structured model', ROOT / 'selfhost/tools/performance/phase111/segment/model.bend'),
                   I.layer(source, 'original structured verifier', ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend')]
        baseline = A.BASE.read_text()
        if A.declaration(source, 'p111_test') != A.declaration(baseline, 'p111_test'):
            layers.append(I.layer(source, 'special-test lowerer', HERE.parent / 'accessors/special-tests.bend'))
            fallback = A.declaration(source, 'p112_special_test_fallback').replace('def p112_special_test_fallback(', 'def p111_test(', 1)
            if fallback != A.declaration(baseline, 'p111_test'):
                raise ValueError('Original special-test fallback changed')
    baseline = A.BASE.read_text()
    for filename in ['facts.bend', 'overrides.bend']:
        layers.append(I.layer(source, 'typed ownership/' + filename, HERE / filename))
    original = json.loads((HERE / 'overrides.json').read_text())
    for item in original['changes']:
        before = A.declaration(Path(item['origin']).read_text(), item['name'])
        after = A.declaration(source, item['name'])
        if A.digest(before) != item['oldSha256'] or A.digest(after) != item['newSha256']:
            raise ValueError('Exact override provenance changed: ' + item['name'])
        if before.count(item['before']) != 1 or before.replace(item['before'], item['after'], 1) != after:
            raise ValueError('Override exceeds the audited change: ' + item['name'])
    # These are the mature semantic facts and every machine-width consumer of
    # the propagated environment. No NF C parameter renderer is selected.
    names = HELPERS + re.findall(r'(?m)^def (nq_layout_[A-Za-z0-9_]+)\(', baseline)
    for name in dict.fromkeys(names):
        if A.declaration(source, name) != A.declaration(baseline, name):
            raise ValueError('Mature fact or U64 transport helper changed: ' + name)
    # The already-selected word-pattern path is another N_W32 producer. Its
    # value is explicitly masked to32 bits and its optional bit to1.
    layers.append(I.layer(source, 'existing masked-word producer', HERE.parent / 'word-pattern/emit.bend'))
    return layers, list(dict.fromkeys(names))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, default=ROOT / 'selfhost/build/phase111/runtime-source04/runtime.c')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--immediate', action='store_true', help='Authenticate the experimental immediate hook; default is the selected no-immediate composition')
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Use a fresh Phase112 receipt directory')
    abi_path = HERE.parent / 'accessors/abi.json'
    abi = json.loads(abi_path.read_text())
    header_path = args.runtime.with_name('runtime.h')
    source, runtime, header = args.source.read_text(), args.runtime.read_text(), header_path.read_text()
    layers, helpers = validate(source, runtime, header, abi, args.immediate)
    changes = [
        ('opaque-marked-nonowning', 'p112to_nonowning', 'case _: False{}', 'case _: True{}'),
        ('drop-unknown-keep', 'p111_keep', 'Bool.not(p112to_nonowning(kind))', 'False{}'),
        ('drop-unknown-sink', 'p111_partition_step', 'p112to_nonowning(kind)', 'True{}'),
        ('unconditional-typed-seed', 'p111_extend', 'nf_worker_kinds(book, name, arity)', 'nf_opaque_kinds(arity)'),
        ('kind-shadow-lookup', 'nk_kind', 'u => kind, u => nk_kind(id, rest)', 'u => N_W32{}, u => nk_kind(id, rest)'),
        ('builtin-identity-guard', 'nf_scalar_kind', 'db(owner)', 'True{}'),
        ('machine-parameter-narrowing', 'p111_params', 'N111U64{}', 'N111U32{}'),
        ('active-hook-bypass', 'p111q_stmt', 'p112i_expand(stmt,ids,code)' if args.immediate else 'p112fp_expand(stmt,code)', 'P112IEmission{False{},code}' if args.immediate else 'P112FPEmission{False{},code}'),
    ]
    variants = [('runtime-byte', source, runtime + '\n', header),
                ('abi-version', source, runtime, header.replace('11101', '11102', 1))]
    for label, name, before, after in changes:
        old = A.declaration(source, name)
        if before not in old:
            raise ValueError('Mutation did not match: ' + label)
        variants.append((label, source.replace(old, old.replace(before, after, 1), 1), runtime, header))
    refusals = []
    for label, src, rt, hdr in variants:
        try:
            validate(src, rt, hdr, abi, args.immediate)
        except ValueError as error:
            refusals.append(dict(name=label, refused=True, error=str(error)))
        else:
            raise ValueError('Mutation unexpectedly admitted: ' + label)
    paths = [Path(__file__), HERE / 'overrides.json', HERE / 'controls.bend',
             HERE.parent / 'immediates/admit-v3.py', HERE.parent / 'immediates/admit.py',
             HERE.parent / 'float/admit.py',
             HERE.parent / 'accessors/admit.py', HERE.parent / 'static/admit.py',
             abi_path, A.BASE, args.source, args.runtime, header_path]
    paths += [Path(item['module']['file']) for item in layers]
    paths += [Path(item['origin']) for item in json.loads((HERE / 'overrides.json').read_text())['changes']]
    inputs = [A.pin(path) for path in dict.fromkeys(paths)]
    report = dict(kind='phase112-typed-ownership-admission', complete=True, targetsRun=False,
                  source=A.pin(args.source), runtime=A.pin(args.runtime), inputs=inputs, composition=layers,
                  matureHelpers=helpers, refusals=refusals, machineAbiChanged=False,
                  immediate=args.immediate, projectionUsed=False,
                  scope='Checked-source scalar fact reuse before ownership insertion; raw binding records are not certificates. Native semantics and region-benefit evidence remain separate.')
    for item in inputs:
        if A.pin(item['file']) != item:
            raise ValueError('Input changed during admission')
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, refusals=len(refusals), report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()
