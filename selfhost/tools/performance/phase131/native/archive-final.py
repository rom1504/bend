"""Archive the completed final qualification and separate compiler/program evidence; data only."""
import argparse
import filecmp
import gzip
import hashlib
import io
import json
from pathlib import Path
import platform
import zlib

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'implementation/phase131/final'
INPUTS = {}


def require(ok, message):
    if not ok: raise ValueError(message)


def pin(path):
    path = Path(path).resolve(); sha = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''): sha.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=sha.hexdigest())


def verify(item):
    row = {k: item[k] for k in ['file', 'bytes', 'sha256']}
    require(pin(row['file']) == row, 'Input changed: ' + row['file'])
    previous = INPUTS.get(row['file'])
    require(previous is None or previous == row, 'Conflicting input: ' + row['file'])
    INPUTS[row['file']] = row
    return Path(row['file'])


def read(path):
    verify(pin(path)); return json.loads(Path(path).read_text())


def copied(source, name):
    source = verify(pin(source)); target = OUT / name
    with target.open('xb') as f: f.write(source.read_bytes())
    require(filecmp.cmp(source, target, shallow=False), 'Archived metadata copy differs')
    return pin(target)


def save(name, value):
    target = OUT / name
    with target.open('x') as f: f.write(json.dumps(value, indent=2) + '\n')
    return pin(target)


def compress(source):
    buffer = io.BytesIO()
    with gzip.GzipFile(filename='', fileobj=buffer, mode='wb', compresslevel=9, mtime=0) as stream:
        stream.write(source)
    return buffer.getvalue()


def timing_block(summary_path, report_path, left, right, left_source, right_source):
    timing, raw = read(summary_path), read(report_path)
    require(timing['complete'] and raw['complete'] and raw['passed'] and raw['inputsUnchanged']
            and not raw['checkOnly'] and pin(report_path) in timing['inputs'] and timing['roles'] == raw['roles'],
            'Timing summary/raw identity differs')
    require(timing['roles']['phase111']['binary'] == left and timing['roles']['phase112']['binary'] == right
            and timing['roles']['phase111']['source'] == left_source
            and timing['roles']['phase112']['source'] == right_source, 'Timing source/image roles differ')
    require(timing['observations'] == len(raw['rows']) == 27 and raw['rounds'] == 3
            and raw['modes'] == ['cache'] and len(timing['cases']) == len(raw['cases']) == 3
            and timing['exactNativeQbeAllCases'] and all(r['passed'] and r['outputExact'] and r['stderrExact'] for r in raw['rows']),
            'Timing matrix incomplete')
    for row in timing['inputs']: verify(row)
    verify(raw['manifest'])
    return timing


