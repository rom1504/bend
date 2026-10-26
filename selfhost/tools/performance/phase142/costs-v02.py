#!/usr/bin/env python3
"""Summarize completed guard receipts; nested timers are not added again."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase142')
    rows = []
    files = set((ROOT/'selfhost/build/phase142').rglob('process.json'))
    files.update((ROOT/'selfhost/build/phase111').glob('*p142*-guard/process.json'))
    for file in sorted(files):
        if not file.parent.name.endswith('-guard'): continue
        r = json.loads(file.read_text())
        assert 'finished' in r, f'Guard still active: {file}'
        name = file.parent.name
        kind = ('acquisition' if ('api' in name and 'screen' not in name) or any(x in name for x in ['indexed-emit','indexed-build']) else
                'profile' if 'context' in str(file.relative_to(ROOT/'selfhost/build')) else
                'controls' if any(k in name for k in ['controls', 'loader']) else
                'measurement')
        rows.append(dict(name=name, category=kind, complete=r['complete'],
                         seconds=r['wallSeconds'], start=r['started'], end=r['finished'],
                         peakRssBytes=r['peakTreeRssBytes'],
                         minimumAvailableBytes=r['minimumAvailableBytes'], receipt=pin(file)))
    intervals = []
    for r in sorted(rows, key=lambda r: r['start']):
        if intervals and r['start'] <= intervals[-1][1]:
            intervals[-1][1] = max(intervals[-1][1], r['end'])
        else:
            intervals.append([r['start'], r['end']])
    result = dict(kind='phase142-completed-guard-costs', complete=True, inputs=[pin(Path(__file__))],
                  guards=len(rows), failed=sum(not r['complete'] for r in rows),
                  summedGuardSeconds=sum(r['seconds'] for r in rows),
                  guardUnionSeconds=sum(b-a for a, b in intervals),
                  failedGuardSeconds=sum(r['seconds'] for r in rows if not r['complete']),
                  categories={k: sum(r['seconds'] for r in rows if r['category']==k)
                              for k in sorted({r['category'] for r in rows})},
                  peakTreeRssBytes=max(r['peakRssBytes'] for r in rows),
                  minimumAvailableBytes=min(r['minimumAvailableBytes'] for r in rows),
                  rows=rows,
                  scope='Guard wall includes supervised setup, execution and validation. '
                  'API checks, native profiling, measurements and failures remain visible. '
                  'This is not agent reasoning cost, quota consumption or a compiler speed ratio.')
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'inputs','rows'}}))


if __name__ == '__main__':
    main()
