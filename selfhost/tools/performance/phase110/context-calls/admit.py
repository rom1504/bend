#!/usr/bin/env python3
"""Authenticate pointer lifetime/layout and the exact context-call source; data only."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
IR = HERE.parent / 'runtime-ir'
spec = importlib.util.spec_from_file_location('source_auth', IR / 'stored-field-admit-v2.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', required=True, type=Path)
    p.add_argument('--source', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    runtime, out = a.runtime.resolve(), a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    manifest = runtime / 'manifest.json'
    capsule = json.loads(manifest.read_text())
    if not capsule.get('complete') or capsule['kind'] != 'phase110-context-call-runtime-core':
        raise ValueError('requires assertion-only context-call runtime capsule')
    for row in capsule['inputs'] + capsule['outputs'] + [capsule['base']]:
        if S.pin(Path(row['file'])) != row:
            raise ValueError('changed runtime input: ' + row['file'])
    parent = Path(capsule['base']['file']).parent
    chain = S.runtime_chain(parent / 'manifest.json')
    base_facts = [row for row in chain.values() if row['kind'] == 'phase109-production-runtime-core']
    if len(base_facts) != 1:
        raise ValueError('one complete production runtime required')
    base_path = Path(next(row['file'] for row in base_facts[0]['outputs'] if row['file'].endswith('/runtime.c')))
    paths = {'helper': HERE.parent / 'runtime/adapter.inc.c',
             'direct': HERE.parent / 'runtime/adapter-direct.inc.c',
             'take': HERE.parent / 'runtime/take-pair.inc.c',
             'private': IR / 'adapter.inc.c', 'general': IR / 'general-runtime.inc.c',
             'probe': IR / 'probe-runtime.inc.c'}
    components = {key: path.read_text() for key, path in paths.items()}
    selected = S.runtime_text_ok((parent / 'runtime.c').read_text(), base_path.read_text(), components)
    assertion = HERE / 'runtime-assert.inc.c'
    expected_runtime = (parent / 'runtime.c').read_text() + '\n' + assertion.read_text()
    if (runtime / 'runtime.c').read_text() != expected_runtime:
        raise ValueError('runtime assertion suffix differs')
    template_paths = [IR / 'lower.bend', IR / 'library.bend', IR / 'namespace.bend',
                      HERE.parent / 'calls/runtime-library.bend']
    if 'general' in selected:
        template_paths.append(IR / 'general.bend')
    template_paths += [HERE / (name + '.bend') for name in ['model', 'lower', 'verify', 'c', 'controls']]
    expected = {}
    for path in template_paths:
        expected.update(S.definitions(path.read_text()))
    override_paths = [IR / 'namespace-overrides.json', IR / 'predicate-overrides.json',
                      IR / 'general-overrides.json', HERE.parent / 'calls/runtime-overrides.json']
    allowed = {}
    for path in override_paths:
        for row in json.loads(path.read_text())['replacements']:
            allowed.setdefault(row['name'], []).append(row['new'])
    baseline = S.definitions((IR / 'lower.bend').read_text())['nx110rt_rebuild_fast']

    def source_ok(text):
        S.source_ok(text, expected, allowed, baseline)
        actual = S.definitions(text)
        if 'nx110rt_calls_ok' not in actual['nx110rt_verify']:
            raise ValueError('closed ordinary-call admission required')
        return True

    source = a.source.read_text()
    source_ok(source)
    mutations = {
        'reject-forwarding-pointer-swap': source.replace(
            'Con{context,Con{NxVar{"ir_heap"},Con{NxVar{"ir_alc"},rest}}}',
            'Con{context,Con{NxVar{"ir_alc"},Con{NxVar{"ir_heap"},rest}}}'),
        'reject-unchecked-public-entry': source.replace(
            'NxSet{"ir_heap",NxCall{"rt_ir_heap",[NxVar{"ctx"}]}}',
            'NxSet{"ir_heap",NxVar{"ctx"}}'),
        'reject-private-offset-change': source.replace(
            'NxLoad{NxPtr{},NxOffset{NxVar{"ctx"},nx110rt_u(0)},8}',
            'NxLoad{NxPtr{},NxOffset{NxVar{"ctx"},nx110rt_u(0)},16}'),
        'reject-open-call-rewrite': source.replace(
            'nx_choose(NxStmt,nxlib_has_name(name,names),u =>',
            'nx_choose(NxStmt,True{},u =>'),
        'reject-namespace-gate-removal': source.replace('nx110rtn_check(ownership,arity,next) && ', ''),
        'reject-closed-call-gate-removal': source.replace('nx110rt_calls_ok(workers,nx110rt_callees(workers)) &&', ''),
        'reject-exact-machine-check-removal': source.replace(
            'nx110ctx_exact(nx110ctx_json(machine),nx110ctx_json(nx110ctx_machine(source,mode))) &&', ''),
    }
    controls = [dict(name=name, ok=text != source and S.refused(lambda text=text: source_ok(text)))
                for name, text in mutations.items()]
    if not all(row['ok'] for row in controls):
        raise ValueError('context-call source refusal failed: ' + repr(controls))
    out.mkdir()
    record = dict(kind='phase110-context-call-admission', complete=True, targetsRun=False,
        inputs=[S.pin(a.source), S.pin(manifest), S.pin(runtime / 'runtime.c'), S.pin(assertion),
                S.pin(Path(__file__)), S.pin(IR / 'stored-field-admit-v2.py'), S.pin(base_path),
                *[S.pin(path) for path in paths.values()],
                *[S.pin(path) for path in template_paths + override_paths]],
        runtimeChain=[S.pin(path) for path in chain], runtimeComponents=selected,
        modes=['threaded', 'context'], publicABI='Unchanged ctx plus owning Terms to one owning Term',
        lifetime='One synchronous admitted single-thread context; env bases assigned at open, close absent from closed call imports, corpus_grow extends without relocation, ALC[0] static address; mutable pointed-to contents remain freshly loaded',
        scratch='Canonical Take/rebuild transfers every pending scratch owner immediately before any ordinary owning-call boundary; getter pending-zero validation retained at every exported entry',
        limitations=['Authenticated source premises and exact graph regeneration, not a mechanized physical-heap proof',
            'No arbitrary native context mutation, callbacks, reentry, concurrent worker or context close within a call tree',
            'Diagnostic after frozen selection; no heldout-driven policy reselection'], controls=controls)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, controls=len(controls), manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
