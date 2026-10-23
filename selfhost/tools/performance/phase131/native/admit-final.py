"""Admit only the final frozen Phase131 composition; no target execution."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase131_admission_base', HERE / 'qualify.py')
V = importlib.util.module_from_spec(spec); spec.loader.exec_module(V)
contract_spec = importlib.util.spec_from_file_location('phase131_final_contract', HERE / 'final-source-contract.py')
F = importlib.util.module_from_spec(contract_spec); contract_spec.loader.exec_module(F); F.install(V)
ROOT, pin, require = V.ROOT, V.Q.pin, V.require
RAW = ROOT / 'selfhost/build/phase131'
TOOLS = ROOT / 'selfhost/tools/performance/phase131'
CASES = ['lexer', 'coverage-closures-256', 'coverage-map-churn-128']
SOURCES = {
    'algorithms': ('combined-first-order', '81957cb20776f8888058fa18c06e4e47d0b1d267b2cdd040e957e2733796eb3f'),
    'codegen': ('combined-literals', '1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'),
}
PROOFS = {
    'laws-add01': 'f28847ecc0988fdb69533989971aa3f6b603f0114457211b73476489adb00112',
    'laws-low01': 'e50bdf453e7c82c20116670138650bcd00efa6ca6684e8ab5b53687c180b3caf',
    'laws-high01': '02e9f02f422c628408b29f90e0c7c5f5af4df381947f89c6631e7ae9e24cacb1',
    'laws-absent04': '064372420c01a9032507da5f80b6e83fc7685eba9321a08fdd07bfce5dcf35fc',
    'laws-first-order-summary01': '1cf45f192ab86119352be6ad69a2906ca10e0cf21981c23773cd3415550b17cb',
}
SAFE = {
    'production.bend': ['p131a_add', 'p131a_low', 'p131a_high'],
    'absent-production.bend': ['P131UEntry', 'p131u_absent'],
    'lookup-first-order-v02.bend': ['p131u_max_loop', 'p131u_max', 'p131u_min_loop', 'p131u_min'],
    'merge-first-order-v01.bend': ['p131u_merge_loop', 'p131u_merge'],
}


def guard(path):
    report = V.read(path)
    require(report.get('complete') and report.get('returncode') == 0, 'Guard did not close successfully')


def proof_bridge(path, source):
    bridge = V.read(path)
    method = TOOLS / 'laws/first-order-source-bridge.py'
    require(pin(method)['sha256'] == '70b2db7fec3d9c39c9747d2f833909ff2037a719cfda1e1b1b10a792da1e30bb',
            'Source bridge method changed')
    names = [n for group in SAFE.values() for n in group]
    require(bridge.get('complete') and bridge['source'] == source and bridge['method'] == pin(method)
            and bridge['exactDeclarations'] == names and bridge['namespaceRemoval'] == ['A.', 'P.'],
            'Exact eleven-declaration source bridge required')
    require(bridge['proofReceipts'] == [pin(RAW / n / 'report.json') for n in PROOFS],
            'Proof receipt set differs')
    snapshots = {}
    for name, sha in PROOFS.items():
        file = RAW / name / 'report.json'; proof = V.read(file)
        require(pin(file)['sha256'] == sha and proof['complete'] and proof['independentlyChecked']
                and proof['inputsUnchanged'] and proof['opaqueDefinitions'] == [], 'Proof authority changed')
        for stage in ['check', 'elaborate', 'kernel']:
            require(proof['rows'][stage]['process']['complete']
                    and proof['rows'][stage]['process']['returncode'] == 0
                    and not proof['rows'][stage]['process'].get('stoppedFor'), 'Proof stage failed')
        require(proof['rows']['kernel']['stdout'].strip() == 'ALL PROOFS CHECK'
                and proof['rows']['kernel-negative']['process']['complete'] is False
                and proof['rows']['kernel-negative']['process']['returncode'] == 1
                and not proof['rows']['kernel-negative']['process'].get('stoppedFor')
                and proof['rows']['kernel-negative']['stdout'] ==
                    'SOME PROOFS FAIL\nIn phase67_false:\nexpected: .left\nobserved: .right\n'
                and proof['rows']['kernel-negative']['stderr'] == '', 'Proof negative control differs')
        for row in proof['sourceClosure']:
            require(V.exact(row['origin'], row['snapshot']), 'Proof snapshot/body differs')
            snapshots[row['origin']['file']] = row['origin']
    def declaration(text, name):
        found = re.findall(r'^(?:def|type) ' + re.escape(name) + r'\b[\s\S]*?(?=\n\n|\Z)', text, re.M)
        require(len(found) == 1, 'Ambiguous safe declaration: ' + name)
        return found[0].strip()
    text = Path(source['file']).read_text(); blocks = V.C.blocks(text)
    for filename, group in SAFE.items():
        origin = TOOLS / 'laws' / filename
        require(pin(origin) in bridge['inputs'] and snapshots[str(origin)] == pin(origin), 'Unproved bridge body')
        for name in group:
            expected = declaration(origin.read_text(), name).replace('A.', '').replace('P.', '')
            require(declaration(text, name) == expected and not blocks[name].startswith('@unsafe'),
                    'Candidate safe declaration differs: ' + name)
    return dict(report=pin(path), declarations=names, proofReceipts=bridge['proofReceipts'],
                scope=bridge['coverage'])


def finite(path, sm, sm_path, api, api_path, codegen):
    report = V.read(path)
    expected = {'p131u_controls': 22}
    if codegen: expected.update(p131sc_controls_v02=19, p131p_controls=14,
                               p128br_call_controls=10, p128raw_br_controls=4,
                               p131rg_controls=13, p128bl_controls=7, p131rv_controls=9)
    require(report.get('complete') and report['source'] == sm['source']
            and report['sourceManifest'] == pin(sm_path), 'Finite source identity differs')
    require(api['api'] in report['inputs'] and pin(api_path) in report['inputs'], 'Finite checked API differs')
    require(any(x['sha256'] == '94181cc6514c1e8d0aacfcd85c19a32efd915054ddecefc6d0e92520ef5d7ccc'
                and x['bytes'] == 3044 for x in report['inputs']), 'Finite method differs')
    groups = report['groups']
    require(len(groups) == len(expected) and {g['name']: g['expectedCount'] for g in groups} == expected,
            'Finite group inventory differs')
    for g in groups:
        require(g['complete'] and len(g['rows']) == g['expectedCount']
                and all(isinstance(x, str) and x.endswith(':pass') for x in g['rows']), 'Finite predicate failed')
    return dict(report=pin(path), groups=expected, count=sum(expected.values()))


def requests(path, sm, api, api_path, selected, fast, codegen):
    report = V.read(path)
    name = 'final-request-v01.mjs' if codegen else 'combined-request-check-v3.mjs'
    method = TOOLS / 'usage' / name
    comparison = fast
    require(report.get('complete') and report['source'] == sm['source']
            and report['parent'] == selected['source'] and report['comparisonParent'] == comparison['source'],
            'Request source comparison differs')
    require(all(x in report['inputs'] for x in [pin(method), api['api'], pin(api_path),
            comparison['api'], comparison['checkedApi'], sm['source']]), 'Request method/API identities differ')
    require(len(report['rows']) == 6 and {(r['name'], r['label'], r['round']) for r in report['rows']}
            == {(n, role, 0) for n in CASES for role in ['parent', 'candidate']}, 'Request matrix differs')
    profiles_path = ROOT / 'selfhost/build/phase129/profile01/manifest.json'
    V.retain(pin(profiles_path)); profiles = json.loads(profiles_path.read_text())
    for row in report['rows']:
        w = next(w for w in profiles['workloads'] if w['name'] == row['name'])
        variant = next(v for v in w['variants'] if v['name'] == 'phase128')
        arg = variant['command'].index('phase111')
        source = next(x for x in variant['inputs'] if x['file'] == variant['command'][arg + 1])
        # Profile stdout carries a descriptive kind alongside its three pin
        # fields. Authenticate the whole manifest, then retain the actual pin.
        oracle = {k: variant['expected']['stdout'][k] for k in ['file', 'bytes', 'sha256']}
        V.retain([source, oracle])
        require(variant['expected']['exitCode'] == 0 and variant['expected']['stdout']['kind'] == 'exact'
                and row['source'] == source and row['oracle'] == oracle, 'Frozen request oracle differs')
        equal = V.exact(row['product'], row['oracle'])
        require(row['byteIdentical'] == equal and row['product']['bytes'] > 0, 'Request product metadata differs')
        require((codegen and row['label'] == 'candidate') or equal, 'Required original QBE bytes differ')
    require(len(report['realBodies']) == 16 and all(x['exactMinMax'] and 4 <= x['nodes'] <= 128
                for x in report['realBodies']), 'Real Base-body observation differs')
    return report


def ordinary(path, request, request_path, selected):
    plan = V.read(path)
    require(plan['complete'] and plan['targetsRun'] is False and plan['source'] == request['source']
            and plan['requestReport'] == pin(request_path), 'Ordinary plan/source differs')
    require(pin(TOOLS / 'usage/codegen-ordinary-jobs.py') in plan['inputs'], 'Ordinary planner differs')
    corpus = V.read(ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json')
    tools = V.read(V.Q.BASE)['tools']
    require(len(plan['cases']) == 3 and {r['name'] for r in plan['cases']} == set(CASES), 'Ordinary case inventory differs')
    result = []
    for case in plan['cases']:
        row = next(r for r in request['rows'] if r['name'] == case['name'] and r['label'] == 'candidate')
        matches = [r for r in corpus['cases'] if r.get('source88') == row['source']]
        require(len(matches) == 1, 'Independent ordinary source missing')
        oracle = matches[0]
        require(case['source'] == row['source'] and case['qbe'] == row['product']
                and case['expected'] == oracle['expectedStdoutEvidence']
                and Path(case['expected']['file']).read_bytes() == oracle['expectedStdout'].encode(),
                'Independent ordinary oracle/product identity differs')
        built = V.read(case['buildReport'])
        binary = V.Q.build(built, row['product'], selected['runtime'], tools)
        require(case['expected'] in built['inputs'] and built['outputExact']
                and [j['label'] for j in built['jobs']] == ['qbe', 'assemble', 'link', 'execute'],
                'Ordinary execution gate incomplete')
        run = built['jobs'][-1]
        require(run['command'] == [binary['file'], '--threads', '1', '--gpu', 'off']
                and run['exitCode'] == 0 and run['stderr']['bytes'] == 0
                and V.exact(run['stdout'], case['expected']), 'Complete ordinary output differs')
        result.append(dict(name=case['name'], build=pin(case['buildReport']), binary=binary,
                           source=case['source'], qbe=case['qbe'], expected=case['expected']))
    return dict(plan=pin(path), cases=result, independentOutputPasses=3)


def transfers(path, sm, sm_path, api, api_path, selected):
    plan = V.read(path); emitted = V.bound(plan['emission'])
    catalog_path = TOOLS / 'usage/final-transfer-cases.json'; catalog = V.read(catalog_path)
    require(plan['complete'] and plan['targetsRun'] is False and plan['source'] == sm['source']
            and plan['api'] == api['api'] and pin(TOOLS / 'usage/transfer-jobs-v2.py') in plan['inputs'],
            'Transfer plan/source identity differs')
    require(emitted['complete'] and emitted['kind'] == 'phase128-request-bound-entry-emission'
            and emitted['entry'] == 'p111_emit_admitted' and emitted['source'] == sm['source']
            and emitted['api'] == api['api'] and emitted['runtime'] == selected['runtime']
            and emitted['derived'] and emitted['borrowed'] and emitted['cold'], 'Transfer emission identity differs')
    require(all(x in emitted['inputs'] for x in [pin(api_path), pin(sm_path), pin(catalog_path),
            pin(ROOT / 'selfhost/tools/performance/phase128/emit-entry.mjs')]), 'Transfer emission method differs')
    names = {'selector-transfer', 'projection-string', 'projection-list', 'compiler-uses'}
    for rows in [catalog['cases'], emitted['cases'], plan['cases']]:
        require(len(rows) == 4 and {x['name'] for x in rows} == names, 'Transfer case inventory differs')
    tools = V.read(V.Q.BASE)['tools']; result = []
    for case in plan['cases']:
        oracle = next(x for x in catalog['cases'] if x['name'] == case['name'])
        row = next(x for x in emitted['cases'] if x['name'] == case['name'])
        require(row['verified'] and row['parentVerified'] and case['source'] == row['source'] == oracle['source']
                and case['qbe'] == row['qbe'] and case['oracle'] == oracle['expected'], 'Transfer source/product differs')
        expected = Path(case['oracle']['file']).read_bytes()
        if Path(case['oracle']['file']).suffix == '.json':
            decoded = json.loads(expected)
            require(decoded['status'] == 0 and decoded['stderr'] == '', 'Transfer independent oracle status differs')
            expected = decoded['stdout'].encode()
        require(Path(case['expected']['file']).read_bytes() == expected, 'Transfer stdout extraction differs')
        built = V.read(case['buildReport'])
        binary = V.Q.build(built, case['qbe'], selected['runtime'], tools)
        require(case['expected'] in built['inputs'] and built['outputExact']
                and [j['label'] for j in built['jobs']] == ['qbe', 'assemble', 'link', 'execute'],
                'Transfer execution incomplete')
        run = built['jobs'][-1]
        require(run['command'] == [binary['file'], '--threads', '1', '--gpu', 'off']
                and run['exitCode'] == 0 and run['stderr']['bytes'] == 0
                and Path(run['stdout']['file']).read_bytes() == expected, 'Complete transfer output differs')
        result.append(dict(name=case['name'], build=pin(case['buildReport']), source=case['source'],
                           qbe=case['qbe'], oracle=case['oracle']))
    return dict(plan=pin(path), emission=plan['emission'], cases=result, independentOutputPasses=4)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--kind', choices=['codegen'], default='codegen')
    p.add_argument('--ordinary-plan', type=Path)
    p.add_argument('--transfer-plan', type=Path)
    for name in ['out', 'semantic-out']: p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args(); codegen = a.kind == 'codegen'; prefix, expected_sha = SOURCES[a.kind]
    for path in [a.out, a.semantic_out]:
        require(not path.exists() and path.resolve().is_relative_to(RAW), 'Fresh Phase131 output required')
    require(bool(a.ordinary_plan) == codegen and bool(a.transfer_plan) == codegen,
            'Codegen requires independent ordinary and exercised transfer executions')
    require(pin(V.__file__)['sha256'] == '28a5d00beb5744d8d41c192f5efca3926a28a0b78952124f7123b43b45626e14',
            'Frozen native source binder changed')
    selected = V.read(V.SELECTION)
    fast_path = RAW / 'combined-fast-admission01.json'; fast = V.read(fast_path)
    require(pin(fast_path)['sha256'] == 'efeb2f06daaa5bef00edabddb9917462ae203203a12560fd7c01549484684a2e'
            and fast['complete'] and fast['sourceChecked'], 'Historical FAST admission changed')
    sm_path = RAW / (prefix + '-source01/manifest.json')
    api_path = ROOT / 'selfhost/build/phase111' / ('p131-' + prefix + '-api01/report.json')
    sm, api = V.read(sm_path), V.read(api_path)
    require(sm['source']['sha256'] == expected_sha, 'Exact successor source required')
    require(api.get('complete') and api.get('checked') and api['status'] == 0, 'Source/API check incomplete')
    bridge = proof_bridge(RAW / (prefix + '-bridge01/report.json'), sm['source'])
    finite_info = finite(RAW / (prefix + '-finite01/report.json'), sm, sm_path, api, api_path, codegen)
    request_path = RAW / (prefix + '-request01/report.json')
    request = requests(request_path, sm, api, api_path, selected, fast, codegen)
    for role in ['api', 'finite', 'request']:
        guard(RAW / (prefix + '-' + role + '01-guard/process.json'))
    ordinary_info = ordinary(a.ordinary_plan, request, request_path, selected) if codegen else None
    transfer_info = transfers(a.transfer_plan, sm, sm_path, api, api_path, selected) if codegen else None
    before = V.C.blocks(Path(selected['source']['file']).read_text())
    after = V.C.blocks(Path(sm['source']['file']).read_text())
    changed = sorted(n for n in before if V.C.norm(before[n]) != V.C.norm(after[n]))
    expected = ['index_find', 'index_set', 'lookup', 'missing', 'nh_terms', 'ns_unshared_terms']
    if codegen: expected += ['nbc_closed', 'nbc_definition', 'P128BRHelper', 'p128br_lookup',
                            'p128br_call', 'p128br_seed', 'p128br_summaries', 'p128br_helper_names',
                            'p128br_scan_ready', 'p128raw_br_scanned']
    require(changed == sorted(sm['overrides']), 'Actual source override inventory differs')
    old = V.C.blocks(Path(fast['source']['file']).read_text())
    transition = dict(changed=sorted(n for n in set(old) & set(after) if V.C.norm(old[n]) != V.C.norm(after[n])),
                      added=sorted(set(after) - set(old)), removed=sorted(set(old) - set(after)))
    qualification = pin(HERE / 'qualify-final.py')
    V.retain([pin(__file__), pin(V.__file__), pin(F.__file__), qualification])
    semantic = dict(kind='phase131-successor-semantic-admission', complete=True, passed=True, targetsRun=False,
        source=sm['source'], api=api['api'], checkedApi=pin(api_path), finite=finite_info,
        exactSourceBridge=bridge, requests=pin(request_path), ordinary=ordinary_info, exercisedTransfers=transfer_info,
        historicalFastEvidence=dict(admission=pin(fast_path), reports=fast['semanticReports'],
            scope='Previously executed on FAST, not rerun or relabelled as successor controls.'),
        transitionFromFast=transition, inputs=[pin(__file__), pin(api_path), pin(sm_path), pin(request_path)],
        transitiveInputs=list(V.INPUTS.values()),
        scope='Actual candidate finite controls and exact proof-body bridge; authenticated successful ordinary requests. '
              + ('Codegen products independently execute against three frozen source-output oracles; raw QBE may differ.'
                 if codegen else 'All six paired request products match the three frozen complete QBE oracles.')
              + ' Bounded acquisition evidence, not native-image qualification or a proof of compilation.')
    for row in V.INPUTS.values(): require(pin(row['file']) == row, 'Input changed during admission')
    with a.semantic_out.open('x') as f: f.write(json.dumps(semantic, indent=2) + '\n')
    admission = dict(kind='phase131-native-acquisition-admission', complete=True, sourceChecked=True,
        source=sm['source'], api=api['api'], runtime=selected['runtime'], sourceBinding=pin(sm_path),
        checkedApi=pin(api_path), parentAdmission=selected['admission'], changedDeclarations=changed,
        addedDeclarations=sorted(set(after) - set(before)), originalVerifiersUnchanged=True,
        runtimeContractsUnchanged=True, semanticChecks=[pin(a.semantic_out)], exactSourceBridge=bridge,
        producerSelection=pin(V.SELECTION), permittedProducer=selected['n1'], qualificationMethod=qualification,
        changeKind='declared-codegen-change' if codegen else 'byte-preserving-algorithm-candidate',
        codegenPolicyDeclarationsUnchanged=not codegen,
        requiredReproduction='N0->N1->N2->N3;Q2=Q3' if codegen else 'N0->N1->N2;Q1=Q2',
        generatedCodePreservation='Not claimed for codegen changes; final Q2/Q3 exact reproduction is mandatory.' if codegen
            else 'Established only on the three frozen ordinary sources; full-source Q1/Q2 equality remains mandatory.',
        nativeQualified=False, selected=False, installed=False, targetsRun=False,
        scope='Permission for exact checked source acquisition via declared qualified Phase130 native N1. '
              'Final focused19 on both compared images and ordinary45 on the final image remain mandatory. '
              'Proof coverage is exactly the eleven bridged safe declarations; no generic traversal, caller or compiler theorem.')
    admission['sourceBodyAudit'] = V.source_contract(admission, selected)
    admission['inputs'] = list(V.INPUTS.values())
    for row in V.INPUTS.values(): require(pin(row['file']) == row, 'Input changed during admission')
    with a.out.open('x') as f: f.write(json.dumps(admission, indent=2) + '\n')
    print(json.dumps(dict(complete=True, admission=pin(a.out), semantic=pin(a.semantic_out),
                         requiredReproduction=admission['requiredReproduction'])))


if __name__ == '__main__': main()
