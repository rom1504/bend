#!/usr/bin/env python3
"""Offline Phase191 cost snapshot; reads receipts and frozen sources only."""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HELPER = ROOT / 'selfhost/tests/phase190/campaign-cost.py'
spec = importlib.util.spec_from_file_location('phase190_cost', HELPER)
cost = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cost)
cost.CAMPAIGN = ROOT / 'selfhost/build/phase191'


def source_snapshot(directory):
    data, pin = cost.capture(directory / 'compiler.bend')
    map_data, map_pin = cost.capture(directory / 'source-map.json')
    entries = json.loads(map_data)
    selected = [r for r in entries if r['file'].startswith('src/back/x86/')]
    spans = sorted((r['generatedStartByte'], r['generatedStartByte'] + r['spanBytes']) for r in selected)
    for i, (start, end) in enumerate(spans):
        if start < 0 or end > len(data) or start > end or (i and spans[i-1][1] > start):
            raise ValueError('Invalid or overlapping frozen x86 source-map spans')
    return dict(source=pin, sourceMap=map_pin, lines=len(data.splitlines()),
                mappedX86Declarations=len(selected), mappedX86Modules=len({r['file'] for r in selected}),
                mappedX86SpanBytes=sum(end-start for start, end in spans))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists() or args.out.suffix != '.json':
        parser.error('--out must be a fresh .json file')
    rows = cost.guards()
    before = source_snapshot(ROOT / 'selfhost/build/phase190/selected-source01')
    after = source_snapshot(cost.CAMPAIGN / 'selected-source01')
    result = dict(kind='phase191-offline-campaign-cost', version=1,
        capturedUTC=datetime.now(timezone.utc).isoformat(), programsExecuted=False,
        method=cost.capture(Path(__file__))[1], helper=cost.capture(HELPER)[1],
        summary=cost.totals(rows), jobs=rows,
        byCategory={c: cost.totals([r for r in rows if r['category'] == c]) for c in sorted({r['category'] for r in rows})},
        failedJobs=[r['job'] for r in rows if r['status'] == 'failed'],
        incompleteJobs=[r['job'] for r in rows if r['status'] == 'incomplete'],
        sourceGrowth=dict(baseline=before, selected=after,
            deltaBytes=after['source']['bytes']-before['source']['bytes'],
            deltaLines=after['lines']-before['lines'],
            deltaMappedX86Declarations=after['mappedX86Declarations']-before['mappedX86Declarations'],
            deltaMappedX86SpanBytes=after['mappedX86SpanBytes']-before['mappedX86SpanBytes']),
        scope='As-of snapshot of finished outer guard wall durations, including failures; incomplete receipts excluded. Not elapsed research time, CPU time, kernel time, quota, or an atomic campaign close. Peak RSS/disk are per-job maxima, never summed. Unguarded work absent. Native45 acquisition is classified with native qualification by the reused category helper but does not establish compiler qualification. Source sizes compare frozen assembled sources and disjoint mapped x86 declaration spans, including comments; not logical complexity or whole maintained-module churn. No mutable worktree source attribution.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(out=str(args.out), summary=result['summary'], sourceGrowth=result['sourceGrowth'], incompleteJobs=result['incompleteJobs'])))


if __name__ == '__main__':
    main()
