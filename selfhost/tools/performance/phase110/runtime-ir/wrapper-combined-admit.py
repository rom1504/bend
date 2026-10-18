#!/usr/bin/env python3
"""Authenticate combined stored-field/spare and optional delayed-load premises.

Data only: authenticates exact source/runtime closure and exercises refusals.
This does not establish a mechanized physical-heap correspondence theorem.
"""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('source_admission', HERE / 'stored-field-admit-v2.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--variant', choices=['combined', 'delayed'], required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    chain = S.runtime_chain(a.runtime / 'manifest.json')
    roots = [facts for facts in chain.values()
             if facts['kind'] == 'phase109-production-runtime-core']
    if len(roots) != 1:
        raise ValueError('one authenticated production runtime required')
    base_path = Path(next(r['file'] for r in roots[0]['outputs']
                         if r['file'].endswith('/runtime.c')))
    base = base_path.read_text()
    paths = {'helper': HERE.parent / 'runtime/adapter.inc.c',
             'direct': HERE.parent / 'runtime/adapter-direct.inc.c',
             'take': HERE.parent / 'runtime/take-pair.inc.c',
             'private': HERE / 'adapter.inc.c',
             'general': HERE / 'general-runtime.inc.c',
             'probe': HERE / 'probe-runtime.inc.c'}
    components = {key: path.read_text() for key, path in paths.items()}
    runtime = (a.runtime / 'runtime.c').read_text()
    selected = S.runtime_text_ok(runtime, base, components)
    source = a.source.read_text()
    template_paths = [HERE / 'lower.bend', HERE / 'library.bend',
                      HERE / 'wrapper-spare.bend', HERE / 'namespace.bend']
    if 'general' in selected:
        template_paths.append(HERE / 'general.bend')
    if 'NxoCall{' in source:
        template_paths.append(HERE.parent / 'calls/runtime-library.bend')
    expected = {}
    for path in template_paths:
        expected.update(S.definitions(path.read_text()))
    override_paths = [HERE / 'namespace-overrides.json', HERE / 'predicate-overrides.json',
                      HERE / 'general-overrides.json',
                      HERE.parent / 'calls/runtime-overrides.json',
                      HERE / 'wrapper-spare-overrides.json']
    allowed = {}
    for path in override_paths:
        for replacement in json.loads(path.read_text())['replacements']:
            allowed.setdefault(replacement['name'], []).append(replacement['new'])
    wrapper = json.loads(override_paths[-1].read_text())['replacements']
    fast = next(row for row in wrapper if row['name'] == 'nx110rt_rebuild_fast')
    for replacement in wrapper:
        if expected[replacement['name']] != replacement['old']:
            raise ValueError('wrapper override origin changed')
    combined_path = HERE / ('wrapper-' + a.variant + '-overrides.json')
    combined = json.loads(combined_path.read_text())['replacements'][0]
    if expected[combined['name']] != combined['old']:
        raise ValueError('combined override origin changed')
    allowed[combined['name']] = [combined['new']]

    def source_ok(text):
        S.source_ok(text, expected, allowed, fast['new'])
        if S.definitions(text).get(combined['name']) != combined['new']:
            raise ValueError('exact selected combined template required')
        return True

    source_ok(source)
    mutations = {
        'reject-spare-not-reset': source.replace(
            'NxSet{"ir_spare",nx110rt_u(0)}', 'NxSet{"ir_spare",nx110rt_u(1)}'),
        'reject-spare-from-source-shell': source.replace(
            'NxSet{"ir_spare",NxVar{"ir_loc"}}', 'NxSet{"ir_spare",NxVar{"ir_src"}}'),
        'reject-reservation-without-rfc': source.replace(
            'NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},\n     [NxIf{nx110rtw_raw_constructor',
            'NxIf{NxConst{NxU32{},1},\n     [NxIf{nx110rtw_raw_constructor'),
        'reject-reservation-for-existing-rfc': source.replace(
            'NxIf{nx110rtw_raw_constructor("ir_tail"),', 'NxIf{NxConst{NxU32{},1},'),
        'reject-wrapper-count-two': source.replace(
            'NxBin{"or",NxBin{"shl",nx110rt_loc(NxVar{word}),nx110rt_u(24)},nx110rt_u(1)}},\n   NxSet{word',
            'NxBin{"or",NxBin{"shl",nx110rt_loc(NxVar{word}),nx110rt_u(24)},nx110rt_u(2)}},\n   NxSet{word'),
        'reject-rfc-to-static-fast-admission': source.replace(
            'NxSet{"ir_ok",nx110rt_dynamic(NxVar{"ir_src"})}',
            'NxSet{"ir_ok",NxConst{NxU32{},1}}'),
        'reject-missing-unused-spare-release': source.replace(
            '[NxSet{"ir_spare",NxVar{"ir_loc"}}],nx110rt_free_wrapper()',
            '[NxSet{"ir_spare",NxVar{"ir_loc"}}],[]'),
        'reject-external-seal-omission': source.replace(
            'nx110rt_seal("ir_tail"),nx110rtw_seal_spare("ir_tail")',
            '[],nx110rtw_seal_spare("ir_tail")'),
        'reject-private-namespace-gate-removal': source.replace(
            'nx110rtn_check(ownership,arity,next) && ', ''),
        'reject-unselected-combined-template': source.replace(combined['new'], combined['old']),
        'reject-child-load-from-wrapper': source.replace(
            'NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}}',
            'NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_loc"}),0}}'),
        'reject-shell-write-before-child-loads': source.replace(
            'NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}}',
            'NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0,NxVar{"ir_tail"}},\n     '
            'NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}}'),
    }
    controls = [dict(name=name, ok=text != source and S.refused(
        lambda text=text: source_ok(text))) for name, text in mutations.items()]
    runtime_mutations = {
        'reject-unsealed-dynamic-head': runtime.replace(
            'e.mem[loc] = rfc_seal(e, head);', 'e.mem[loc] = head;', 1),
        'reject-unsealed-dynamic-tail': runtime.replace(
            'e.mem[loc + 1] = rfc_seal(e, tail);', 'e.mem[loc + 1] = tail;', 1),
        'reject-static-writer-in-heap': runtime.replace(
            'Loc loc = STAT_OFF + ctx->static_words;',
            'Loc loc = HEAP_OFF + ctx->static_words;', 1),
        'reject-new-raw-writer': runtime + '\nvoid unsafe_payload(Env e, Loc p, Term t) { e.mem[p] = t; }\n',
    }
    controls += [dict(name=name, ok=text != runtime and S.refused(
        lambda text=text: S.runtime_text_ok(text, base, components)))
        for name, text in runtime_mutations.items()]
    if not all(row['ok'] for row in controls):
        raise ValueError('combined source refusal failed: ' + repr(controls))
    record = dict(kind='phase110-wrapper-combined-admission', version=1,
        variant=a.variant, complete=True, targetsRun=False, runtimeComponents=selected,
        runtimeChain=[S.pin(path) for path in chain],
        inputs=[S.pin(a.source), S.pin(a.runtime / 'runtime.c'), S.pin(base_path),
                S.pin(Path(__file__)), S.pin(HERE / 'stored-field-admit-v2.py'),
                *[S.pin(path) for path in paths.values()],
                *[S.pin(path) for path in template_paths + override_paths], S.pin(combined_path)],
        requiredConjunction=['authenticated dynamic stored-field seal fixedpoint',
            'exclusive consumed last-owner class0 wrapper spare',
            'private canonical ownership namespace', 'exact regenerated private graph',
            'closed ordinary owning-call catalogue when present'],
        owningSpareInvariant='Zero or one exclusive consumed last-owner class0 wrapper; reserve only for raw external CTR, consume once into count1 redirect then clear. The dynamic source shell remains owned and live.',
        delayedReads=a.variant == 'delayed',
        physicalFrame='The live class1 source shell is distinct from consumed/fresh/free class0 wrapper blocks. Wrapper sealing/free/allocation does not write live payloads. Both old-child reads precede either shell write. Cached heap base is fixed under corpus extension; no concurrent mutation or callbacks.',
        aliasCases='External other may overlap retained/remaining descendants or static payloads: seal writes only its fresh/exclusive wrapper, never its payload. A raw external alias to the uniquely owned dynamic parent itself is excluded by valid acyclic ownership. Existing RFC other is not resealed; raw static other is wrapped.',
        parentFallback='Shared, direct static, and count1 RFC-to-static parents fall back before any private fast mutation.',
        exclusions=['fabricated Terms or arbitrary payload writers', 'concurrent mutation',
                    'cyclic/invalid owning graphs', 'unknown source/runtime components'],
        limitation='Composition of separate safe models plus authenticated source/frame premises and physical probes; not a mechanized physical-heap, load-motion, or C-compiler proof',
        controls=controls)
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, variant=a.variant,
                         controls=len(controls), manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
