#!/usr/bin/env python3
"""Authenticate equivalent immutable reference receipts; no compiler execution."""
import argparse
import hashlib
import json
from pathlib import Path

def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('old', type=Path)
    parser.add_argument('current', type=Path)
    parser.add_argument('stages', type=Path)
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    assert not args.out.exists()
    old, current, stages = (json.loads(p.read_text()) for p in (args.old, args.current, args.stages))
    assert old['complete'] and current['complete'] and stages['complete']
    for field in ('source', 'cases', 'wrappers'):
        assert old[field] == current[field], field
    verified = list(current['inputs']) + [current['source']]
    verified += [p for case in current['cases'] for p in (case['source'], case['expectedQbe'])]
    for item in verified:
        assert pin(item['file']) == item, item['file']
    expected = {case['name']: case['expectedQbe'] for case in current['cases']}
    for row in stages['rows']:
        assert row['complete'] and row['exactNativeReference']
        assert row['expected'] == expected[row['name']]
        assert row['actual'] == {k: expected[row['name']][k] for k in ('bytes', 'sha256')}
    record = dict(kind='phase134-reference-reconciliation', complete=True, targetsRun=False,
                  inputs=[pin(__file__), pin(args.old), pin(args.current), pin(args.stages)],
                  equalFields=['source', 'cases', 'wrappers'], verifiedCurrentInputs=verified,
                  observations=len(stages['rows']),
                  reason='The original stage attempt refused a modified reference-generation tool. The successful diagnostic authenticated the old immutable receipt and consumed products. This independent reconciliation authenticates the replacement receipt including every current creator input, and proves its source/cases/products are unchanged.')
    args.out.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps(dict(complete=True, observations=record['observations'], verified=len(verified))))

if __name__ == '__main__':
    main()