def program_binding(path, q):
    equality = read(path)
    require(equality['complete'] and equality['all45ByteExact'] and equality['image'] == q['n2']
            and equality['source'] == q['source'] and equality['runtime'] == q['runtime'], 'Native program equality identity differs')
    require(pin(ROOT/'selfhost/tools/performance/phase131/programs/native-equality.py') in equality['inputs'],
            'Program equality producer differs')
    screen = read(verify(equality['measuredScreen']))
    require(screen['complete'] and len(screen['rows']) == 405 and not screen['correctnessOnly']
            and all(r['correct'] and r['status'] == 0 for r in screen['rows']), 'Program execution screen incomplete')
    require(len(equality['cases']) == len({c['name'] for c in equality['cases']}) == 45
            and {r['name'] for r in screen['rows']} == {c['name'] for c in equality['cases']}, 'Program case inventory differs')
    builds = {b['name']: b['report'] for b in screen['builds']}
    require(len(builds) == len(screen['builds']) == 45, 'Program build inventory differs')
    require({r['role'] for r in screen['rows']} == {'candidate', 'baseline', 'upstream'}, 'Program timing roles differ')
    for case in equality['cases']:
        require(case['byteExact'] and filecmp.cmp(verify(case['nativeQbe']), verify(case['hostedQbe']), shallow=False),
                'Complete native/checked-API program QBE differs')
        verify(case['source']); verify(case['measuredBinary'])
        request = read(verify(case['receipt']))
        require(request['complete'] and request['byteExact'] and request['image'] == q['n2']
                and request['source'] == case['source'] and request['runtime'] == q['runtime']
                and request['product'] == case['nativeQbe'] and request['expectedQbe'] == case['hostedQbe']
                and request['exitCode'] == 0 and not request['changedInputs'] and request['stderr']['bytes'] == 0,
                'Native program request lineage differs')
        built = read(verify(builds[case['name']]))
        require(built['complete'] and built['binary'] == case['measuredBinary']
                and case['hostedQbe'] in built['inputs'] and q['runtime'] in built['inputs'], 'Measured binary/build differs')
        observations = [r for r in screen['rows'] if r['name'] == case['name']]
        require(len(observations) == 9 and {(r['role'], r['round']) for r in observations}
                == {(role, round) for role in ['candidate', 'baseline', 'upstream'] for round in range(3)},
                'Program role/round schedule differs')
        verify(request['stderr'])
        rows = [r for r in observations if r['role'] == 'candidate']
        require(len(rows) == 3 and all(r['binary'] == case['measuredBinary'] for r in rows), 'Measured candidate image differs')
        for r in rows:
            verify(r['stdout']); verify(r['stderr']); require(r['stderr']['bytes'] == 0, 'Program diagnostic differs')
    return equality, screen


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['qualification', 'timing-summary', 'timing-report', 'stage-summary', 'stage-report', 'program-equality']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not OUT.exists(), 'Fresh final capsule directory required')
    q = read(a.qualification)
    require(q.get('kind') == 'phase131-native-producer-qualification' and q['complete']
            and q['nativeQualified'] and q['byteExact'] and not q['acquisitionQbeUnchanged']
            and q['acquisitionRoute'] == 'qualified-native' and not q['hostedAcquisition']
            and not q['installed'] and not q['selected'], 'Completed separate native qualification required')
    require(q['finalImage'] == q['n3'] and set(q['qbe']) == {'q1', 'q2', 'q3'}, 'Expected final N1/N2/N3 chain')
    for name in ['source', 'api', 'runtime', 'n1', 'n2', 'n3', 'producer', 'admission', 'sourceBinding', 'checkedApi']:
        verify(q[name])
    first = verify(q['qbe']['q1'])
    left, right = [verify(q['qbe'][k]) for k in ['q2', 'q3']]
    require(not filecmp.cmp(first, left, shallow=False), 'Declared first-generation code change is absent')
    require(filecmp.cmp(left, right, shallow=False), 'Raw QBE reproduction differs')
    require(q['reproducedQbe'] == dict(left=q['qbe']['q2'], right=q['qbe']['q3']), 'Reproduction receipt differs')
    gates = q['semanticGates']
    require(len(gates) == 3 and [(g['image'], g['semanticPasses'], g['expectedRefusals']) for g in gates]
            == [(q['n2'], 16, 3), (q['n3'], 16, 3), (q['n3'], 45, 0)], 'Native gate inventory differs')
    for g in gates:
        report = read(verify(g['report']))
        require(report['complete'] and report['passed'], 'Qualified semantic gate no longer complete')
    admission = read(q['admission']['file']); source_manifest = read(q['sourceBinding']['file'])
    api = read(q['checkedApi']['file'])
    require(admission['complete'] and admission['sourceChecked'] and admission['source'] == q['source']
            and admission['api'] == q['api'] and admission['runtime'] == q['runtime']
            and admission['changeKind'] == 'declared-codegen-change'
            and admission['requiredReproduction'] == 'N0->N1->N2->N3;Q2=Q3', 'Final admission identity differs')
    require(source_manifest['source'] == q['source'] and api['complete'] and api['checked']
            and api['status'] == 0 and api['api'] == q['api'] and q['source'] in api['inputs'], 'Checked source binding differs')
    parent = read(verify(q['producerSelection']))
    require(parent['complete'] and parent['nativeQualified'] and q['producer'] in [parent['n1'], parent['n2']]
            and parent['runtime'] == q['runtime'], 'Qualified producer/runtime differs')
    for k in ['preferredCarrier', 'preferredCarrierReceipt', 'legacyCarrierReceipt', 'runtimeReport']:
        verify(parent[k])
    timing = timing_block(a.timing_summary, a.timing_report, q['producer'], q['n2'], parent['source'], q['source'])
    stage_timing = timing_block(a.stage_summary, a.stage_report, q['n1'], q['n2'], q['source'], q['source'])
    programs, program_screen = program_binding(a.program_equality, q)
    semantic = admission['semanticChecks']
    require(len(semantic) == 1, 'Expected one actual final semantic admission')
    read(verify(semantic[0]))
    bridge_pin = admission['exactSourceBridge']['report']
    bridge = read(verify(bridge_pin)); proof_names = bridge['exactDeclarations']
    require(bridge['complete'] and bridge['source'] == q['source'] and len(proof_names) == 11, 'Proof/source bridge differs')
    for proof in bridge['proofReceipts']: verify(proof)
    verify(pin(__file__))
    # The qualification already authenticates its full transitive inventory.
    # Packaging rechecks principal identities and exact copies, not all prior
    # raw history or compiler executions a second time.
    OUT.mkdir()
    source = Path(q['source']['file']).read_bytes(); compressed = compress(source)
    require(compressed == compress(source), 'Compression is not deterministic in this environment')
    archive = OUT / 'compiler-source01.bend.gz'
    with archive.open('xb') as f: f.write(compressed)
    restored = gzip.decompress(archive.read_bytes())
    require(restored == source and len(restored) == q['source']['bytes']
            and hashlib.sha256(restored).hexdigest() == q['source']['sha256'], 'Archived source round trip differs')
    copies = {
        'qualification': copied(a.qualification, 'native-qualification.json'),
        'admission': copied(q['admission']['file'], 'acquisition-admission.json'),
        'sourceManifest': copied(q['sourceBinding']['file'], 'source-manifest.json'),
        'checkedApi': copied(q['checkedApi']['file'], 'checked-api.json'),
        'semanticAdmission': copied(semantic[0]['file'], 'semantic-admission.json'),
        'sourceBridge': copied(bridge_pin['file'], 'source-bridge.json'),
        'timingSummary': copied(a.timing_summary, 'timing-summary.json'),
        'timingReport': copied(a.timing_report, 'timing-report.json'),
        'stageSummary': copied(a.stage_summary, 'stage-timing-summary.json'),
        'stageReport': copied(a.stage_report, 'stage-timing-report.json'),
        'programEquality': copied(a.program_equality, 'program-equality.json'),
        'programScreen': copied(programs['measuredScreen']['file'], 'program-runtime.json'),
        'runtimeReport': copied(parent['runtimeReport']['file'], 'runtime-report.json'),
    }
    source_receipt = save('source.json', dict(complete=True, checked=True, nativeQualified=True,
        source=q['source'], archive=pin(archive), restoredBytes=len(restored), restoredSha256=hashlib.sha256(restored).hexdigest(),
        decompressedByteExact=True, deterministicCompression=True, gzip=dict(level=9, mtime=0, filename=''),
        environment=dict(python=platform.python_version(), zlib=zlib.ZLIB_RUNTIME_VERSION),
        sourceManifest=q['sourceBinding'], checkedApi=q['checkedApi'], qualification=pin(a.qualification),
        scope='Deterministic source capsule only; native binaries, QBE, tools and other raw dependencies remain separate pinned artifacts.'))
    candidate = dict(kind='phase131-final-native-research-checkpoint', complete=True, nativeQualified=True,
        source=q['source'], archive=pin(archive), sourceArchiveReceipt=source_receipt,
        sourceManifest=q['sourceBinding'], api=q['api'], checkedApi=q['checkedApi'], runtime=q['runtime'],
        runtimeReport=parent['runtimeReport'], n1=q['n1'], n2=q['n2'], n3=q['n3'], finalImage=q['finalImage'],
        qualification=pin(a.qualification), qualificationArchive=copies['qualification'], admission=q['admission'],
        preferredCarrier=parent['preferredCarrier'], preferredCarrierReceipt=parent['preferredCarrierReceipt'],
        preferredStamp=parent['preferredStamp'], legacyCarrierReceipt=parent['legacyCarrierReceipt'],
        proofScope=dict(exactDeclarations=proof_names, proofReceipts=bridge['proofReceipts'],
            exactDeclarationCount=len(proof_names), scope=bridge['coverage']),
        requestReproduction=dict(products=q['qbe'], acquisitionQbeUnchanged=False, finalQbeByteExact=True,
            comparedImages=[q['n2'], q['n3']], comparedProducts=q['reproducedQbe'], elfFixedPointClaimed=False),
        compilerTiming=dict(parentComparison=dict(summary=pin(a.timing_summary), rawReport=pin(a.timing_report)),
            sameSourceStages=dict(summary=pin(a.stage_summary), rawReport=pin(a.stage_report)), measuredImage=q['n2'],
            scope='Two distinct historical three-request/three-round compiler timing blocks. N2 was measured; N3 timing is not inferred.'),
        generatedPrograms=dict(equality=pin(a.program_equality), measuredScreen=programs['measuredScreen'],
            producingNativeImage=q['n2'], independentNativeQbeMatches=45, totalRuntimeObservations=len(program_screen['rows']),
            candidateRuntimeObservations=sum(r['role'] == 'candidate' for r in program_screen['rows']),
            scope='All 45 native N2 wrapper products equal the checked-API products used for the candidate role (135 observations within the separate 405-observation program screen), with the identical cached runtime. No N3 speed transfer claim.'),
        entryPoints=dict(nativeImage=q['n3'], checkedApi=q['api'], sourceArchive=pin(archive), runtime=q['runtime'],
            requestTool=pin(ROOT/'selfhost/tools/performance/phase130/native-request.py'),
            machineBuildTool=pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),
            nativeRequestArgv=[q['n3']['file'],'--threads','1','--gpu','off','--','phase111','SOURCE_FILE',
                str(ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'),'cache',parent['preferredCarrier']['file'],parent['preferredStamp']],
            nativeOutput='Complete raw QBE on stdout; use the authenticated request tool to bind carrier/source/runtime and deadlines.'),
        installed=False, selected=False, productionSelectionChanged=False, finalCombinedCandidate=True,
        scope='Qualified final combined research compiler capsule, separate from FAST. N2/N3 raw QBE reproduces; focused 19 covers both, ordinary 45 covers N3. No installed selector change or universal compiler proof.')
    candidate_pin = save('candidate.json', candidate)
    for row in INPUTS.values(): verify(row)
    inventory = [pin(archive), source_receipt, candidate_pin, *copies.values()]
    for row in inventory: require(pin(row['file']) == row, 'Capsule output changed')
    receipt = save('receipt.json', dict(kind='phase131-final-source-capsule', complete=True, targetsRun=False,
        method=pin(__file__), inputs=list(INPUTS.values()), outputs=inventory, outputBytes=sum(x['bytes'] for x in inventory),
        decompressedByteExact=True, nativeQualified=True, installed=False, productionSelectionChanged=False,
        scope='Exact copies of completed receipts and deterministic source compression. Principal role/source/runtime/timing pins rechecked; full raw history is not archived or requalified here.'))
    print(json.dumps(dict(complete=True, candidate=candidate_pin, receipt=receipt, archive=pin(archive))))


if __name__ == '__main__': main()
