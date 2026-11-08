#!/usr/bin/env python3
"""Summarize completed Phase179 measurements; no compilation or new timing."""
import hashlib
import json
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase179'


def read(name):
    file = BUILD / name / 'report.json'
    result = json.loads(file.read_text())
    if not result.get('complete') or result.get('changedInputs'):
        raise ValueError('Incomplete or changed-input measurement: ' + name)
    receipts.append(dict(path=str(file.relative_to(ROOT)),
                         sha256=hashlib.sha256(file.read_bytes()).hexdigest()))
    return result


receipts = []
bendc = [read('bendc-build01'), read('bendc-build02')]
ours = [read('ours-build01'), read('ours-build02')]
emit = read('ours-emission01')
machine = read('ours-machine01')
bc_check = read('bendc-rebuilt-check01')
our_check = read('ours-rebuilt-check01')
assets = read('bendc-assets01')
assert all(x['seedExact'] for x in bendc) and bc_check['seedExact']
assert all(x['comparedToReference'] for x in ours + [machine, our_check])
assert emit['byteExact'] and our_check['outputExact']
assert ours[0]['irDigest'] == ours[1]['irDigest']
assert all(ours[0][key]['sha256'] == ours[1][key]['sha256']
           for key in ['assembly', 'object'])
bc_total = [x['totalSeconds'] for x in bendc]
our_total = [x['wallSeconds'] for x in ours]
bc_emit = [x['sourceThroughCaptureSeconds'] for x in bendc]
bc_machine = [x['machine']['machineSeconds'] for x in bendc]
result = dict(kind='phase179-complete-checked-self-build-comparison', complete=True,
    scope='Same operation, different compiler sources/IR languages. CPU3, one worker, '
          'GPU off, reusable runtime objects; filesystem caches not flushed. '
          'Ours reuses prepared Base; bendc checks Base live. Two full builds each, '
          'one separate serial diagnostic; no equal-work or universal throughput claim.',
    order=['bendc-build01', 'ours-build01', 'ours-build02', 'bendc-build02'],
    fullBuild=dict(bendcSeconds=bc_total, oursSeconds=our_total,
                   bendcMedianSeconds=median(bc_total), oursMedianSeconds=median(our_total),
                   oursOverBendc=median(our_total)/median(bc_total)),
    bendc=dict(sourceThroughCaptureSeconds=bc_emit, sourceThroughCaptureMedian=median(bc_emit),
               clangAndLinkSeconds=bc_machine, clangAndLinkMedian=median(bc_machine),
               captureCopySeconds=[x['machine']['captureSeconds'] for x in bendc],
               runtimeAcquisitionSeconds=assets['process']['seconds'],
               ir=bendc[0]['emittedC'], binary=bendc[0]['binary']),
    ours=dict(overlappedCompilerAndQbeSeconds=[x['emitAndQbeSeconds'] for x in ours],
              serialEmissionSeconds=emit['nativeSeconds'],
              serialEmissionCpuSeconds=emit['process']['userSeconds'] + emit['process']['systemSeconds'],
              serialMachineWallSeconds=machine['wallSeconds'],
              serialMachineStages={x['label']:x['seconds'] for x in machine['jobs']},
              ir=emit['product'], binary=ours[0]['binary']),
    compilerToDifferentIRRatio=emit['nativeSeconds']/median(bc_emit),
    validation=dict(bendcSeedExact=True, oursFullQbeExact=True,
                     oursRepeatedAssemblyObjectExact=True,
                     rebuiltBendcSeedExact=True, rebuiltOursQbeAndStdoutExact=True,
                     rebuiltBendcEmissionSeconds=bc_check['totalSeconds'],
                     scope='Bounded executable checks, not a new broad qualification or installed promotion.'),
    receipts=receipts)
out = ROOT / 'implementation/phase179/metrics.json'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['fullBuild', 'compilerToDifferentIRRatio']}))
