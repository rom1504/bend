#!/usr/bin/env python3
"""Bind the private wrapper-spare ownership template to authenticated source."""
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
    paths = {'helper': HERE.parent / 'runtime/adapter.inc.c',
             'direct': HERE.parent / 'runtime/adapter-direct.inc.c',
             'take': HERE.parent / 'runtime/take-pair.inc.c',
             'private': HERE / 'adapter.inc.c',
             'general': HERE / 'general-runtime.inc.c',
             'probe': HERE / 'probe-runtime.inc.c'}
    components = {key: path.read_text() for key, path in paths.items()}
    runtime = (a.runtime / 'runtime.c').read_text()
    selected = S.runtime_text_ok(runtime, base_path.read_text(), components)
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
    S.source_ok(source, expected, allowed, fast['new'])
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
    }
    controls = [dict(name=name, ok=text != source and S.refused(
        lambda text=text: S.source_ok(text, expected, allowed, fast['new'])))
        for name, text in mutations.items()]
    altered = source.replace('nx110rtn_check(ownership,arity,next) && ', '')
    controls.append(dict(name='reject-private-namespace-gate-removal', ok=altered != source and
        S.refused(lambda: S.source_ok(altered, expected, allowed, fast['new']))))
    if not all(row['ok'] for row in controls):
        raise ValueError('wrapper source refusal failed: ' + repr(controls))
    record = dict(kind='phase110-wrapper-spare-admission', version=2,
        complete=True, targetsRun=False, runtimeComponents=selected,
        runtimeChain=[S.pin(path) for path in chain],
        inputs=[S.pin(a.source), S.pin(a.runtime / 'runtime.c'), S.pin(base_path),
                S.pin(Path(__file__)), S.pin(HERE / 'stored-field-admit-v2.py'),
                *[S.pin(path) for path in paths.values()],
                *[S.pin(path) for path in template_paths + override_paths]],
        owningSpareInvariant='ir_spare=0 or one exclusively owned consumed class0 RFC wrapper; created only after both child loads from an eligible count1 dynamic parent; either not reserved and freed, or consumed once into an external raw CTR redirect and cleared',
        eligibility='Existing dynamic-parent classifier, RFC count exactly1, decoded source>=HEAP_OFF, external other topbyte exactly2. Raw static other is included because production rfc_seal wraps it.',
        retainedField='The original retained-head seal stays present; this candidate is exclusive with stored-field omission.',
        allocator='Uses an already owned class0 block; neither free nor allocation occurs on the reserved path. Unreserved path uses exact original free/seal transitions. No new allocator or layout.',
        preserved=['decoded values and independent owners', 'remaining child transfer',
                   'shared/static fallback before mutation', 'empty scratch and zero live ownership'],
        intentionallyNotEqual=['RFC wrapper physical addresses', 'allocator free-list/handoff schedule',
                               'transient allocation count or timing'],
        limitation='Exact source admission plus separate safe ownership model and runtime controls; not a mechanized physical-heap or C-compiler proof',
        controls=controls)
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, controls=len(controls),
                         manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
