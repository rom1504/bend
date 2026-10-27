#!/usr/bin/env python3
"""Summarize completed Phase146 measurements without executing targets."""
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    out = ROOT/'implementation/phase146/metrics.json'
    assert not out.exists()
    evidence = []

    def read(name):
        path = ROOT/name
        r = json.loads(path.read_text())
        assert r['complete'], path
        evidence.append(pin(path))
        return r

    native = read('selfhost/build/phase146/native-screen01/report.json')
    hosted = read('selfhost/build/phase146/hosted-screen01/report.json')
    counts = read('selfhost/build/phase146/counts01/report.json')
    full = read('selfhost/build/phase146/full-stream01/report.json')
    qualification = read('implementation/phase146/qualification.json')
    builds = [read('selfhost/build/phase134/p146-context01-'+n+'/report.json') for n in ['n1','n2']]
    guards = []
    for p in sorted((ROOT/'selfhost/build/phase146').rglob('process.json')):
        r = json.loads(p.read_text())
        if not ('rssLimitBytes' in r and 'availableFloorBytes' in r):
            continue
        assert 'finished' in r and 'returncode' in r, p
        guards.append(dict(receipt=pin(p), **{k:r[k] for k in ['started','finished','wallSeconds','returncode','peakTreeRssBytes']}))
    guards.sort(key=lambda r:r['started'])
    assert all(b['started'] >= a['finished'] for a,b in zip(guards, guards[1:])), 'Overlapping target guards'
    assert len(native['rows']) == 32 and all(r['byteExact'] for r in native['rows'])
    result = dict(kind='phase146-measured-results', complete=True, targetsRun=False, inputs=[pin(__file__),*evidence],
        nativeSmall=dict(cases=native['cases'], pairsPerCase=4, exactProducts=32,
                         geometricAcrossCases=math.exp(sum(math.log(c['candidateOverBaselineGeometric']) for c in native['cases'])/4),
                         scope='Exploratory alternating fresh native requests; no new upstream comparison.'),
        nativeFull=dict(rows=full['rows'], candidateOverBaseline=full['candidateOverBaseline'],
                        timeReductionPercent=100*(1-full['candidateOverBaseline']),
                        scope='One matched baseline-first source03 request pair, literal streaming QBE consumer; source-specific cold, prepared Base, OS caches not flushed; machine construction excluded.'),
        acquisition=[dict(seconds=r['wallSeconds'], emitAndQbeSeconds=r['emitAndQbeSeconds'], retainIR=r['retainIR']) for r in builds],
        acquisitionTimingCaveat='N1 retained QBE while N2 did not. Their 275/268-second clocks are actual acquisition costs, not a clean speed comparison.',
        generatedProgramQuality=dict(exactParentQbe=qualification['suites'], freshRuntimeBenchmark=False),
        guards=guards,
        cost=dict(jobs=len(guards), targetSeconds=sum(g['wallSeconds'] for g in guards),
                  failedJobs=sum(g['returncode'] != 0 for g in guards),
                  failedSeconds=sum(g['wallSeconds'] for g in guards if g['returncode'] != 0),
                  peakTreeRssBytes=max(g['peakTreeRssBytes'] for g in guards),
                  scope='Nonoverlapping outer guards only; includes acquisition, measurement, qualification and failures. Excludes metadata/source editing, archival work and unmeasured agent effort; no quota claim.'))
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(full=result['nativeFull']['timeReductionPercent'], small=result['nativeSmall']['geometricAcrossCases'], cost=result['cost'])))


if __name__ == '__main__':
    main()
