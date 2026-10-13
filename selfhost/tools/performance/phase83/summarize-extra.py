#!/usr/bin/env python3
"""Summarize frontend warmth, rejected products and all execution receipts."""
import collections
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT/'selfhost/build/phase83'
OUT = ROOT/'implementation/phase83'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


frontend = {}
for path in sorted((RAW/'frontend01/runs').glob('frontend-*/report.json')):
    report = json.loads(path.read_text())
    assert report['pass'] and report['complete'] and report['inputsUnchanged']
    assert len(report['iterations']) == 3
    frontend[report['job']['name']] = dict(report=pin(path), iterations=report['iterations'])
assert len(frontend) == 8
(OUT/'frontend.json').write_text(json.dumps(dict(
    scope='Instrumented ordinary check/report calls. Three calls per process, four definition counts. No persistent inspector; no claim of asymptotic complexity or pure JIT attribution. TS checks Base each call, Bend uses explicitly prepared Base. Not native compilation clocks.',
    cases=frontend), indent=2)+'\n')

rejected = {}
for path in sorted((RAW/'regions01/runs').glob('clean-*/report.json')):
    report = json.loads(path.read_text())
    assert report['pass'] and report['exactC']
    diagnostic = report['diagnostic']
    plan, = diagnostic['plans']
    ready = set(plan['ready'])
    categories = collections.defaultdict(lambda: dict(constructions=0, inclusiveMs=0, bodyUnits=0))
    names = collections.defaultdict(lambda: dict(constructions=0, inclusiveMs=0, bodyUnits=0))
    for worker in diagnostic['workers']:
        key = 'finally-ready' if worker['name'] in ready else 'finally-unready'
        for row in [categories[key], names[worker['name']]]:
            row['constructions'] += 1
            row['inclusiveMs'] += worker['ms']
            row['bodyUnits'] += worker['bodyUnits']
    rejected[report['job']['case']] = dict(report=pin(path), requestMs=report['timings']['requestMs'],
        categories=dict(categories), names=dict(names), finalWorkerCount=len(plan['workers']),
        readyCount=len(ready), finalUnreadyBodyUnits=sum(w['bodyUnits'] for w in plan['workers'] if not w['accepted']))
assert len(rejected) == 4
(OUT/'candidate-fate.json').write_text(json.dumps(dict(
    scope='Observation derivative. Times include necessary analyses and instrumentation, so unready construction cost is an upper bound, not a demonstrated saving. Final ordinary/product readiness; source audit proves later observer routing cannot re-admit these names. UTF-16 body units are not allocation bytes.',
    cases=rejected), indent=2)+'\n')

guards = []
for directory in ['survey01', 'regions01', 'frontend01']:
    for path in (RAW/directory/'runs').glob('*-guard/process.json'):
        row = json.loads(path.read_text())
        assert row['complete'] and row['returncode'] == 0
        guards.append((path, row))
assert len(guards) == 82
resource = dict(complete=True, guardedJobs=len(guards), guardedWallSeconds=sum(g['wallSeconds'] for p,g in guards),
    peakTreeRssBytes=max(g['peakTreeRssBytes'] for p,g in guards),
    minimumAvailableBytes=min(g['minimumAvailableBytes'] for p,g in guards),
    firstTargetStart=min(g['started'] for p,g in guards), lastTargetFinish=max(g['finished'] for p,g in guards),
    cleanRequests=48, cpuProfiles=16, heapProfiles=3, regionRequests=4, preparations=3,
    exactCRequests=71, frontendProcesses=8, acceptedFrontendRequests=24,
    compilerBuilds=0, productionChanged=False, agents=3,
    scope='Guarded target occupancy only; excludes source analysis, browsing, document writing and offline profile summarization. No token or quota-use claim.',
    receipts=[pin(p) for p,g in guards], method=pin(Path(__file__)))
(OUT/'resources.json').write_text(json.dumps(resource, indent=2)+'\n')
print(json.dumps({key: value for key,value in resource.items() if key not in ['receipts','method']}))
