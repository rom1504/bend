"""Bind exact Phase141 ordinary native evidence; no compiler/target execution."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('phase141_native_authority', ROOT / 'selfhost/tools/performance/phase131/native/qualify.py')
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
Q, C, require = V.Q, V.C, V.require
SOURCE_SHA = 'f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a'
SELECTION = ROOT / 'implementation/phase137/candidate.json'
POLICY = ROOT / 'selfhost/build/phase130/n1-n2-timing01.json'
CARRIER = ROOT / 'selfhost/build/phase130/base-carrier01/receipt.json'
FILES = {
    'sourceManifest': 'phase141/integrated-source02/manifest.json',
    'checkedApi': 'phase111/p141-exact-api/report.json',
    'finite': 'phase141/exact-finite01/report.json',
    'acquisition': 'phase130/p141-integrated-emit01/report.json',
    'n1Build': 'phase111/p141-integrated-n1/report.json',
    'selfEmission': 'phase130/p141-integrated-self01/report.json',
    'n2Build': 'phase111/p141-integrated-n2/report.json',
    'firstFocused': 'phase111/p141-integrated-focused19/report.json',
    'finalFocused': 'phase111/p141-n2-focused19/report.json',
    'finalFull45': 'phase111/p141-n2-full45/report.json',
}
FILES = {k: ROOT / 'selfhost/build' / v for k, v in FILES.items()}
FROZEN = {
    SELECTION: '1aa448660135c1dc61a97229f085a732ee40635ce4b93e6a7b355b54c5b1b5c0',
    Path(V.__file__): '28a5d00beb5744d8d41c192f5efca3926a28a0b78952124f7123b43b45626e14',
    POLICY: '458c7f9a302bdb57b0749ff3a0e44e477fe0a6e01eaf6aa13f254c0e5148cf29',
    ROOT / 'selfhost/tools/performance/phase141/finite.mjs': '5fe12cbc376fd18cad048adfdea267c0633889067e36493eda821d44b890e457',
}


def document(path):
    """Retain a prior authority, without rereading its historical campaign."""
    V.retain(Q.pin(path))
    return json.loads(Path(path).read_text())


def source_contract(selected):
    sm, api, finite = (V.read(FILES[k]) for k in ['sourceManifest', 'checkedApi', 'finite'])
    source = sm['source']
    require(sm['kind'] == 'phase141-explicit-replacement' and sm['complete']
            and source['sha256'] == SOURCE_SHA, 'Exact source02 composition required')
    contract_path = ROOT / 'selfhost/tools/performance/phase141/integrated-contract-v02.json'
    contract = V.read(contract_path)
    require(Q.pin(contract_path) in sm['inputs'] and contract['source'] == sm['parent'], 'Composition authority differs')
    before = C.blocks(Path(sm['parent']['file']).read_text(), True)
    after = C.blocks(Path(source['file']).read_text(), True)
    patch = {}
    for row in contract['modules']:
        require(row in sm['inputs'], 'Overlay missing from source inputs')
        current = C.blocks(Q.verify(row).read_text(), True)
        require(not patch.keys() & current.keys(), 'Duplicate overlay declaration')
        patch.update(current)
    deleted, overrides = set(contract['deleteNames']), set(contract['overrides'])
    require(set(sm['deleted']) == deleted and set(sm['overrides']) == overrides
            and set(sm['added']) == patch.keys() - before.keys()
            and patch.keys() & before.keys() == overrides
            and not deleted & patch.keys()
            and after.keys() == (before.keys() - deleted) | patch.keys(), 'Declaration inventory differs')
    for name in after:
        expected = patch.get(name, before.get(name, ''))
        if name in overrides:
            # The composer preserves an existing forward law verbatim.
            hits = list(C.PAT.finditer(before[name]))
            laws = [before[name][h.start():hits[i + 1].start() if i + 1 < len(hits) else len(before[name])]
                    for i, h in enumerate(hits) if before[name][h.start():].startswith('law ')]
            expected = ''.join(laws) + expected
        require(C.norm(after[name]) == C.norm(expected), 'Unexpected source body: ' + name)
    order = {m[1]: m.start() for m in C.PAT.finditer(Path(source['file']).read_text())}
    require(sm.get('insertBefore') == contract.get('insertBefore'), 'Template placement inventory differs')
    for anchor, names in contract.get('insertBefore', {}).items():
        positions = [order[n] for n in names] + [order[anchor]]
        require(positions == sorted(positions) and len(set(positions)) == len(positions), 'Template order differs')
    parent = C.blocks(Q.verify(selected['source']).read_text(), True)
    protected = (C.ENTRY_GATES | set(C.blocks(C.DIRECT_VERIFIER.read_text()))
                 | set(selected['proofScope']['exactDeclarations'])
                 | {n for n in parent if n.startswith(('p111v_', 'p113a_', 'p113d_', 'p113e_'))})
    require(all(n in after and C.norm(after[n]) == C.norm(parent[n])
                for n in protected & parent.keys() - {'p111_native_args'}), 'Qualified final gate/proof changed')
    # Phase140 adds distinct batch/session arities; qualify only the unchanged
    # ordinary six-word request arm, never those experimental entry points.
    marker = '    case Con{program,Con{+path,'
    require(marker in parent['p111_native_args'] and marker in after['p111_native_args']
            and C.norm(parent['p111_native_args'].split(marker, 1)[1])
            == C.norm(after['p111_native_args'].split(marker, 1)[1]), 'Ordinary native request routing changed')
    parent_api = V.bound(selected['checkedApi'])
    require(parent_api.get('complete') and parent_api.get('checked') and parent_api['status'] == 0,
            'Qualified parent checker receipt differs')
    require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked')
            and api['status'] == 0 and source in api['inputs']
            and api['command'] == parent_api['command'][:2] + [source['file'], api['api']['file']] + api['exports']
            and api['exports'] == parent_api['exports'] + ['p140tc_controls'], 'Direct checked-source/API binding differs')
    for old in parent_api['inputs']:
        if old != selected['source']:
            require(any((r['bytes'], r['sha256']) == (old['bytes'], old['sha256']) for r in api['inputs']),
                    'Independent checker authority changed: ' + old['file'])
    rows = [name + ':pass' for name in re.findall(r'p128bs_control_row\("([^"]+)"', before['p140tc_controls'])]
    require(len(rows) == 19 and finite.get('kind') == 'phase141-finite' and finite.get('complete')
            and finite['entry'] == 'p140tc_controls' and finite['expected'] == 19 and finite['rows'] == rows
            and all(r in finite['inputs'] for r in [Q.pin(FILES['checkedApi']), api['api'], source,
                Q.pin(ROOT / 'selfhost/tools/performance/phase141/finite.mjs')]), 'Exact finite source/API gate differs')
    return source, api['api'], dict(declarationsMatchContract=True,
        protectedDeclarations=sorted((protected & parent.keys()) - {'p111_native_args'}),
        ordinaryNativeArmUnchanged=True, experimentalEntryPointsExcluded=['phase140-batch', 'phase140-session'],
        sourceManifest=Q.pin(FILES['sourceManifest']), contract=Q.pin(contract_path),
        checkedApi=Q.pin(FILES['checkedApi']), finite=Q.pin(FILES['finite']))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'selfhost/build/phase141/qualification01.json')
    args = parser.parse_args()
    require(not args.out.exists() and args.out.resolve().is_relative_to(ROOT / 'selfhost/build/phase141'), 'Fresh Phase141 output required')
    require(all(p.is_file() for p in FILES.values()), 'Required chain/coverage receipts are not all ready')
    for path, sha in {**{p: h for p, h in V.FROZEN.items() if p != V.SELECTION}, **FROZEN}.items():
        require(Q.pin(path)['sha256'] == sha, 'Frozen authority changed: ' + str(path))
        V.retain(Q.pin(path))
    selected = document(SELECTION)
    qualification = document(Q.verify(selected['qualification']))
    require(selected.get('complete') and selected.get('nativeQualified') and qualification.get('complete')
            and qualification.get('nativeQualified') and selected['source'] == qualification['source']
            and selected['runtime'] == qualification['runtime']
            and selected['preferredNative'] == selected['n3'] == qualification['finalImage'], 'Qualified Phase137 producer differs')
    producer, runtime = selected['preferredNative'], selected['runtime']
    V.retain([producer, runtime, selected['source'], selected['api']])
    source, api, bodies = source_contract(selected)
    policy = document(POLICY)
    require(policy['runtime'] == runtime, 'Native policy runtime differs')
    V.retain(policy['tools'])
    q1 = V.emission(FILES['acquisition'], producer, source, runtime, CARRIER)
    n1 = Q.build(V.read(FILES['n1Build']), q1, runtime, policy['tools'])
    q2 = V.emission(FILES['selfEmission'], n1, source, runtime, CARRIER)
    n2 = Q.build(V.read(FILES['n2Build']), q2, runtime, policy['tools'])
    require(V.exact(q1, q2), 'Required complete Q1/Q2 byte reproduction differs')
    gates = [V.coverage(FILES['firstFocused'], n1, FILES['n1Build'], runtime, policy['tools']),
             V.coverage(FILES['finalFocused'], n2, FILES['n2Build'], runtime, policy['tools']),
             V.coverage(FILES['finalFull45'], n2, FILES['n2Build'], runtime, policy['tools'], broad=True)]
    V.retain(Q.pin(__file__))
    result = dict(kind='phase141-ordinary-native-qualification', complete=True, nativeQualified=True, targetsRun=False,
        source=source, api=api, runtime=runtime, sourceContract=bodies, producer=producer,
        producerSelection=Q.pin(SELECTION), producerQualification=selected['qualification'], carrierReceipt=Q.pin(CARRIER),
        policy=Q.pin(POLICY), n1=n1, n2=n2, qbe=dict(q1=q1, q2=q2), finalImage=n2,
        requiredQbeByteExact=True, reproducedQbe=dict(left=q1, right=q2), semanticGates=gates,
        reports={k: Q.pin(p) for k, p in FILES.items()}, inputs=list(V.INPUTS.values()),
        selected=False, installed=False, productionSelectionChanged=False, incrementalQualified=False,
        scope='Exact independently checked source02; qualified Phase137 N3→N1→N2 ordinary native chain. '
              'Q1=Q2 bytes; focused19 on N1/N2 and frozen ordinary45 on N2. '
              'Not full language conformance, a compiler theorem, an ELF fixed point, a performance claim or promotion. '
              'Phase140 incremental/session/batch paths remain experimental and outside this qualification.')
    for row in V.INPUTS.values():
        require(Q.pin(row['file']) == row, 'Input changed during qualification: ' + row['file'])
    with args.out.open('x') as f:
        f.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, nativeQualified=True, finalImage=n2, report=Q.pin(args.out))))


if __name__ == '__main__':
    main()
