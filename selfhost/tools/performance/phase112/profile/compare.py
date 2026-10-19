#!/usr/bin/env python3
"""Compare already validated diagnostic profiles offline; never compare timings."""
import argparse
import json
from pathlib import Path
from parse import pin
from run import read, verify

COUNTERS = ['rt_frame', 'rt_jump', 'rt_return', 'rt_apply', 'rt_closure', 'rt_keep', 'rt_sink',
            'rt_op', 'rt_take', 'rt_ctor', 'rt_special_take', 'rt_stack_get', 'heap_alloc',
            'rfc_wrap', 'register_words_copied', 'register_words_zeroed']


def delta(before, after):
    return dict(before=before, after=after, difference=after-before,
                ratio=after/before if before else None)


def stable(rows):
    return {row['decoded']: row['count'] for row in rows
            if 'decoded' in row and not row['decoded'].startswith('$p111.k.')}


def symbol_rows(rows):
    return {row.get('symbol', str(row['index'])): row['count'] for row in rows}


def load_batch(path):
    report = read(path)
    if report.get('kind') != 'phase112-diagnostic-batch' or not report.get('complete'):
        raise ValueError('complete diagnostic batch required: ' + str(path))
    inputs = [pin(path)]
    plan = read(path.parent / 'plan.json')
    inputs.append(pin(path.parent / 'plan.json'))
    cases = {}
    for row in report['cases']:
        if row['state'] != 'qualified':
            raise ValueError('unqualified diagnostic case')
        profile = read(verify(row['profile']))
        if not profile.get('complete') or not profile.get('diagnosticOnly'):
            raise ValueError('profile validation missing')
        cases[row['name']] = profile
        inputs.append(row['profile'])
    if len(cases) != 6 or any(c['repetitions'] != 1 or c['warmups'] != 0 for c in plan['cases']):
        raise ValueError('matching frozen six-program1/0 diagnostic policy required')
    return plan, cases, inputs


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--before', type=Path, required=True)
    p.add_argument('--after', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise SystemExit('fresh comparison output required')
    before_plan, before, inputs = load_batch(a.before)
    after_plan, after, after_inputs = load_batch(a.after)
    if set(before) != set(after) or before_plan['benchmarkManifest'] != after_plan['benchmarkManifest']:
        raise SystemExit('diagnostic benchmark identity mismatch')
    cases = []
    for name, old in before.items():
        new = after[name]
        if any(old['meta'][key] != new['meta'][key] for key in ['version', 'sourceSha256', 'heapRc', 'abi']):
            raise SystemExit('runtime instrumentation mismatch')
        old_case = next(c for c in before_plan['cases'] if c['name'] == name)
        new_case = next(c for c in after_plan['cases'] if c['name'] == name)
        if any(old_case[k] != new_case[k] for k in ['source', 'oracle', 'runtimeArgs', 'expected', 'repetitions', 'warmups']):
            raise SystemExit('case semantics/input mismatch')
        row = dict(name=name,
            counters={key: delta(old['counters'][key], new['counters'][key]) for key in COUNTERS},
            dispatches=delta(sum(r['count'] for r in old['histograms']['dispatch_fid']),
                             sum(r['count'] for r in new['histograms']['dispatch_fid'])),
            publicCalls=delta(sum(r['count'] for r in old['histograms']['public_calls_fid']),
                              sum(r['count'] for r in new['histograms']['public_calls_fid'])),
            transportWidth=delta(old['meta']['transportWidth'], new['meta']['transportWidth']),
            stableFunctions={}, semanticHistograms={})
        for hist in ['dispatch_fid', 'jump_fid', 'public_calls_fid']:
            prior, later = stable(old['histograms'][hist]), stable(new['histograms'][hist])
            changes = [dict(name=n, **delta(prior.get(n, 0), later.get(n, 0))) for n in prior.keys() | later.keys()]
            row['stableFunctions'][hist] = sorted(changes, key=lambda r: (-abs(r['difference']), -r['before'], r['name']))
        for hist in ['op', 'ctor_cid', 'take_cid', 'special_take_kind', 'frame_captures']:
            prior, later = symbol_rows(old['histograms'][hist]), symbol_rows(new['histograms'][hist])
            row['semanticHistograms'][hist] = {n: delta(prior.get(n, 0), later.get(n, 0))
                                               for n in sorted(prior.keys() | later.keys())}
        cases.append(row)
    report = dict(kind='phase112-offline-diagnostic-comparison', complete=True, targetsRun=False,
                  diagnosticNotTiming=True, inputs=[pin(Path(__file__)), *inputs, *after_inputs],
                  beforeBinding=before_plan['binding'], afterBinding=after_plan['binding'], cases=cases,
                  caveats=['Counter reductions are not CPU shares or measured speedups.',
                           'Anonymous continuation FIDs are unstable across snapshots and are not individually matched.',
                           'Private-worker calls inherit the last dispatched FID attribution.',
                           'Compare composition manifests before attributing a snapshot delta to a single pass.',
                           'Zero-count original events have no defined multiplicative ratio.'])
    a.out.mkdir(parents=True)
    (a.out / 'report.json').write_text(json.dumps(report, indent=2)+'\n')
    lines = ['# Diagnostic count comparison', '',
             'Counts only; no CPU-time attribution or speed claim. Anonymous continuation names are not matched.', '',
             '| Program | Dispatches before → after | Frames before → after | Primitive calls before → after | Allocations before → after |',
             '|---|---:|---:|---:|---:|']
    for row in cases:
        fields = [row['dispatches'], row['counters']['rt_frame'], row['counters']['rt_op'], row['counters']['heap_alloc']]
        lines.append('| '+row['name']+' | '+' | '.join(f"{d['before']:,} → {d['after']:,}" for d in fields)+' |')
    lines += ['', 'Input/profile pins and stable function/histogram deltas: [report.json](report.json).', '']
    (a.out / 'README.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True, targetsRun=False, report=str(a.out / 'report.json'))))


if __name__ == '__main__':
    main()
