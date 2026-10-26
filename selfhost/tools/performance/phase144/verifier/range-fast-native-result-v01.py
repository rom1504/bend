"""Read native experiment receipts; no builds, requests or target execution."""
import argparse
import filecmp
import hashlib
import json
from pathlib import Path


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
ap.add_argument('--plan', type=Path, required=True)
a = ap.parse_args()
p = read(a.plan)
assert p['complete'] and p['kind'] == 'phase144-experimental-fast-native-plan'
out = Path(p['paths']['result'])
assert not out.exists()
inputs = [pin(__file__), pin(a.plan), *p['inputs']]
receipts = {k: read(p['paths'][k]) for k in ['acquisition', 'latency', 'fullProduct', 'baselineLatency']}
for k, r in receipts.items():
    assert r['complete'], k
    inputs.append(pin(p['paths'][k]))
full45 = read(p['producerFull45Gate'])
assert full45['complete']
inputs.append(pin(p['producerFull45Gate']))
acq, fast, product, baseline = [receipts[k] for k in ['acquisition', 'latency', 'fullProduct', 'baselineLatency']]
assert acq['source'] == p['policySource'] and acq['image'] == p['producer']
assert acq['runtime'] == p['runtime'] and product['runtime'] == p['runtime']
assert baseline['image'] == p['producer'] and fast['image'] == product['image'] == acq['binary']
assert fast['source'] == baseline['source'] == p['fixedSource']
assert fast['base'] == baseline['base'] and fast['carrier'] == baseline['carrier'] and fast['stamp'] == baseline['stamp']
assert product['source'] == p['fullSource']
for r in [fast, baseline]:
    assert r['exitCode'] == 0 and r['stderr']['bytes'] == 0 and r['inheritedAffinity'] == [3]
for r in [acq, product]:
    assert r['compilerExitCode'] == r['qbeExitCode'] == 0
    assert r['compilerStderr']['bytes'] == r['qbeStderr']['bytes'] == 0
    assert r['inheritedAffinity'] == [3] and not r['retainIR']
    inputs.extend([r['binary'], r['object'], r['assembly']])
inputs.extend([fast['product'], baseline['product']])
for x in inputs:
    assert pin(x['file']) == x


def exact(a, b):
    return a['bytes'] == b['bytes'] and a['sha256'] == b['sha256'] and filecmp.cmp(a['file'], b['file'], shallow=False)


fixed_ratio = fast['nativeSeconds']/baseline['nativeSeconds']
report = dict(kind='phase144-fast-native-policy-result', complete=True, targetsRun=False,
    selected=False, nativeQualified=False, inputs=list({x['file']: x for x in inputs}.values()),
    acquisition=dict(seconds=acq['wallSeconds'], emitAndQbeSeconds=acq['emitAndQbeSeconds'], binary=acq['binary']),
    fixedInput=dict(source=p['fixedSource'], baselineImage=baseline['image'], fastImage=fast['image'],
        baselineSeconds=baseline['nativeSeconds'], fastSeconds=fast['nativeSeconds'], ratio=fixed_ratio,
        baselineCpuSeconds=baseline['cpuSeconds'], fastCpuSeconds=fast['cpuSeconds'],
        baselinePeakRssKiB=baseline['peakRssKiB'], fastPeakRssKiB=fast['peakRssKiB'],
        qbeExact=exact(baseline['product'], fast['product']),
        baselineMatchesHistoricalQbe=exact(baseline['product'], p['fixedHistoricalProduct']),
        repetitions=1, scope='Same frozen input/Base/carrier/CPU3 and actual linked serial runtime. One fresh process per variant; exploratory latency only.'),
    fullSourceQuality=dict(source=p['fullSource'], baseline=p['frozenFullProduct'],
        candidate=dict(irDigest=product['irDigest'], assembly=product['assembly'], object=product['object']),
        qbeDigestExact=all(product['irDigest'][k] == p['frozenFullProduct']['qbe'][k] for k in ['bytes', 'sha256']),
        assemblyExact=exact(p['frozenFullProduct']['assembly'], product['assembly']),
        objectExact=exact(p['frozenFullProduct']['object'], product['object']),
        experimentWallSeconds=product['wallSeconds'], emitAndQbeSeconds=product['emitAndQbeSeconds'],
        scope='Machine products for the same final03 source, baselineQ2 vs experimental fast producer. No automatic semantic-equivalence claim if machine bytes differ.'),
    qualification='Source checked+171 finite controls; candidate acquisition by qualified producer. This experiment is not fast-image N1/N2 qualification or a default change.')
out.write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(report=pin(out), fixedInputRatio=fixed_ratio,
    assemblyExact=report['fullSourceQuality']['assemblyExact'], objectExact=report['fullSourceQuality']['objectExact'])))
