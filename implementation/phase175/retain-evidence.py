#!/usr/bin/env python3
"""Copy finished compact Phase175 receipts; never execute compiler targets."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'implementation/phase175'
BUILD = ROOT / 'selfhost/build/phase175'
EVIDENCE = OUT / 'evidence'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('names', nargs='+', help='Explicit finished build directories')
    args = parser.parse_args()
    index = read(OUT / 'evidence-index.json')
    retained = read(EVIDENCE / 'index.json')
    metrics = read(OUT / 'metrics.json')
    rows = {r['name']: r for r in index['rows']}
    copies = {r['original']['file']: r for r in retained['files']}
    prepared = []
    for name in args.names:
        if re.fullmatch(r'[a-z0-9][a-z0-9-]*', name) is None:
            parser.error('Simple Phase175 directory names required')
        guard = BUILD / (name + '-guard') / 'process.json'
        report = BUILD / name / 'report.json'
        if not report.exists():
            # Admission refusals have no target report: the target never started.
            if not guard.exists() or read(guard).get('stoppedFor') != 'disk-admission':
                parser.error('No completed target report or admission refusal: ' + name)
            report = guard
        value = read(report)
        if guard.exists():
            if 'finished' not in read(guard):
                parser.error('Guard has not closed: ' + name)
        elif not value.get('complete'):
            parser.error('Unfinished report without a closed guard: ' + name)
        files = [report] + ([guard] if guard.exists() and guard != report else [])
        for filename in ['compiler.stderr', 'qbe.stderr']:
            path = report.parent / filename
            if path.is_file():
                files.append(path)
        for path in files:
            if path.stat().st_size > 262144:
                parser.error('Large artifact is outside compact receipt scope: ' + str(path))
            target = EVIDENCE / path.relative_to(BUILD)
            if target.exists() and target.read_bytes() != path.read_bytes():
                parser.error('Refuse to replace different retained bytes: ' + str(target))
        prepared.append((name, report, value, files))
    for name, report, value, files in prepared:
        for path in files:
            target = EVIDENCE / path.relative_to(BUILD)
            target.parent.mkdir(parents=True, exist_ok=True)
            if not target.exists():
                target.write_bytes(path.read_bytes())
            original, copy = pin(path), pin(target)
            assert original['sha256'] == copy['sha256']
            copies[original['file']] = dict(original=original, retained=copy)
        rows[name] = dict(name=name, kind=value['kind'], complete=value['complete'],
                          receipt=pin(report),
                          retainedReceipt=pin(EVIDENCE / report.relative_to(BUILD)),
                          seconds=value.get('seconds', value.get('wallSeconds',
                                             value.get('totalSeconds'))),
                          error=value.get('error', value.get('stoppedFor')))
    retained['files'] = list(copies.values())
    retained['bytes'] = sum(r['retained']['bytes'] for r in copies.values())
    assert retained['bytes'] < 3 * 1024 * 1024, 'Compact evidence exceeds 3 MiB'
    save(EVIDENCE / 'index.json', retained)
    index['rows'] = [rows[n] for n in sorted(rows)]
    index['snapshotUtc'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    index['retainedEvidenceIndex'] = pin(EVIDENCE / 'index.json')
    save(OUT / 'evidence-index.json', index)
    metrics['evidenceIndex'] = pin(OUT / 'evidence-index.json')
    metrics['retainedEvidence'].update(index=pin(EVIDENCE / 'index.json'),
                                      files=len(copies), bytes=retained['bytes'])
    save(OUT / 'metrics.json', metrics)
    print(json.dumps(dict(reports=args.names, files=len(copies), bytes=retained['bytes'])))


if __name__ == '__main__':
    main()
