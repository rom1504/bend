#!/usr/bin/env python3
"""Snapshot closed outer Phase175 guards, without running any targets."""
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'selfhost/build/phase175'
OUT = ROOT / 'implementation/phase175'


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(raw),
                sha256=hashlib.sha256(raw).hexdigest())


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    retained = json.loads((OUT / 'evidence/index.json').read_text())
    copies = {r['original']['file']: r for r in retained['files']}
    rows, pending = [], []
    for path in sorted(BUILD.glob('*-guard/process.json')):
        value = json.loads(path.read_text())
        assert value['kind'] == 'build-retention-disk-guard-v1'
        name = path.parent.name.removesuffix('-guard')
        if 'finished' not in value:
            pending.append(dict(name=name, started=value.get('started')))
            continue
        assert value['finished'] >= value['started']
        target = OUT / 'evidence' / path.relative_to(BUILD)
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            assert target.read_bytes() == path.read_bytes()
        else:
            target.write_bytes(path.read_bytes())
        original, copy = pin(path), pin(target)
        copies[original['file']] = dict(original=original, retained=copy)
        outcome = ('passed' if value.get('complete') else
                   'admission-refused' if value.get('stoppedFor') == 'disk-admission' else
                   'stopped' if value.get('stoppedFor') else 'failed')
        rows.append(dict(name=name, outcome=outcome, receipt=original,
                         retainedReceipt=copy, started=value['started'],
                         finished=value['finished'], wallSeconds=value['wallSeconds'],
                         returncode=value.get('returncode'),
                         stoppedFor=value.get('stoppedFor')))
    intervals = sorted((r['started'], r['finished']) for r in rows)
    merged = []
    for start, end in intervals:
        if merged and start <= merged[-1][1]:
            merged[-1][1] = max(end, merged[-1][1])
        else:
            merged.append([start, end])
    union = sum(end-start for start, end in merged)
    sum_intervals = sum(end-start for start, end in intervals)
    by_outcome = {}
    for row in rows:
        group = by_outcome.setdefault(row['outcome'], dict(count=0, wallSeconds=0))
        group['count'] += 1
        group['wallSeconds'] += row['wallSeconds']
    result = dict(kind='phase175-outer-guard-cost-census', version=1,
                  snapshotUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  scope='Immediate selfhost/build/phase175/*-guard/process.json only. Each closed outer invocation counted once, including failures/refusals. Nested case/emission/build reports and inner timing components are never added. Storage recovery, unguarded work, agent effort and quota are outside this total. Pending outer runs are listed but not charged partial times.',
                  method=pin(Path(__file__).resolve()), closedCount=len(rows),
                  closedWallSeconds=sum(r['wallSeconds'] for r in rows),
                  intervalUnionSeconds=union,
                  overlappingIntervalSeconds=sum_intervals-union,
                  byOutcome=by_outcome, pending=pending, rows=rows)
    save(OUT / 'cost-census.json', result)
    retained['files'] = list(copies.values())
    retained['bytes'] = sum(r['retained']['bytes'] for r in copies.values())
    assert retained['bytes'] < 3 * 1024 * 1024
    save(OUT / 'evidence/index.json', retained)
    index = json.loads((OUT / 'evidence-index.json').read_text())
    index['retainedEvidenceIndex'] = pin(OUT / 'evidence/index.json')
    save(OUT / 'evidence-index.json', index)
    metrics = json.loads((OUT / 'metrics.json').read_text())
    metrics['evidenceIndex'] = pin(OUT / 'evidence-index.json')
    metrics['retainedEvidence'].update(index=pin(OUT / 'evidence/index.json'),
                                      files=len(copies), bytes=retained['bytes'])
    metrics['costCensus'] = pin(OUT / 'cost-census.json')
    save(OUT / 'metrics.json', metrics)
    print(json.dumps({k: result[k] for k in ['closedCount', 'closedWallSeconds',
                     'overlappingIntervalSeconds', 'byOutcome', 'pending']}))


if __name__ == '__main__':
    main()
