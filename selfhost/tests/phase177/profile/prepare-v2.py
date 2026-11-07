#!/usr/bin/env python3
"""Metadata-only fresh stage plan after the preserved Phase177 marker failure.

Reuse all eleven observed unique boundaries. Remove only the unobserved private
ordinary wrapper, combining its two adjacent intervals. Never relabel or modify
the old spec, ELF, capture, observation, or sampler output.
"""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
TOOLS = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(TOOLS))
from run import pin, verify
from stages_v1 import validate_spec

OLD = ROOT / 'selfhost/build/phase177/profile-prep01'
FAILED = ROOT / 'selfhost/build/phase177/profile-medium01/stages.json'
RAW = ROOT / 'selfhost/build/phase177/profile-medium01/000-sample-medium-front-base-staged/samples.txt.stages-v1.json'
ANALYSIS = RAW.with_name('analysis.json')
SAMPLER = ROOT / 'selfhost/build/phase161/profile-build03/sampler-base/report.json'
REMOVED = 'p175fp_ordinary'


def read(path):
    return json.loads(Path(path).read_text())


def need(value, message):
    if not value:
        raise ValueError(message)


def save(path, data):
    with Path(path).open('x') as stream:
        json.dump(data, stream, indent=2)
        stream.write('\n')


def prepare(out, products):
    need(not out.exists() and not products.exists(), 'Fresh prep/products required')
    old = read(OLD / 'ready.json')
    for key in ('method', 'image', 'source', 'imageBuild', 'assets', 'owners', 'spec', 'plan'):
        verify(old[key])
    spec = copy.deepcopy(read(verify(old['spec'])))
    raw, failed, analysis = read(RAW), read(FAILED), read(ANALYSIS)
    need(failed['sidecar']['identity'] == pin(RAW), 'Failed observation/raw sidecar identity differs')
    need(not failed['complete'] and not raw['complete'] and raw['badOrderOrDuplicate']
         and not raw['clockError'] and raw['sequentialOnly'], 'Expected preserved marker failure')
    need(raw['specSha256'] == old['spec']['sha256'], 'Failed raw capture/spec mismatch')
    need([r['label'] for r in raw['markers']] == spec['requiredOrder'], 'Failed marker inventory differs')
    need([r['label'] for r in raw['markers'] if r['entries'] == 0] == [REMOVED],
         'Unexpected missing-marker set')
    need(all(r['entries'] == 1 and len(r['observations']) == 1
             for r in raw['markers'] if r['label'] != REMOVED), 'Other markers not unique')
    kept = [r for r in raw['markers'] if r['label'] != REMOVED]
    for left, right in zip(kept, kept[1:]):
        need(all(left['observations'][0][key] <= right['observations'][0][key]
                 for key in ('wallNs', 'cpuNs', 'threadNs', 'sampleOrdinal')),
             'Kept marker observations reordered')
    need(not analysis['usable'], 'The rejected 2ms capture must stay rejected')
    out.mkdir(parents=True)
    (out / 'owners.json').write_bytes(verify(old['owners']).read_bytes())
    spec['ownerMap'] = pin(out / 'owners.json')
    spec['markers'] = [r for r in spec['markers'] if r['label'] != REMOVED]
    spec['requiredOrder'] = [name for name in spec['requiredOrder'] if name != REMOVED]
    intervals = []
    for interval in spec['intervals']:
        if interval['begin'] == REMOVED:
            continue
        if interval['end'] == REMOVED:
            interval = dict(label='erasure, request wrapping and clocks',
                            begin=interval['begin'], end='p175fn_observe')
        intervals.append(interval)
    spec['intervals'] = intervals
    spec['scope'] = ('Fresh capture only: eleven exact direct dispatcher markers previously observed once. '
                     'p175fp_ordinary is called by a private p112w/p113d path and was not dispatched. '
                     'Its adjacent intervals are combined; all other boundaries remain. '
                     'Prior failed order/quality capture remains failed; 8000us requested for the next capture.')
    validate_spec(spec, read(out / 'owners.json'))
    save(out / 'spec.json', spec)
    save(out / 'revision.json', dict(complete=True, targetsRun=False, method=pin(__file__),
        previousReady=pin(OLD / 'ready.json'), previousSpec=old['spec'], failedObservation=pin(FAILED),
        rawMarkers=pin(RAW), rejectedAnalysis=pin(ANALYSIS), removedRequiredMarker=REMOVED,
        keptRequiredMarkers=spec['requiredOrder'], requestedPeriodUs=8000,
        reason='Only ordinary has zero dispatch entries; the other eleven are unique and ordered. 2ms also failed timer delivery: 4239 delivered, 4239 overruns. No failed sample is rehabilitated.'))
    subprocess.run([sys.executable, '-B', str(TOOLS / 'stages-build-v1.py'),
        '--spec', str(out / 'spec.json'), '--runtime-plan', str(OLD / 'base-runtime/plan.json'),
        '--sampler-build', str(SAMPLER), '--out', str(out / 'stage-runtime')],
        check=True, timeout=60)
    stage_plan = read(out / 'stage-runtime/plan.json')
    stage_plan['inputs'] += [pin(__file__), pin(out / 'revision.json'), pin(OLD / 'ready.json'),
                             pin(FAILED), pin(RAW), pin(ANALYSIS), pin(out / 'stage-runtime/plan.json')]
    save(out / 'stage-runtime-plan.json', stage_plan)
    ready = {key: old[key] for key in ('image', 'source', 'imageBuild', 'assets', 'ownershipLimit')}
    ready.update(complete=True, targetsRun=False, method=pin(__file__), owners=pin(out / 'owners.json'),
                 spec=pin(out / 'spec.json'), plan=pin(out / 'stage-runtime-plan.json'),
                 revision=pin(out / 'revision.json'))
    save(out / 'ready.json', ready)
    path = ROOT / 'experiments/phase171/tools/profile-v2.py'
    loader = importlib.util.spec_from_file_location('phase171_profile_paths', path)
    module = importlib.util.module_from_spec(loader)
    loader.loader.exec_module(module)
    module.relocate(out, products, out / 'build-plan.json')


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--products', type=Path, required=True)
    a = p.parse_args()
    prepare(a.out.resolve(), a.products.resolve())
