"""Archive a completed FAST qualification and its separate timing block; data only."""
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
OUT = ROOT / 'implementation/phase131/fast'
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


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['qualification', 'timing-summary', 'timing-report']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not OUT.exists(), 'Fresh FAST capsule directory required')
    q = read(a.qualification)
    require(q.get('kind') == 'phase131-native-producer-qualification' and q['complete']
            and q['nativeQualified'] and q['byteExact'] and q['acquisitionQbeUnchanged']
            and q['acquisitionRoute'] == 'qualified-native' and not q['hostedAcquisition']
            and not q['installed'] and not q['selected'], 'Completed separate native qualification required')
    require(q['finalImage'] == q['n2'] and set(q['qbe']) == {'q1', 'q2'}, 'Expected FAST N1/N2 chain')
    for name in ['source', 'api', 'runtime', 'n1', 'n2', 'producer', 'admission', 'sourceBinding', 'checkedApi']:
        verify(q[name])
    left, right = [verify(q['qbe'][k]) for k in ['q1', 'q2']]
    require(filecmp.cmp(left, right, shallow=False), 'Raw QBE reproduction differs')
    require(q['reproducedQbe'] == dict(left=q['qbe']['q1'], right=q['qbe']['q2']), 'Reproduction receipt differs')
    gates = q['semanticGates']
    require(len(gates) == 3 and [(g['image'], g['semanticPasses'], g['expectedRefusals']) for g in gates]
            == [(q['n1'], 16, 3), (q['n2'], 16, 3), (q['n2'], 45, 0)], 'Native gate inventory differs')
    for g in gates:
        report = read(verify(g['report']))
        require(report['complete'] and report['passed'], 'Qualified semantic gate no longer complete')
    admission = read(q['admission']['file']); source_manifest = read(q['sourceBinding']['file'])
    api = read(q['checkedApi']['file'])
    require(admission['complete'] and admission['sourceChecked'] and admission['source'] == q['source']
            and admission['api'] == q['api'] and admission['runtime'] == q['runtime']
            and admission['changeKind'] == 'byte-preserving-algorithm-candidate', 'FAST admission identity differs')
    require(source_manifest['source'] == q['source'] and api['complete'] and api['checked']
            and api['status'] == 0 and api['api'] == q['api'] and q['source'] in api['inputs'], 'Checked source binding differs')
    parent = read(verify(q['producerSelection']))
    require(parent['complete'] and parent['nativeQualified'] and q['producer'] in [parent['n1'], parent['n2']]
            and parent['runtime'] == q['runtime'], 'Qualified producer/runtime differs')
    for k in ['preferredCarrier', 'preferredCarrierReceipt', 'legacyCarrierReceipt', 'runtimeReport']:
        verify(parent[k])
    timing = read(a.timing_summary); raw_timing = read(a.timing_report)
    require(timing['complete'] and raw_timing['complete'] and raw_timing['passed']
            and raw_timing['inputsUnchanged'] and not raw_timing['checkOnly']
            and pin(a.timing_report) in timing['inputs'] and timing['roles'] == raw_timing['roles'],
            'Timing summary/raw identity differs')
    require(timing['roles']['phase112']['binary'] == q['n1'] and timing['roles']['phase112']['source'] == q['source']
            and timing['roles']['phase111']['binary'] == q['producer'], 'Timing is not the qualified FAST N1')
    require(timing['observations'] == len(raw_timing['rows']) == 27 and raw_timing['rounds'] == 3
            and raw_timing['modes'] == ['cache'] and len(timing['cases']) == len(raw_timing['cases']) == 3
            and all(r['passed'] and r['outputExact'] and r['stderrExact'] for r in raw_timing['rows']),
            'Timing matrix incomplete')
    for row in timing['inputs']: verify(row)
    verify(raw_timing['manifest'])
    semantic = admission['semanticChecks']
    require(len(semantic) == 1, 'Expected one actual FAST semantic admission')
    read(verify(semantic[0]))
    bridge = read(verify(admission['exactSourceBridge']))
    proof_names = bridge['exactDeclarations']
    require(bridge['complete'] and bridge['candidate'] == q['source'], 'Proof/source bridge differs')
    for proof in admission['independentHelperLaws']: verify(proof['report'])
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
        'sourceBridge': copied(admission['exactSourceBridge']['file'], 'source-bridge.json'),
        'timingSummary': copied(a.timing_summary, 'timing-summary.json'),
        'timingReport': copied(a.timing_report, 'timing-report.json'),
    }
    source_receipt = save('source.json', dict(complete=True, checked=True, nativeQualified=True,
        source=q['source'], archive=pin(archive), restoredBytes=len(restored), restoredSha256=hashlib.sha256(restored).hexdigest(),
        decompressedByteExact=True, deterministicCompression=True, gzip=dict(level=9, mtime=0, filename=''),
        environment=dict(python=platform.python_version(), zlib=zlib.ZLIB_RUNTIME_VERSION),
        sourceManifest=q['sourceBinding'], checkedApi=q['checkedApi'], qualification=pin(a.qualification),
        scope='Deterministic source capsule only; native binaries, QBE, tools and other raw dependencies remain separate pinned artifacts.'))
    candidate = dict(kind='phase131-fast-native-research-checkpoint', complete=True, nativeQualified=True,
        source=q['source'], archive=pin(archive), sourceArchiveReceipt=source_receipt,
        sourceManifest=q['sourceBinding'], api=q['api'], checkedApi=q['checkedApi'], runtime=q['runtime'],
        runtimeReport=parent['runtimeReport'], n1=q['n1'], n2=q['n2'], finalImage=q['finalImage'],
        qualification=pin(a.qualification), qualificationArchive=copies['qualification'], admission=q['admission'],
        preferredCarrier=parent['preferredCarrier'], preferredCarrierReceipt=parent['preferredCarrierReceipt'],
        preferredStamp=parent['preferredStamp'], legacyCarrierReceipt=parent['legacyCarrierReceipt'],
        proofScope=dict(exactDeclarations=proof_names, independentHelperLaws=admission['independentHelperLaws'],
            exactDeclarationCount=len(proof_names), lawCount=sum(len(p['laws']) for p in admission['independentHelperLaws']),
            scope='Exactly the listed actual safe declarations and law names; generic traversal, merge and callers are not proved.'),
        timing=dict(summary=pin(a.timing_summary), rawReport=pin(a.timing_report), measuredImage=q['n1'],
            qualificationAtMeasurement=timing['roles']['phase112']['nativeQualified'], nowSeparatelyQualified=True,
            scope='Historical three-request/three-round compiler timing block. No FAST N2 timing or generated-program speed claim.'),
        installed=False, selected=False, productionSelectionChanged=False, finalCombinedCandidate=False,
        scope='Separately qualified FAST fallback checkpoint. Distinct from the later combined code-generation candidate; no installed selector changes.')
    candidate_pin = save('candidate.json', candidate)
    for row in INPUTS.values(): verify(row)
    inventory = [pin(archive), source_receipt, candidate_pin, *copies.values()]
    for row in inventory: require(pin(row['file']) == row, 'Capsule output changed')
    receipt = save('receipt.json', dict(kind='phase131-fast-source-capsule', complete=True, targetsRun=False,
        method=pin(__file__), inputs=list(INPUTS.values()), outputs=inventory, outputBytes=sum(x['bytes'] for x in inventory),
        decompressedByteExact=True, nativeQualified=True, installed=False, productionSelectionChanged=False,
        scope='Exact copies of completed receipts and deterministic source compression. Principal role/source/runtime/timing pins rechecked; full raw history is not archived or requalified here.'))
    print(json.dumps(dict(complete=True, candidate=candidate_pin, receipt=receipt, archive=pin(archive))))


if __name__ == '__main__': main()
