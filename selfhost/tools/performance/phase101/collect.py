#!/usr/bin/env python3
"""Offline phase summary; counts every guarded target, including failed trials."""
from collections import Counter
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase101'
OUT = ROOT / 'implementation/phase101'


def pin(path):
    path = Path(path).resolve(); raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    OUT.mkdir(exist_ok=True)
    runs, targets = [], []
    for path in sorted(BUILD.glob('*/report.json')):
        r = json.loads(path.read_bytes())
        rows = r.get('records', r.get('executions', []))
        runs.append(dict(name=path.parent.name, receipt=pin(path), complete=r['complete'],
            error=r.get('error'), passed=sum(x.get('passed', x.get('outputCorrect', False)) for x in rows),
            observed=len(rows), elapsedSeconds=r.get('finished', 0)-r.get('started', 0)))
    for path in sorted(BUILD.rglob('process.json')):
        r = json.loads(path.read_bytes())
        if 'command' in r and 'started' in r and 'finished' in r:
            targets.append(dict(receipt=pin(path), started=r['started'], finished=r['finished'],
                seconds=r['wallSeconds'], peak=r.get('peakTreeRssBytes', 0),
                returncode=r.get('returncode'), stoppedFor=r.get('stoppedFor')))
    targets.sort(key=lambda x:x['started'])
    overlap = [(x['receipt']['file'],y['receipt']['file']) for x,y in zip(targets,targets[1:]) if x['finished']>y['started']]
    assert not overlap, overlap
    final_path = BUILD/'final-screen01/report.json'; final = json.loads(final_path.read_bytes())
    controls_path = BUILD/'controls-compare01/report.json'; controls = json.loads(controls_path.read_bytes())
    apps_path = BUILD/'app-controls01/report.json'; apps = json.loads(apps_path.read_bytes())
    assert final['complete'] and controls['complete'] and apps['complete']
    assert all(r['passed'] for r in final['records']+controls['executions']+apps['records'])
    profiles = []
    for name in ['source-profile03','image-profile02']:
        path = BUILD/name/'report.json'; r = json.loads(path.read_bytes()); assert r['complete']
        profiles.append(dict(receipt=pin(path), summaries=r['summaries']))
    result = dict(scope='Experimental host-only generated-C text ABI; installed compiler unchanged.',
        finalScreen=dict(receipt=pin(final_path), rows=final['summary'], products=final['products']),
        independentControls=dict(receipt=pin(controls_path), distinctCases=len({r['case'] for r in controls['executions']}),
            executions=len(controls['executions'])),
        applicationControls=dict(receipt=pin(apps_path), distinctCases=len(apps['cases']),
            executions=len(apps['records']), byApp=dict(Counter(c['app'] for c in apps['cases']))),
        profiles=profiles, runs=runs,
        queue=dict(jobs=len(targets), occupiedSeconds=sum(r['seconds'] for r in targets),
            spanSeconds=targets[-1]['finished']-targets[0]['started'], peakTreeRssBytes=max(r['peak'] for r in targets),
            failedTargets=sum(r['returncode']!=0 for r in targets), resourceStops=[r for r in targets if r['stoppedFor']],
            overlaps=overlap), targets=targets)
    (OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['independentControls','applicationControls','queue']}))


if __name__=='__main__': main()
