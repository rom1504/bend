"""Issue bounded acquisition admission for exact combined-fast-source02; data only."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p131_native_binder', HERE / 'qualify.py')
V = importlib.util.module_from_spec(spec); spec.loader.exec_module(V)
ROOT, pin, require = V.ROOT, V.Q.pin, V.require
RAW = ROOT / 'selfhost/build/phase131'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--semantic-out', type=Path, required=True)
    a = p.parse_args()
    for path in (a.out, a.semantic_out):
        require(not path.exists() and path.resolve().is_relative_to(RAW), 'Fresh Phase131 output required')
    selection = V.read(V.SELECTION)
    source_path = RAW / 'combined-fast-source02/manifest.json'
    api_path = ROOT / 'selfhost/build/phase111/p131-combined-fast-api02/report.json'
    sm, api = V.read(source_path), V.read(api_path)
    require(sm['source']['sha256'] == '7f7952989ca1dd4b9c5246ee7f2fdbdee6c9b0e1a603f2bfb2244d76a75d22fd'
            and api['api']['sha256'] == '3b47745d704bc0262dc9ae98c58fa0bc7c6f88e609ac08f4f4a0eef2cfb834dc',
            'Exact selected combined source/API required')
    paths = {k: RAW / ('combined-fast-' + k + '02/report.json')
             for k in ['usage', 'identity', 'read', 'lookup', 'request']}
    checks = {k: V.read(f) for k, f in paths.items()}
    methods = {'usage': 'regions/finite.mjs', 'identity': 'identity/check.mjs',
               'read': 'identity/read-check.mjs', 'lookup': 'identity/lookup-check.mjs',
               'request': 'identity/combined-request-check.mjs'}
    for role, report in checks.items():
        require(report.get('complete'), 'Combined control incomplete: ' + role)
        method = ROOT / 'selfhost/tools/performance/phase131' / methods[role]
        require(all(x in report['inputs'] for x in [pin(method), pin(api_path), api['api'], sm['source']]),
                'Combined control source/API/method mismatch: ' + role)
        guard = V.read(RAW / ('combined-fast-' + role + '-guard02/process.json'))
        require(guard.get('complete') and guard['returncode'] == 0, 'Control guard not closed: ' + role)
    u, i, r, l, q = [checks[k] for k in ['usage', 'identity', 'read', 'lookup', 'request']]
    require(u['source'] == sm['source'] and u['sourceManifest'] == pin(source_path), 'Usage source mismatch')
    require(len(u['groups']) == 1, 'Usage group inventory differs')
    group = u['groups'][0]
    require(group['name'] == 'p131u_controls' and group['expectedCount'] == 22 and group['complete']
            and len(group['rows']) == 22 and all(x.endswith(':pass') for x in group['rows']), 'Usage controls differ')
    require(i['kind'] == 'phase131-patricia-differential' and i['caseCount'] == len(i['cases']) == 336
            and i['queryCount'] == 11088 and all(c['wholeTreeEqual'] and c['lookupEqual']
                and c['independentPayloadOracle'] for c in i['cases']), 'Insertion whole-tree/oracle failure')
    require(r['treeCases'] == len(r['cases']) == 336 and r['queries'] == 11088
            and sum(c['queries'] for c in r['cases']) == 11088
            and r['malformedQueries'] == len(r['malformed']) == 840
            and all(c['selectedOriginalAndCloneAndCandidateEqual'] for c in r['cases'])
            and all(c['equal'] for c in r['malformed']), 'Read-loop whole-payload failure')
    require(l['caseCount'] == len(l['cases']) == 2656
            and all(c['exactOriginal'] and c['independentExpected'] for c in l['cases']), 'Catalogue lookup failure')
    require(q['source'] == sm['source'] and q['parent'] == selection['source'], 'QBE comparison source differs')
    wanted = {(name, role) for name in ['lexer', 'coverage-closures-256', 'coverage-map-churn-128']
              for role in ['parent', 'candidate']}
    require(len(q['rows']) == 6 and {(c['name'], c['label']) for c in q['rows']} == wanted,
            'Whole-QBE matrix differs')
    for row in q['rows']:
        require(row['round'] == 0 and row['byteIdentical'] and V.exact(row['product'], row['oracle']),
                'Complete QBE/oracle bytes differ')
    require(len(q['realBodies']) == 16 and all(c['exactMinMax'] and 4 <= c['nodes'] <= 128
                for c in q['realBodies']), 'Real Base-body usage checks differ')

    bridge_path = RAW / 'combined-fast-source-bridge01/report.json'
    bridge = V.read(bridge_path)
    safe_names = ['p131a_add', 'p131a_low', 'p131a_high', 'P131UEntry', 'p131u_absent']
    require(bridge['complete'] and bridge['candidate'] == sm['source']
            and bridge['exactDeclarations'] == safe_names, 'Actual safe declaration source bridge differs')
    source = Path(sm['source']['file']).read_text()
    actual = V.C.blocks(source)
    for name in safe_names:
        require(not actual[name].startswith('@unsafe'), 'Selected safe helper remains unsafe: ' + name)
    bspec = importlib.util.spec_from_file_location('p131_law_bridge', ROOT / 'selfhost/tools/performance/phase131/laws/source-bridge.py')
    B = importlib.util.module_from_spec(bspec); bspec.loader.exec_module(B)
    require(bridge['method'] == pin(bspec.origin), 'Source bridge method differs')
    for file, names in [('production.bend', safe_names[:3]), ('absent-production.bend', safe_names[3:])]:
        text = (Path(bspec.origin).parent / file).read_text()
        for name in names:
            require(B.declaration(source, name) == B.declaration(text, name), 'Safe body differs: ' + name)
    proof_cases = {
        'laws-add01': ['saturated_sequence_exact'],
        'laws-low01': ['lower_combination_exact'],
        'laws-high01': ['upper_combination_exact'],
        'laws-absent04': ['sequence_missing_identity', 'branch_missing_exact', 'pattern_missing_exact', 'clear_preserves_highs'],
    }
    proofs = []
    for directory, laws in proof_cases.items():
        path = RAW / directory / 'report.json'; proof = V.read(path)
        require(proof['complete'] and proof['independentlyChecked'] and proof['inputsUnchanged']
                and proof['lawNames'] == laws and proof['opaqueDefinitions'] == [], 'Independent helper laws incomplete')
        for key in ['check', 'elaborate', 'kernel']:
            require(proof['rows'][key]['process']['complete']
                    and proof['rows'][key]['process']['returncode'] == 0, 'Law gate failed')
        require(proof['rows']['kernel']['stdout'].strip() == 'ALL PROOFS CHECK'
                and proof['rows']['kernel-negative']['process']['returncode'] == 1
                and 'SOME PROOFS FAIL' in proof['rows']['kernel-negative']['stdout'], 'Independent proof/rejection gate differs')
        required_body = 'absent-production.bend' if directory == 'laws-absent04' else 'production.bend'
        require(any(row['origin'] == pin(Path(bspec.origin).parent / required_body)
                    and V.exact(row['origin'], row['snapshot']) for row in proof['sourceClosure']),
                'Proof does not consume the exact bridged safe bodies')
        proofs.append(dict(report=pin(path), laws=laws))
    V.retain([pin(__file__), pin(V.__file__), pin(bspec.origin)])
    semantic = dict(kind='phase131-combined-fast-semantic-admission', complete=True, passed=True,
        targetsRun=False, source=sm['source'], api=api['api'], checkedApi=pin(api_path),
        checks={k: pin(f) for k, f in paths.items()},
        counts=dict(usage=22, insertionTrees=336, insertionQueries=11088, readTrees=336,
                    readQueries=11088, malformedReads=840, catalogueQueries=2656, wholeQbeProducts=6, realBaseBodies=16),
        exactSourceBridge=pin(bridge_path), independentHelperLaws=proofs,
        proofScope='Only actual p131a_add/low/high saturated-count algebra and p131u_absent list behavior; no proof of unsafe merge, generic traversal, caller integration or compilation.',
        inputs=list(V.INPUTS.values()), scope='Data-only join of actual selected checked API finite controls and three independent frozen QBE oracles. No native generation or universal code-preservation claim.')
    for row in V.INPUTS.values(): require(pin(row['file']) == row, 'Input changed during admission')
    with a.semantic_out.open('x') as f: f.write(json.dumps(semantic, indent=2) + '\n')
    before = V.C.blocks(Path(selection['source']['file']).read_text())
    changed = sorted(n for n in before if V.C.norm(before[n]) != V.C.norm(actual[n]))
    require(changed == ['index_find', 'index_set', 'lookup', 'nh_terms', 'ns_unshared_terms'], 'Unexpected source override')
    admission = dict(kind='phase131-native-acquisition-admission', complete=True, sourceChecked=True,
        source=sm['source'], api=api['api'], runtime=selection['runtime'], sourceBinding=pin(source_path),
        checkedApi=pin(api_path), parentAdmission=selection['admission'], changedDeclarations=changed,
        addedDeclarations=sorted(set(actual) - set(before)), originalVerifiersUnchanged=True,
        runtimeContractsUnchanged=True, semanticChecks=[pin(a.semantic_out)],
        semanticReports={k: pin(f) for k, f in paths.items()}, exactSourceBridge=pin(bridge_path),
        independentHelperLaws=proofs, producerSelection=pin(V.SELECTION), permittedProducer=selection['n1'],
        changeKind='byte-preserving-algorithm-candidate', codegenPolicyDeclarationsUnchanged=True,
        generatedCodePreservation='Established only for the three frozen ordinary sources; full-source reproduction remains mandatory.',
        nativeQualified=False, selected=False, installed=False, targetsRun=False,
        scope='Acquisition permission for exact checked combined source via qualified Phase130 N1. Five private algorithms change; runtime, original gates and other existing declarations unchanged. Not native qualification, installed promotion, or proof of full summary/merge/caller semantics.')
    admission['sourceBodyAudit'] = V.source_contract(admission, selection)
    admission['inputs'] = list(V.INPUTS.values())
    for row in V.INPUTS.values(): require(pin(row['file']) == row, 'Input changed during admission')
    with a.out.open('x') as f: f.write(json.dumps(admission, indent=2) + '\n')
    print(json.dumps(dict(complete=True, source=admission['source'], admission=pin(a.out), semantic=pin(a.semantic_out))))


if __name__ == '__main__': main()
