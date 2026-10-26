"""Metadata only: experimental fast image and two native experiments."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def read(p):
    return json.loads(Path(p).read_text())


def pin(p):
    p = Path(p).resolve()
    h = hashlib.sha256()
    size = 0
    with p.open('rb') as f:
        while chunk := f.read(1024*1024):
            h.update(chunk)
            size += len(chunk)
    return dict(file=str(p), bytes=size, sha256=h.hexdigest())


ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--baseline-receipt', type=Path, required=True)
a = ap.parse_args()
out = ROOT/'selfhost/build/phase144/range-fast-native-plan01'
assert not out.exists()
final_plan_file = ROOT/'selfhost/build/phase144/final03-plan/plan.json'
fp = read(final_plan_file)
producer_receipt = ROOT/'selfhost/build/phase134/p144-final03-n2/report.json'
q3_receipt = ROOT/'selfhost/build/phase130/p144-final03-q3/report.json'
producer, q3 = read(producer_receipt), read(q3_receipt)
assert producer['complete'] and q3['complete'] and q3['byteExact']
assert producer['binary'] == q3['image'] and producer['source'] == q3['source']
assert all(producer['retainedIR'][k] == q3['product'][k] for k in ['bytes', 'sha256'])
assert producer['runtime'] == fp['runtime']
sm_file = ROOT/'selfhost/build/phase144/range-skip-final03-source01/manifest.json'
api_file = ROOT/'selfhost/build/phase111/p144-range-skip-final03-api01/report.json'
controls_file = ROOT/'selfhost/build/phase144/range-skip-final03-controls01/report.json'
sm, api, controls = read(sm_file), read(api_file), read(controls_file)
assert sm['complete'] and api['complete'] and api['checked'] and controls['complete']
assert sm['source'] in api['inputs'] and api['api'] in controls['inputs']
assert sum(len(g['rows']) for g in controls['groups']) == 171
assert sm['parent'] == producer['source']
assert sm['overrides'] == ['p114s_ranges'] and not sm['added']
assert sm['allOtherDeclarationsIncludingProofsAndFinalVerifiersNormalizedExact']
fixed_receipt = ROOT/'selfhost/build/phase130/p142-indexed-emit01/report.json'
fixed = read(fixed_receipt)
assert fixed['complete']
assert fixed['source']['sha256'] == '15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1'
pipe = ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py'
request = ROOT/'selfhost/tools/performance/phase130/native-request.py'
guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
analysis = HERE/'range-fast-native-result-v01.py'
inputs = [pin(__file__), pin(final_plan_file), pin(producer_receipt), pin(q3_receipt),
    pin(sm_file), pin(api_file), pin(controls_file), pin(fixed_receipt),
    sm['source'], producer['source'], producer['binary'], producer['assembly'], producer['object'],
    producer['retainedIR'], q3['product'], fp['runtime'], fp['runtimeBuild'], fp['carrierReceipt'],
    fp['base'], fp['carrier'], *fp['machineTools'].values(), fixed['source'], fixed['product'],
    api['api'], *api['inputs'], *controls['inputs'], pin(pipe), pin(request), pin(guard), pin(analysis)]
inputs = list({x['file']: x for x in inputs}.values())
for x in inputs:
    assert pin(x['file']) == x
acquire = ROOT/'selfhost/build/phase134/p144-range-fast-n1-01'
latency = ROOT/'selfhost/build/phase130/p144-range-fast-fixed142-01'
product = ROOT/'selfhost/build/phase134/p144-range-fast-final03-product01'
analysis_out = ROOT/'selfhost/build/phase144/range-fast-native-result01.json'
for p in [acquire, latency, product, analysis_out]:
    assert not p.exists()
out.mkdir()
jobs = []


def job(name, cmd, seconds, report):
    jobs.append(dict(name=name, seconds=seconds+30, report=str(report), command=[sys.executable,
        '-B', str(guard), '--out', str(out/(name+'-guard')), '--seconds', str(seconds),
        '--cpu', '3', '--rss-mib', '3072', '--available-mib', '16384', '--file-mib', '256',
        '--', *map(str, cmd)]))


# No retained textual IR for the two pipe builds: their digest, assembly and
# machine products remain. This is experimental acquisition, not qualification.
job('acquire-fast-image', [sys.executable, '-B', pipe, '--image', producer['binary']['file'],
    '--source', sm['source']['file'], '--carrier-receipt', fp['carrierReceipt']['file'],
    '--runtime', fp['runtime']['file'], '--out', acquire, '--seconds', '600'], 660, acquire/'report.json')
job('fast-fixed142-latency', [sys.executable, '-B', request, '--image', acquire/'program',
    '--source', fixed['source']['file'], '--carrier-receipt', fp['carrierReceipt']['file'],
    '--out', latency, '--seconds', '600'], 630, latency/'report.json')
job('fast-same-final03-machine', [sys.executable, '-B', pipe, '--image', acquire/'program',
    '--source', producer['source']['file'], '--carrier-receipt', fp['carrierReceipt']['file'],
    '--runtime', fp['runtime']['file'], '--out', product, '--seconds', '600'], 660, product/'report.json')
plan = dict(kind='phase144-experimental-fast-native-plan', complete=True, targetsRun=False,
    selected=False, nativeQualified=False, inputs=inputs,
    producer=producer['binary'], producerReceipt=pin(producer_receipt), producerQ3=pin(q3_receipt),
    producerFull45Gate=str(ROOT/'selfhost/build/phase111/p144-final03-n2-full45/report.json'),
    policySource=sm['source'], checkedApi=pin(api_file), finiteControls=pin(controls_file),
    sourceManifest=pin(sm_file), runtime=fp['runtime'], runtimeBuild=fp['runtimeBuild'],
    carrierReceipt=fp['carrierReceipt'], fixedSource=fixed['source'], fixedHistoricalProduct=fixed['product'], fullSource=producer['source'],
    frozenFullProduct=dict(qbe=producer['retainedIR'], assembly=producer['assembly'], object=producer['object']),
    paths=dict(acquisition=str(acquire/'report.json'), latency=str(latency/'report.json'),
        fullProduct=str(product/'report.json'), baselineLatency=str(a.baseline_receipt.resolve()),
        result=str(analysis_out)), jobs=jobs,
    clockPolicy='Compare nativeSeconds of fresh fixed Phase142 requests only. Keep acquisition wall/pipe time and final03 emit+QBE time separate. One pair is exploratory; no cross-source timing ratio.',
    qualityPolicy='Candidate QBE may intentionally differ; no false byteExact requirement. Record exact full-source assembly/object comparison to final03Q2. A machine mismatch is negative evidence, not automatically a semantic failure or accepted regression.',
    runtimePolicy='Both native images link the exact serial-RFC runtime. Phase130 request runtime field describes future-build context only; actual linked runtime is authenticated by acquisition receipts.',
    diskPolicy='Pipe builds omit duplicate full textual IR (~230MB saved). Keep hashes, assembly and objects. Fixed-input latency retains its raw QBE. No automatic deletion.',
    gate='Root waits for producer full45 success, runs sequential guarded jobs, then static analysis. No production default/installed compiler change, no fast-image self-reproduction or full qualification claim.')
mf = out/'plan.json'
mf.write_text(json.dumps(plan, indent=2)+'\n')
jobs.append(dict(name='static-result', seconds=45, command=[sys.executable, '-B', str(analysis), '--plan', str(mf)]))
(out/'jobs.json').write_text(json.dumps(dict(complete=True, targetsRun=False, selected=False,
    inputs=[pin(mf)], jobs=jobs), indent=2)+'\n')
print(json.dumps(dict(plan=pin(mf), jobs=pin(out/'jobs.json'), source=sm['source'])))
