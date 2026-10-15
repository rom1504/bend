#!/usr/bin/env python3
"""Collect the completed Phase94 pilot; no compiler or benchmark targets run.

Preserve failures as well as accepted observations. The official Lean binary
distribution is externally reproducible and excluded; its manifests are kept.
"""
import argparse
import collections
import csv
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase94'


def read(path):
    return json.loads(path.read_text())


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data), sha256=digest(data))


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    out = parser.parse_args().out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    proof = read(RAW / 'proof-replay02/report.json')
    micro = read(RAW / 'micro-measure01/report.json')
    screen = read(RAW / 'compiler-screen02/report.json')
    broad = read(RAW / 'compiler-broad01/report.json')
    mutations = read(RAW / 'mutations01/report.json')
    assert all(r['complete'] for r in [proof, micro, screen, broad, mutations])
    assert proof['independentlyChecked'] and len(proof['definitions']) == 36
    assert mutations['passed'] and len(mutations['rows']) == 3
    assert all(r['rejected'] for r in mutations['rows'])
    assert screen['summary']['exactCCount'] == 48 and broad['summary']['exactCCount'] == 45
    assert all(r['passed'] for r in screen['rows'] + broad['rows'])
    for report in [screen, broad]:
        for item in report['inputs']:
            path = Path(item['file'])
            assert (pin(path)['sha256'], path.stat().st_size) == (item['sha256'], item['bytes'])

    expected = RAW / 'integration01/edge-controls.expected.txt'
    stdout = RAW / 'controls-run01/stdout.log'
    assert stdout.read_bytes() == expected.read_bytes()
    assert not (RAW / 'controls-run01/stderr.log').read_bytes()
    controls = dict(complete=True, cases=stdout.read_text().splitlines(),
                    expected=pin(expected), observed=pin(stdout),
                    source=pin(RAW / 'integration01/edge-controls.bend'),
                    c=pin(RAW / 'controls01/program.c'),
                    executable=pin(RAW / 'controls01/program'))
    for name in ['controls-acquire01', 'controls-build01', 'controls-run01']:
        record = read(RAW / name / 'process.json')
        assert record['complete'] and record['returncode'] == 0
        controls[name] = record
    save(out / 'controls.json', controls)

    processes = []
    for path in sorted(RAW.rglob('process.json')):
        record = read(path)
        record['receipt'] = str(path.relative_to(ROOT))
        processes.append(record)
    ordered = sorted(processes, key=lambda r: r['started'])
    overlaps = [(a['receipt'], b['receipt']) for a, b in zip(ordered, ordered[1:])
                if a['finished'] > b['started']]
    assert not overlaps and not any(r.get('stoppedFor') for r in processes)
    resource = dict(guardedJobs=len(processes),
                    guardedWallSeconds=sum(r['wallSeconds'] for r in processes),
                    peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in processes),
                    overlaps=overlaps,
                    nonzeroExits=[r['receipt'] for r in processes if r['returncode'] != 0],
                    scope='Guard occupancy, not total elapsed time, agent work or quota usage.')
    save(out / 'execution-ledger.json', dict(summary=resource, processes=processes))

    with (out / 'helper.csv').open('w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['size', 'mask', 'new_binding', 'repetitions', 'baseline_us', 'candidate_us', 'candidate_over_baseline'])
        for case in micro['cases']:
            writer.writerow([*case['args'], case['repetitions'],
                             case['roles']['baseline']['medianUs'], case['roles']['candidate']['medianUs'],
                             case['candidateOverBaseline']])
    with (out / 'compiler.csv').open('w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['case', 'baseline_request_ms', 'candidate_request_ms', 'candidate_over_baseline'])
        for name, case in screen['summary']['cases'].items():
            r = case['requestMs']
            writer.writerow([name, r['medians']['baseline'], r['medians']['candidate'], r['ratioOfMedians']])

    summary = dict(complete=True, promoted=False,
                   decision='Retain the proven isolated candidate; compiler-wide gain is not established.',
                   proof=dict(independentAcceptance=True, independentFalseEqualityRejected=True,
                              definitions=36, rejectedMutations=3, adapterControls=6,
                              guardedStepSeconds={k: v['process']['wallSeconds'] for k, v in proof['rows'].items()}),
                   helper=dict(cases=micro['cases'], sampleCounts=dict(collections.Counter(r['stage'] for r in micro['records'])), scaling=micro['scaling']),
                   compiler=screen['summary'], broadProductIdentityCount=45,
                   complexity=dict(productionLineDelta=0, candidateLineDelta=50, candidateByteDelta=2230,
                                   safeHelperLines=31, referenceLines=30, proofLines=114),
                   resources=resource,
                   exclusions=['compiler-screen01: method changed during run; not pooled',
                               'profile-map01: two timer overruns; exploratory leaf attribution only',
                               'no candidate B2, full self-compilation, new broad conformance or program-runtime timing'])
    save(out / 'summary.json', summary)

    members = []
    archive = out / 'raw.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for path in sorted(RAW.rglob('*')):
            if not path.is_file():
                continue
            rel = path.relative_to(RAW)
            if rel.parts[0] == 'toolchain' and not (len(rel.parts) == 2 and path.suffix == '.json'):
                continue
            data = path.read_bytes()
            name = str(path.relative_to(ROOT))
            z.writestr(name, data)
            members.append(dict(file=name, bytes=len(data), sha256=digest(data), mode=path.stat().st_mode & 0o777))
    with zipfile.ZipFile(archive) as z:
        assert len(z.namelist()) == len(members)
        for row in members:
            data = z.read(row['file'])
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
    save(out / 'archive.json', dict(complete=True, method=pin(Path(__file__)), archive=pin(archive),
                                  readbackVerifiedFiles=len(members), uncompressedBytes=sum(r['bytes'] for r in members),
                                  exclusions=['Official Lean archive and extracted toolchain; all JSON manifests retained.'],
                                  members=members))
    print(json.dumps(dict(complete=True, resources=resource, archive=pin(archive), files=len(members))))


if __name__ == '__main__':
    main()
