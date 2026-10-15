#!/usr/bin/env python3
"""Collect Phase95 evidence without running compiler or benchmark targets."""
import argparse
import collections
import csv
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase95'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path),
                bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    actual = pin(Path(item.get('file', item.get('path'))))
    assert all(actual[k] == item[k] for k in ['bytes', 'sha256']), item


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/tools/performance/phase95')
    out.mkdir(parents=True, exist_ok=False)
    micro = read(RAW/'membership-measure02/report.json')
    screen = read(RAW/'compiler-screen01/report.json')
    full = read(RAW/'compiler-self01/report.json')
    broad = read(RAW/'compiler-broad01/report.json')
    for report in [micro, screen, full, broad]:
        assert report['complete'] and report['inputsUnchanged']
        for item in report['inputs']:
            verify(item)
    assert len(micro['cases']) == 6
    assert screen['summary']['exactCCount'] == 48
    assert full['summary']['exactCCount'] == 2
    assert broad['summary']['exactCCount'] == 45
    assert all(r['passed'] for r in screen['rows']+full['rows']+broad['rows'])
    assert all(r['expectedUnsafeRefusalExact'] for r in full['rows'])

    micro_builds = []; build_signatures = []
    for role in ['baseline', 'candidate']:
        folder = RAW/f'membership-{role}-build03'
        build = read(folder/'process.json')
        assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor')
        command = build['command']; start = next(i for i, x in enumerate(command) if x.endswith('/bin/clang'))
        tail = command[start:]
        assert '-O3' in tail and '-std=c11' in tail
        source, image = RAW/'membership03'/role/'program.c', RAW/'membership03'/role/'program'
        assert str((ROOT/tail[tail.index('-o')-1]).resolve()) == str(source)
        assert str((ROOT/tail[tail.index('-o')+1]).resolve()) == str(image)
        build_signatures.append(tail[:tail.index('-o')-1] + tail[tail.index('-o')+2:])
        for item in read(folder/'inputs.json'):
            verify(item)
        micro_builds.append(dict(role=role, receipt=pin(folder/'process.json'),
                                 inputs=pin(folder/'inputs.json'), command=command,
                                 source=pin(source), image=pin(image)))
    assert build_signatures[0] == build_signatures[1]
    save(out/'micro-builds.json', micro_builds)

    expected = ROOT/'selfhost/tools/performance/phase95/membership01/frozen01/controls.expected.txt'
    observed = RAW/'membership-controls-run01/stdout.log'
    assert observed.read_bytes() == expected.read_bytes()
    assert not (RAW/'membership-controls-run01/stderr.log').read_bytes()
    controls = dict(expected=pin(expected), observed=pin(observed), outputLines=len(observed.read_text().splitlines()))
    for name in ['membership-controls-acquire01', 'membership-controls-build01', 'membership-controls-run01']:
        record = read(RAW/name/'process.json')
        assert record['complete'] and record['returncode'] == 0 and not record.get('stoppedFor')
        controls[name] = pin(RAW/name/'process.json')
    save(out/'controls.json', controls)

    profiles = {}
    for name, file in [('map-profile02','callers.json'), ('self-profile01','callers-exploratory.json')]:
        capture = read(RAW/name/'report.json')
        assert capture['compilationPassed'] and capture['inputsUnchanged']
        for item in capture['inputs']:
            verify(item)
        report = read(RAW/name/file)
        profiles[name] = report
        save(out/(name+'.json'), report)
    assert profiles['map-profile02']['qualifiedCapture']
    assert not profiles['self-profile01']['qualifiedCapture']

    processes = []
    for file in sorted(RAW.rglob('process.json')):
        row = read(file); row['receipt'] = str(file.relative_to(ROOT)); processes.append(row)
    ordered = sorted(processes, key=lambda r:r['started'])
    overlaps = [(a['receipt'], b['receipt']) for a,b in zip(ordered, ordered[1:]) if a['finished'] > b['started']]
    assert not overlaps
    resources = dict(guardedJobs=len(processes), guardedWallSeconds=sum(r['wallSeconds'] for r in processes),
                     peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in processes), overlaps=overlaps,
                     stopped=[r['receipt'] for r in processes if r.get('stoppedFor')],
                     nonzeroExits=[r['receipt'] for r in processes if r['returncode'] != 0],
                     scope='Serial guarded occupancy only; not elapsed research time, agent effort or quota usage.')
    save(out/'execution-ledger.json', dict(summary=resources, processes=processes))

    with (out/'helper.csv').open('w', newline='') as f:
        w = csv.writer(f); w.writerow(['size','mode','baseline_us','candidate_us','candidate_over_baseline'])
        for c in micro['cases']:
            w.writerow([*c['args'], c['roles']['baseline']['medianUs'], c['roles']['candidate']['medianUs'], c['candidateOverBaseline']])
    with (out/'compiler.csv').open('w', newline='') as f:
        w = csv.writer(f); w.writerow(['case','pairs','baseline_request_ms','candidate_request_ms','candidate_over_baseline'])
        for report in [screen, full]:
            for name, c in report['summary']['cases'].items():
                r = c['requestMs']; w.writerow([name, report['rounds'], r['medians']['baseline'], r['medians']['candidate'], r['ratioOfMedians']])
    summary = dict(complete=True, scope='Isolated upstream-built native B1 experiment; production/images unchanged.',
                   helper=dict(cases=micro['cases'], scaling=micro['scaling'], sampleCounts=dict(collections.Counter(r['stage'] for r in micro['records']))),
                   screen=screen['summary'], fullInput=full['summary'], broadExactC=45, controls=controls,
                   resources=resources,
                   complexity=dict(candidateLines=-2, candidateBytes=-81, productionLines=0),
                   limitations=['Self profile has two overruns and remains exploratory.',
                                'Single full-input pair is not a confidence interval or new B2 qualification.',
                                'No new compiled-program timings or formal proof of unsafe has_name.'])
    save(out/'summary.json', summary)

    members = []; archive = out/'raw.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for path in sorted(RAW.rglob('*')):
            if not path.is_file(): continue
            record = pin(path); record['mode'] = path.stat().st_mode & 0o777
            z.write(path, record['file']); members.append(record)
    with zipfile.ZipFile(archive) as z:
        assert len(z.namelist()) == len(members)
        for row in members:
            data = z.read(row['file'])
            assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
    save(out/'archive.json', dict(complete=True, method=pin(Path(__file__)), archive=pin(archive),
                                  readbackVerifiedFiles=len(members), uncompressedBytes=sum(r['bytes'] for r in members),
                                  exclusions=[], members=members))
    print(json.dumps(dict(complete=True, resources=resources, archive=pin(archive), files=len(members))))


if __name__ == '__main__':
    main()
