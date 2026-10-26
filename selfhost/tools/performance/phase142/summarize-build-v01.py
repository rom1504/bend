"""Join authenticated native comparison with one identical-product readiness check."""
import argparse
import hashlib
import json
from pathlib import Path

def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())

p = argparse.ArgumentParser(description=__doc__)
for name in ['comparison', 'smoke', 'historical', 'out']:
    p.add_argument('--'+name, type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
comparison, smoke, historical = [json.loads(p.read_text()) for p in [a.comparison, a.smoke, a.historical]]
assert all(x['complete'] for x in [comparison, smoke, historical])
assert comparison['machine']['binary'] in smoke['inputs']
assert len(smoke['rows']) == 3
for artifact in smoke['inputs']:
    assert pin(artifact['file']) == artifact
for row in smoke['rows']:
    assert pin(row['request']['file']) == row['request']
    request = json.loads(Path(row['request']['file']).read_text())
    assert request['complete'] and request['byteExact']
warm = next(j for j in comparison['jobs'] if j['name'] == comparison['machine']['job'])
assert warm['productIdentity']['sha256'] == historical['product']['sha256']
rows = {}
for side in ['baseline', 'candidate']:
    timings = warm['timings']
    shared = comparison[side]['sharedNativeSeconds'] + comparison[side]['hostOrchestrationResidualSeconds']
    subtotal = timings['requestMaterializationAndSharedMachineBuildSeconds'][side]
    rows[side] = dict(warmNativeSeconds=timings['totalSeconds'][side],
                     sourceIoSeconds=timings['sourceIOSeconds'][side],
                     transportSeconds=timings['hostMaterializationSeconds'][side],
                     sharedMachineBuildSeconds=comparison['machine']['seconds'],
                     availableExecutableSubtotalSeconds=subtotal,
                     allSharedOverheadSeconds=shared, inclusiveWarmSeconds=subtotal+shared,
                     readinessSmokeSeconds=smoke['seconds'],
                     readyWithSharedSmokeSeconds=subtotal+shared+smoke['seconds'])
fresh = historical['freshExecutableSubtotalSeconds']
result = dict(kind='phase142-incremental-build-join', complete=True,
              inputs=[pin(__file__), pin(a.comparison), pin(a.smoke), pin(a.historical)],
              rows=rows, ratio=rows['candidate']['inclusiveWarmSeconds']/rows['baseline']['inclusiveWarmSeconds'],
              historicalFreshBaselineSeconds=fresh,
              historicalFreshToCandidateWarmRatio=fresh/rows['candidate']['inclusiveWarmSeconds'],
              scope='Single matched sessions; all shared native/host residual conservatively charged to the edited job. One measured identical-product machine build and readiness smoke reused equally. Historical fresh B denominator explicitly old, not remeasured. Acquisition, cold seeding, guards, qualification and agent cost separate. No confidence interval or universal10x claim.')
a.out.write_text(json.dumps(result, indent=2)+'\n')
