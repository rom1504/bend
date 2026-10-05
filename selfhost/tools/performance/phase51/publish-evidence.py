#!/usr/bin/env python3
"""Join completed Phase51 evidence; no compiler or target execution."""
import hashlib
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
RAW = ROOT / 'selfhost/build/phase51'
OUT = HERE / 'evidence'
API = 'c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061'
RUNTIME = '3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46'
inputs = []

def pin(file):
    file = Path(file).resolve()
    row = dict(file=str(file), bytes=file.stat().st_size, sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    inputs.append(row)
    return row

def read(file):
    pin(file)
    data = json.loads(Path(file).read_text())
    assert data['complete'] is True, file
    return data

assert not (OUT / 'selected-qualification.json').exists()
pin(__file__)
installed = read(RAW / 'installed-release01.json')
semantic = read(RAW / 'semantic-qualification01.json')
runtime = read(RAW / 'full-summary01.json')
replay = read(RAW / 'portable-smoke01/report.json')
publication = read(HERE / 'bundles/publication.json')
assert installed['api']['sha256'] == semantic['selected']['api']['sha256'] == API
assert installed['runtime']['sha256'] == semantic['selected']['runtime']['sha256'] == RUNTIME
assert installed['attempt']['sha256'] == semantic['selected']['attempt']['sha256']
assert installed['inputsUnchanged'] and installed['maintainedSuites'] == 8 and installed['cliSteps'] == 42
assert semantic['agreementComplete'] and semantic['inputsUnchanged']
assert (semantic['exactRows'], semantic['fixtureExecutionPasses'], semantic['notApplicable'], semantic['sharedRawCheckFailures']) == (81, 69, 8, 4)
assert runtime['pass'] and (runtime['points'], runtime['sourceCount'], runtime['samples']) == (45, 23, 669)
for report in [runtime, replay]:
    compiler = report['plan']['variants']['candidate']['compiler']
    assert compiler['api']['sha256'] == API and compiler['runtime']['sha256'] == RUNTIME
assert replay['pass'] and replay['measuredCases'] == 3
assert sum(len(c['samples']) for c in replay['cases']) == 27
assert publication['reopenedVerified'] and publication['points'] == 45
for row in publication['publications']:
    for key in ['manifest', 'archive']:
        expected = row[key]
        assert pin(expected.get('file', expected.get('path')))['sha256'] == expected['sha256']
for case in ['coverage-unicode-text-1601', 'coverage-map-churn-3201', 'coverage-record-aggregation-6401']:
    data = read(RAW / ('checked-' + case) / 'report.json')
    assert data['pass'] and data['boundaries'] == 11
dispatch = read(RAW / 'checked-dispatch-controls02/report.json')
assert dispatch['passed'] and len(dispatch['observations']) == 27
for name in ['emission-differences.json', 'accounting01.json', 'time-use02.json']:
    read(RAW / name)
assert pin(ROOT / 'selfhost/dist/typed-api.mjs')['sha256'] == API
assert pin(ROOT / 'selfhost/src/runtime.mjs')['sha256'] == RUNTIME
for relative in ['src/runtime/js/core.mjs', 'src/runtime.mjs', 'src/back/js/jpure.bend']:
    assert pin(ROOT / 'selfhost' / relative)['sha256'] == pin(RAW / 'checked-candidate01/snapshot' / relative)['sha256']
copies = {}
for name, original in [('installed-release.json', 'installed-release01.json'), ('semantic-qualification.json', 'semantic-qualification01.json'), ('runtime-summary.json', 'full-summary01.json'), ('accounting.json', 'accounting01.json'), ('time-use.json', 'time-use02.json')]:
    target = OUT / name
    assert not target.exists()
    shutil.copyfile(RAW / original, target)
    copies[name] = pin(target)
for row in list(inputs):
    assert hashlib.sha256(Path(row['file']).read_bytes()).hexdigest() == row['sha256']
result = dict(kind='phase51-selected-qualification', complete=True, installed=True,
              attempt=installed['attempt'], api=installed['api'], runtime=installed['runtime'],
              release=installed['release'], semanticOutcomes=dict(passes=69, notApplicable=8, sharedFailures=4),
              fullRuntime=dict(points=45, sources=23, samples=669, geometricMeans=runtime['geometricMeans']),
              maintainedSuites=8, cliSteps=42, portableReplaySamples=27, copies=copies, inputs=inputs,
              scope='Qualified checked B1 with fresh JS execution comparison; native environmental retry is explicit. No renewed full frontend, fixed point, compiler-throughput or universal parity claim.')
(OUT / 'selected-qualification.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(complete=True, selected=str(OUT / 'selected-qualification.json'))))
