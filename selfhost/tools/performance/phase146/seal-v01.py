#!/usr/bin/env python3
"""Authenticate this bounded native checkpoint; no compiler targets executed."""
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def need(value, message):
    if not value:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as stream:
        while chunk := stream.read(65536):
            h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def verify(item):
    need(pin(item['file']) == item, 'Changed input: '+item['file'])
    return Path(item['file'])


def main():
    outputs = ROOT/'implementation/phase146'
    need(not (outputs/'qualification.json').exists() and not (outputs/'candidate.json').exists(), 'Fresh seal outputs')
    evidence = []

    def read(path, checked=True):
        path = ROOT/path
        data = json.loads(path.read_text())
        if checked:
            need(data.get('complete') is True, 'Incomplete '+str(path))
        evidence.append(pin(path))
        return data

    parent = read('implementation/phase144/final04/candidate.json')
    manifest = read('selfhost/build/phase146/source03/manifest.json')
    api = read('selfhost/build/phase111/p146-api03/report.json')
    controls = read('selfhost/build/phase146/source03/controls/report.json')
    need(api['checked'] and api['status'] == 0 and manifest['source'] in api['inputs'], 'Independent source check')
    for data in [manifest, api, controls]:
        for item in data['inputs']:
            verify(item)
    need(sum(len(g['rows']) for g in controls['groups']) == 76 and
         all(row.startswith('PASS ') for g in controls['groups'] for row in g['rows']), '76 finite controls')
    old = C.blocks(verify(parent['source']).read_text(), combine=True)
    new = C.blocks(verify(manifest['source']).read_text(), combine=True)
    need(sorted(name for name in old if C.norm(old[name]) != C.norm(new[name])) == ['p128raw_session_finish'], 'Sole original override')
    for name in set(manifest['protectedDeclarations']) | set(manifest['unchangedProofDeclarations']):
        need(C.norm(old[name]) == C.norm(new[name]), 'Protected declaration '+name)
    builds = [read('selfhost/build/phase134/p146-context01-'+n+'/report.json') for n in ['n1', 'n2']]
    n1, n2 = builds
    for build in builds:
        need(build['source'] == manifest['source'] and build['runtime'] == parent['runtime'], 'Same source/runtime')
        need(build['compilerExitCode'] == build['qbeExitCode'] == 0, 'Successful compiler and QBE')
        need(all(j['exitCode'] == 0 for j in build['jobs']), 'Machine construction')
        for item in build['inputs']:
            verify(item)
        for key in ['assembly', 'object', 'binary']:
            verify(build[key])
    need(n1['image'] == parent['native'] and n2['image'] == n1['binary'], 'Actual parent -> N1 -> N2')
    need(n2['comparedToReference'] and n2['expectedQbe'] == n1['retainedIR'] and n1['irDigest'] == n2['irDigest'], 'Q1/Q2 full-stream digest')
    need({k:n1['object'][k] for k in ['bytes','sha256']} == {k:n2['object'][k] for k in ['bytes','sha256']}, 'Identical machine objects')
    stream = read('selfhost/build/phase146/full-stream01/report.json')
    need(stream['source'] == manifest['source'] and stream['expectedQbe'] == n1['retainedIR'], 'Same Q3 input/reference')
    need([r['image'] for r in stream['rows']] == [parent['native'], n2['binary']], 'Fresh baseline and actual N2')
    need(all(r['complete'] and r['literalByteExact'] and r['digest'] == n2['irDigest'] for r in stream['rows']), 'Observed Q3 literal equality')
    for item in stream['inputs']:
        verify(item)
    suites = []
    for name, image, expected in [('n1-focused19', n1['binary'], (16,3)), ('n2-focused19', n2['binary'], (16,3)), ('n2-full45', n2['binary'], (45,0))]:
        suite = read('selfhost/build/phase111/p146-'+name+'/report.json')
        need(suite['passed'] and image in suite['inputs'] and parent['runtime'] in suite['inputs'], 'Actual suite producer/runtime')
        need((suite['summary']['semanticPasses'], suite['summary']['expectedRefusals']) == expected, 'Frozen suite counts')
        for item in suite['inputs']:
            verify(item)
        exact = 0
        for row in suite['rows']:
            emission = json.loads(verify(row['emission']).read_text())
            for item in emission['inputs']:
                verify(item)
            if not row['semanticPass']:
                need(row['expectedRefusal'], 'Unqualified row')
                continue
            need(emission['comparison']['byteExact'], 'Complete same-mode parent QBE comparison')
            verify(row['product'])
            verify(row['binary'])
            verify(row['observation'])
            exact += 1
        suites.append(dict(name=name, summary=suite['summary'], exactParentQbe=exact, seconds=suite['seconds']))
    qualification = dict(kind='phase146-native-qualification', complete=True, sourceChecked=True, nativeQualified=True,
        source=manifest['source'], n1=n1['binary'], n2=n2['binary'], runtime=parent['runtime'], finiteControls=76,
        q1q2CompleteStreamDigest=True, q3ObservedLiteralEqual=True, qbe=n2['irDigest'], machineObjectsEqual=True,
        completeElfsEqual=False, suites=suites, inputs=[pin(__file__), *evidence],
        scope='Qualified ordinary serial native route: independent source check, unchanged public verifiers/proofs, finite controls, qualified parent -> N1 -> N2, Q1=Q2 digest and actual Q3 literal equality, both focused19 and N2 ordinary45 with exact parent QBE and independent execution/refusal oracles. No universal correctness theorem, fresh runtime-performance corpus, broad incremental qualification, new upstream ratio or default change.')
    for item in qualification['inputs']:
        verify(item)
    (outputs/'qualification.json').write_text(json.dumps(qualification, indent=2)+'\n')
    candidate = dict(kind='phase146-retained-context-native-candidate', complete=True, sourceChecked=True, nativeQualified=True,
        incrementalQualified=False, selected=False, installed=False, defaultSelectionChanged=False,
        source=manifest['source'], sourceManifest=pin(ROOT/'selfhost/build/phase146/source03/manifest.json'),
        checkedApi=pin(ROOT/'selfhost/build/phase111/p146-api03/report.json'), api=api['api'],
        native=n2['binary'], n1=n1['binary'], n2=n2['binary'], nativeBuild=pin(ROOT/'selfhost/build/phase134/p146-context01-n2/report.json'),
        nativeObject=n2['object'], qualification=pin(outputs/'qualification.json'), runtime=parent['runtime'],
        runtimePolicy=parent['runtimePolicy'], preferredCarrierReceipt=parent['preferredCarrierReceipt'],
        preferredCarrier=parent['preferredCarrier'], preferredStamp=parent['preferredStamp'], base=parent['base'],
        qualifiedFallback=pin(ROOT/'implementation/phase144/final04/candidate.json'), sourceLines=manifest['sourceLines'],
        sourceProofScope='Original proof declarations preserved, no new theorem. Private context provenance is source-audited and finitely checked.',
        qualificationScope=qualification['scope'])
    (outputs/'candidate.json').write_text(json.dumps(candidate, indent=2)+'\n')
    print(json.dumps(dict(complete=True, candidate=pin(outputs/'candidate.json'), suites=suites)))


if __name__ == '__main__':
    main()
