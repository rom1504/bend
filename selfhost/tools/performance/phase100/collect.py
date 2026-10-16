#!/usr/bin/env python3
"""Collect completed Phase100 receipts without executing compilers or programs."""
import csv
import hashlib
import json
from pathlib import Path
import statistics
import sys

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase100'
OUT = ROOT / 'implementation/phase100'


def read(path):
    return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    measurements, acquisition, failures = [], [], []
    for path in sorted(BUILD.glob('*/report.json')):
        row = read(path)
        if row.get('kind') == 'phase100-applications-measure':
            if row['complete']:
                assert all(record['passed'] for record in row['records'])
                measurements.append((path, row))
            else:
                failures.append(dict(report=pin(path), error=row.get('error'),
                                     records=len(row['records'])))
        elif row.get('kind') == 'phase100-applications-acquire':
            if row['complete']:
                acquisition.append((path, row))
            else:
                failures.append(dict(report=pin(path), apps=row['apps']))
    cases = {(case['app'], case['id']) for _, run in measurements for case in run['cases']}
    executions = sum(len(run['records']) for _, run in measurements)
    jobs = [dict(receipt=pin(path), **read(path)) for path in BUILD.rglob('process.json')]
    jobs.sort(key=lambda row: row['started'])
    assert all(a['finished'] <= b['started'] for a, b in zip(jobs, jobs[1:])), 'Targets overlapped'
    apps = []
    for path, run in acquisition:
        for app in run['apps']:
            assert app['complete'] and app['sameNativeC']
            assert pin(app['source']['file']) == app['source']
            apps.append(dict(report=pin(path), **app))
    summaries = [dict(run=path.parent.name, **row) for path, run in measurements for row in run['summary']]
    renderer = []
    for workers in (1, 2, 4):
        roles = {}
        for role in ('b2', 'upstream'):
            values = [row['job']['seconds'] for _, run in measurements for row in run['records']
                      if row['app'] == 'image-render' and row['case'] == 'survey-production'
                      and row['workers'] == workers and row['role'] == role]
            roles[role] = dict(samples=len(values), medianSeconds=statistics.median(values),
                               rangeSeconds=[min(values), max(values)])
        renderer.append(dict(workers=workers, roles=roles,
                             ratio=roles['b2']['medianSeconds'] / roles['upstream']['medianSeconds']))
    result = dict(kind='phase100-application-scoreboard', complete=True,
                  method=pin(__file__), apps=apps, measurements=[pin(path) for path, _ in measurements],
                  completeExecutions=executions, distinctInputs=len(cases),
                  casesByApplication={name: sum(app == name for app, _ in cases)
                                      for name in sorted({app for app, _ in cases})},
                  applicationBendLines=sum(len(Path(app['source']['file']).read_text().splitlines()) for app in apps),
                  compilerChanged=False, summaries=summaries, rendererAllObservations=renderer,
                  retainedIncompleteRuns=failures,
                  execution=dict(jobs=len(jobs), serial=True,
                                 occupiedSeconds=sum(job['wallSeconds'] for job in jobs),
                                 firstToLastSeconds=jobs[-1]['finished'] - jobs[0]['started'],
                                 peakTreeRssBytes=max(job['peakTreeRssBytes'] for job in jobs),
                                 resourceStops=[job['receipt'] for job in jobs if job.get('stoppedFor')]),
                  scope='Complete native applications, same Bend sources, own vs upstream C; no universal aggregate or compiler promotion.')
    (OUT / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    with (OUT / 'runtime.csv').open('w') as stream:
        writer = csv.writer(stream)
        writer.writerow(['run', 'application', 'case', 'workers', 'own_seconds', 'upstream_seconds',
                         'own_over_upstream', 'own_peak_rss_kib', 'upstream_peak_rss_kib', 'both_at_least_100ms'])
        for row in summaries:
            own, upstream = row['roles']['b2'], row['roles']['upstream']
            writer.writerow([row['run'], row['app'], row['case'], row['workers'], own['seconds'],
                             upstream['seconds'], row['ratio'], own['rssKiB'], upstream['rssKiB'], row['substantial']])
    print(json.dumps({key: result[key] for key in ['completeExecutions', 'distinctInputs',
                                                'casesByApplication', 'applicationBendLines', 'execution']}, indent=2))


if __name__ == '__main__':
    sys.exit(main())
