#!/usr/bin/env python3
"""Render a generic profiler comparison as a readable Markdown report."""
import argparse
import json
from pathlib import Path
from run import pin


def cell(value):
    return str(value).replace('\n', ' ').replace('|', '\\|').replace('`', '\\`')


def number(value, digits=4):
    return '—' if value is None else f'{value:.{digits}f}'


def render(document, top=10):
    if document.get('schema') != 'bend-native-profile-comparison-v1' or not document.get('complete'):
        raise ValueError('Complete native profiler comparison required')
    lines = ['# Native profiling comparison', '',
             'Clean timings measure complete child processes. Sample and counter runs are diagnostic.',
             'CPU attribution is approximate; event counts are not time percentages.', '',
             '| Workload | Variant | Clean runs | Wall median (s) | CPU median (s) | Peak RSS median (KiB) |',
             '|---|---|---:|---:|---:|---:|']
    for workload, variants in document['workloads'].items():
        for variant, data in variants.items():
            clean = data['clean']
            lines.append('| %s | %s | %s | %s | %s | %s |' % (cell(workload), cell(variant),
                clean['wallSeconds']['count'], number(clean['wallSeconds']['median']),
                number(clean['cpuSeconds']['median']), number(clean['peakRssKiB']['median'],0)))
    ratios = [r for r in document.get('comparisons', []) if r['cleanRatios']]
    if ratios:
        lines += ['', '## Clean comparisons', '', '| Workload | Variant / reference | Wall ratio | CPU ratio |',
                  '|---|---|---:|---:|']
        for row in ratios:
            lines.append('| %s | %s / %s | %s | %s |' % (cell(row['workload']), cell(row['variant']),
                cell(row['reference']), number(row['cleanRatios'].get('wallSeconds')),
                number(row['cleanRatios'].get('cpuSeconds'))))
    for workload, variants in document['workloads'].items():
        for variant, data in variants.items():
            profile = data['profile']
            lines += ['', '## %s — %s' % (cell(workload),cell(variant)), '',
                f"Accepted samples: {profile['samples']}; rejected captures: {len(profile['rejectedCaptures'])}; "
                f"unknown leaf samples: {profile['unknownSamples']}. "
                f"Adequate pooled sample count/quality: {profile['adequate']}. "
                f"Absolute CPU estimate available: {profile['estimateAvailable']}."]
            reasons = profile.get('estimateUnavailableReasons', [])
            if reasons:
                lines += ['', 'Estimate limits: '+ '; '.join(cell(s) for s in reasons)+'.']
            if 'contextOnlyOverCleanWallRatio' in data:
                lines += ['', 'Diagnostic wall-time ratios against explicit clean baseline: sampling '+
                    number(data.get('sampledOverCleanWallRatio'))+', context-only '+
                    number(data.get('contextOnlyOverCleanWallRatio'))+', counters '+
                    number(data.get('countersOverCleanWallRatio'))+'.']
            if profile['functions']:
                lines += ['', '| Physical leaf | Samples | Period-weighted share | Approximate clean CPU (s) |',
                          '|---|---:|---:|---:|']
                for row in profile['functions'][:top]:
                    lines.append('| %s | %s | %.2f%% | %s |' % (cell(row['decoded']),row['samples'],
                        100*row['periodWeightedFraction'],number(row.get('estimatedCleanCpuSeconds'))))
            if data['eventCounts']:
                lines += ['', 'Runtime events are attributed to execution context; inline operations may bypass hooks.', '',
                          '| Event | Repetitions | Median | Min | Max |', '|---|---:|---:|---:|---:|']
                for event, value in data['eventCounts'].items():
                    lines.append('| %s | %s | %s | %s | %s |' % (cell(event),value['count'],
                        number(value['median'],0),number(value['minimum'],0),number(value['maximum'],0)))
    lines += ['', '## Limits', '', *['- '+cell(s) for s in document.get('limitations',[])], '']
    return '\n'.join(lines)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--comparison',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--top',type=int,default=10)
    a=p.parse_args()
    if not 1 <= a.top <= 100 or a.out.exists():
        raise ValueError('Use a fresh output and 1–100 top leaves')
    identity=pin(a.comparison)
    text=render(json.loads(a.comparison.read_text()),a.top)
    if pin(a.comparison)!=identity:
        raise ValueError('Comparison changed during rendering')
    with a.out.open('x') as stream:
        stream.write(text+'\nEvidence SHA256: `'+identity['sha256']+'`.\n')
    print(json.dumps(dict(complete=True,report=pin(a.out),comparison=identity)))


if __name__=='__main__':
    main()
