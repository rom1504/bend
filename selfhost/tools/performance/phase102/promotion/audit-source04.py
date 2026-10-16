#!/usr/bin/env python3
"""Offline candidate04 correspondence to qualified03; no target execution."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/tools/performance/phase102'
RAW = ROOT / 'selfhost/build/phase102'
PARENT_AUDITOR = PHASE / 'qualification/audit-source-v7.py'
spec = importlib.util.spec_from_file_location('phase102_prior_source_audit', PARENT_AUDITOR)
A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)
SOURCE03 = 'b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f'
SOURCE04 = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    assert args.out.resolve().is_relative_to(RAW) and not args.out.exists()
    inputs = {}

    def bind(value):
        item = A.pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict): assert item == {k: value[k] for k in ('file', 'bytes', 'sha256')}
        assert inputs.setdefault(item['file'], item) == item
        return item

    def tree(value):
        if isinstance(value, list):
            for child in value: tree(child)
        elif isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys(): bind(value)
            else:
                for child in value.values(): tree(child)

    def load(value):
        item = bind(value); data = json.loads(Path(item['file']).read_text())
        assert data['complete'] and not data.get('error')
        return item, data

    method = bind(__file__)
    assert bind(PARENT_AUDITOR)['sha256'] == 'e55291d6a4bbae3ecf3e9349806a896cccb6d359f21f8f62c82a8b3e72cc7223'
    admission_pin, admission = load(RAW / 'native-chain03/admission.json')
    assert admission_pin['sha256'] == '585103080cb206fc8a845924147824f18bc1d82cdacabe5b4f9b88f25fab6188'
    assert admission['qualified'] and admission['inputsUnchanged'] and admission['source']['sha256'] == SOURCE03
    parent_pin, parent = load(admission['receipts']['backendSpecific'])
    assert parent['passed'] and parent['inputsUnchanged'] and parent['source'] == admission['source']
    audit_pin, audit = load(parent['declarationBridge'])
    assert audit['passed'] and audit['inputsUnchanged'] and audit['source'] == parent['source']
    assert audit['method'] == bind(PARENT_AUDITOR)
    tree(audit)
    recipe_pin, recipe = load(args.recipe); tree(recipe)
    prior_recipe_pin, prior_recipe = load(recipe['parentRecipe'])
    assert prior_recipe_pin == audit['sourceRecipe'] and recipe['parentCandidate'] == audit['source']
    source = bind(recipe['candidate'])
    assert source['sha256'] == SOURCE04 and recipe['source'] == prior_recipe['source']
    baseline = Path(bind(recipe['source'])['file']).read_text()
    before = Path(bind(audit['source'])['file']).read_text()
    after = Path(source['file']).read_text()
    assert A.replay(baseline, recipe['changes']) == after
    assert A.replay(after, recipe['changes'], True) == baseline
    assert recipe['changes'][:-1] == prior_recipe['changes']
    old = '            u => NF_Worker{name, params, newCode, newDeps, shape}, u => old)'
    new = ('            # Retain the original dependency horizon after eliminating wrappers.\n'
           '            # This is conservative cost metadata; every actual new call stays present.\n'
           '            u => NF_Worker{name, params, newCode, List.append(&2, String, deps, newDeps), shape}, u => old)')
    edit = dict(offset=before.index(old), old=old, new=new)
    assert before.count(old) == 1 and recipe['addedChanges'] == [edit] == recipe['changes'][-1:]
    assert A.replay(before, [edit]) == after and A.replay(after, [edit], True) == before
    old_defs, new_defs = A.declarations(before), A.declarations(after)
    old_types, new_types = A.declarations(before, 'type'), A.declarations(after, 'type')
    assert set(old_defs) == set(new_defs)
    assert {name for name in old_defs if old_defs[name] != new_defs[name]} == {'nfp_replaced'}
    assert new_defs['nfp_replaced'] == old_defs['nfp_replaced'].replace(old, new)
    assert old_types == new_types and A.declarations(before, 'law') == A.declarations(after, 'law')
    for row in audit['exactPermissionDeclarations']:
        assert old_defs[row['name']] == new_defs[row['name']]
        assert A.digest(new_defs[row['name']].encode()) == {k: row[k] for k in ('bytes', 'sha256')}
    for row in audit['auditedPermissionDeclarations']:
        assert old_defs[row['name']] == new_defs[row['name']] == row['afterText']
    for closure in audit['inheritedSafeClosures']:
        _, manifest = load(closure['manifest']) if json.loads(Path(closure['manifest']['file']).read_text()).get('complete') else (bind(closure['manifest']), json.loads(Path(closure['manifest']['file']).read_text()))
        for item in manifest['candidateDefinitions']:
            assert before.count(item['original']) == after.count(item['original']) == 1
    old_bodies, old_edges = A.graph(old_defs, old_types)
    new_bodies, new_edges = A.graph(new_defs, new_types)
    roots = ['no_effect_definitions', 'no_effect_terms', 'ns_source', 'noa_below',
             'nfp_reduce', 'nfp_identity', 'nfp_params', 'nfp_capture_free', 'ntr_hole_policy', 'ne_ctor_node']
    exact_closures = {}
    for root in roots:
        names = A.closure(root, old_edges)
        assert names == A.closure(root, new_edges) and 'nfp_replaced' not in names
        assert all(old_bodies[name] == new_bodies[name] and old_edges[name] == new_edges[name] for name in names)
        exact_closures[root] = dict(exact=True, declarations=[dict(name=name, **A.digest(new_bodies[name].encode())) for name in sorted(names)])
    report = {key: audit[key] for key in ['kind', 'parentSource', 'parentBackendControls',
        'exactPermissionDeclarations', 'auditedPermissionDeclarations', 'inheritedSafeClosures',
        'inheritedRootClosures', 'inheritedBase', 'trmcDestinationPolicyAudit']}
    report.update(complete=True, passed=True, inputsUnchanged=True, targetsRun=False,
        imageQualified=False, wholeCompilerProved=False, method=method, source=source,
        sourceRecipe=recipe_pin, forwardAndInverseExact=True,
        continuityParent=dict(admission=admission_pin, backendControls=parent_pin, sourceAudit=audit_pin,
                              source=parent['source'], recipe=prior_recipe_pin),
        projectionCostDelta=dict(edits=[edit], changedDeclarations=['nfp_replaced'],
            before=A.digest(old_defs['nfp_replaced'].encode()), after=A.digest(new_defs['nfp_replaced'].encode()),
            scope='Only returned dependency metadata gains the original deps. New code, selected parameters, shape, acceptance conditions and fallback are byte-exact. This is a source correspondence, not an operational-equivalence or performance proof.'),
        exactParentClosures=exact_closures,
        scope='Qualified03 facts retain their original source/proof identities. This exact one-expression source bridge supports only the listed unchanged closures. Fresh04 authority and actual04 native image/output gates remain mandatory; inherited03 helper and matrix observations are not fresh04 executions.',
        inputs=list(inputs.values()))
    for item in inputs.values(): assert A.pin(item['file']) == item
    args.out.mkdir(parents=True)
    (args.out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, passed=True, targetsRun=False, source=source, report=str(args.out / 'report.json'))))


if __name__ == '__main__': main()
