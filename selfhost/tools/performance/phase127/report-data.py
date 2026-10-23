#!/usr/bin/env python3
"""Summarize retained Phase127 measurements and draw the report figures; no targets."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import statistics

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase127'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    return {'path': str(path.relative_to(ROOT)), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    inputs = []
    def load(name):
        path = BUILD / name
        inputs.append(pin(path))
        return read(path)
    paired = load('live-bank-paired01/report.json')
    short = []
    for workload in sorted({r['workload'] for r in paired['rows']}):
        variants = {}
        for variant in ['phase125', 'phase126', 'live-bank']:
            rows = [r for r in paired['rows'] if r['workload'] == workload
                    and r['variant'] == variant and r['mode'] == 'clean']
            assert len(rows) == 3 and all(r['correct'] for r in rows)
            variants[variant] = {'wallSeconds': statistics.median(r['wallSeconds'] for r in rows),
                                 'cpuSeconds': statistics.median(r['cpuSeconds'] for r in rows),
                                 'observations': len(rows)}
        short.append({'workload': workload, 'variants': variants})
    full = load('full-clean02/report.json')
    full_rows = {r['variant']: r for r in full['rows']}
    assert full['complete'] and full['passed'] and len(full_rows) == 2
    full_times = {v: r['wallSeconds'] for v, r in full_rows.items()}
    analyses = {}
    for name, file in [
        ('originalExecutable', 'full-physical01/000-sample-compiler-source32-live-bank/analysis.json'),
        ('dispatchInstrumented', 'full-profile01/000-sample-compiler-source32-live-bank-diagnostic/analysis.json')]:
        d = load(file)
        assert d['usable'] and d['zeroLoss']
        analyses[name] = {'samples': d['header']['samples'], 'quality': d['quality'],
                          'physicalLeaves': d['top_functions'][:25],
                          'destructionFraction': sum(r['fraction'] for r in d['top_functions']
                                                     if r['name'] in ('term_drop', 'span_fade'))}
    owners = load('full-profile01-attribution/report.json')
    owner_counts = Counter()
    for row in owners['dispatchContexts']:
        owner_counts[row.get('loweredOwner') or '[unknown]'] += row['samples']
    owner_total = owners['coverage']['allSamples']
    owner_rows = [{'loweredOwner': name, 'samples': count, 'fractionOfAllSamples': count/owner_total}
                  for name, count in owner_counts.most_common()]
    guard_rows = []
    for path in sorted(BUILD.rglob('process.json')):
        d = read(path)
        if 'wallSeconds' not in d:
            continue
        inputs.append(pin(path))
        name = str(path.parent.relative_to(BUILD))
        if 'same-source' in name:
            category = 'full-image emission'
        elif 'api' in name or 'build01-guard' == path.parent.name:
            category = 'compiler acquisition and build'
        elif 'full-' in name:
            category = 'full-source measurements'
        elif any(k in name for k in ('sampler', 'runtime', '-build-guard', 'build-guard')):
            category = 'profiling machinery and controls'
        else:
            category = 'short experiments and validation'
        guard_rows.append({'path': str(path.relative_to(ROOT)), 'category': category,
                           **{k: d.get(k) for k in ['started', 'finished', 'wallSeconds',
                                                    'returncode', 'complete', 'peakTreeRssBytes']}})
    totals = {}
    for row in guard_rows:
        totals[row['category']] = totals.get(row['category'], 0) + row['wallSeconds']
    result = {'schema': 'phase127-report-data-v1', 'inputs': inputs, 'shortRequests': short,
              'repairedOverPhase126': math.exp(statistics.mean(math.log(
                  r['variants']['live-bank']['wallSeconds'] / r['variants']['phase126']['wallSeconds']) for r in short)),
              'repairedOverPhase125': math.exp(statistics.mean(math.log(
                  r['variants']['live-bank']['wallSeconds'] / r['variants']['phase125']['wallSeconds']) for r in short)),
              'fullRequestSeconds': full_times, 'fullSinglePairRatio': full_times['live-bank']/full_times['phase126'],
              'fullProfiles': analyses, 'dispatchContexts': owner_rows[:15],
              'guardedJobs': guard_rows, 'guardedSecondsByCategory': totals,
              'scope': 'Short requests are 3-round clean medians. Full clean comparison is one pair. Physical leaves and active contexts are distinct, nonadditive views. Guard sums exclude unrecorded work and agent reasoning; concurrent offline work overlaps.'}
    (a.out/'data.json').write_text(json.dumps(result, indent=2)+'\n')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    plt.rcParams.update({'font.size': 10, 'svg.fonttype': 'none'})
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.8), gridspec_kw={'width_ratios': [1.6, 1]})
    colors = ['#8395a7', '#ca564a', '#167c80']
    for j, (variant, label) in enumerate(zip(['phase125', 'phase126', 'live-bank'],
                                            ['Phase125', 'Phase126', 'Admission repaired'])):
        axes[0].bar([i+(j-1)*.25 for i in range(3)],
                    [r['variants'][variant]['wallSeconds'] for r in short], .25, label=label, color=colors[j])
    axes[0].set_xticks(range(3), ['Closures', 'Map churn', 'Lexer'])
    axes[0].set_ylabel('Complete request wall time (seconds)')
    axes[0].set_title('Short native compiler requests\nThree clean rounds; median')
    axes[0].legend(frameon=False)
    bars = axes[1].bar(['Phase126', 'Repaired'], [full_times['phase126'], full_times['live-bank']], color=colors[1:])
    axes[1].bar_label(bars, fmt='%.1f s', padding=3)
    axes[1].set_ylim(0, 560)
    axes[1].set_ylabel('Complete request wall time (seconds)')
    axes[1].set_title('Compile unchanged compiler source\nOne clean pair; exact QBE output')
    for ax in axes:
        ax.spines[['top', 'right']].set_visible(False)
    fig.suptitle('A missing transport certificate caused unnecessary work', fontsize=14)
    fig.tight_layout()
    for ext in ['svg', 'png']:
        fig.savefig(a.out/f'compiler-cost.{ext}', dpi=160)
    plt.close(fig)
    fig, axes = plt.subplots(1, 2, figsize=(12, 5.7))
    leaves = analyses['originalExecutable']['physicalLeaves'][:9]
    labels = [r['decoded'].replace('p113d_FID_$direct.', '') for r in leaves]
    axes[0].barh(labels[::-1], [100*r['fraction'] for r in leaves][::-1], color='#167c80')
    axes[0].set_title('Physical CPU leaves\nOriginal executable; 55,761 samples')
    contexts = owner_rows[:9]
    axes[1].barh([r['loweredOwner'] for r in contexts][::-1],
                 [100*r['fractionOfAllSamples'] for r in contexts][::-1], color='#6a63a3')
    axes[1].set_title('Active Bend dispatch context\nDiagnostic executable; 36,220 samples')
    for ax in axes:
        ax.set_xlabel('Percent of all samples, including unknowns')
        ax.spines[['top', 'right']].set_visible(False)
    fig.suptitle('Full-source compilation: ownership work and repeated name operations', fontsize=14)
    fig.text(.5, .01, 'These are two views of execution, not additive costs or a logical call stack.', ha='center', fontsize=9)
    fig.tight_layout(rect=(0, .035, 1, 1))
    for ext in ['svg', 'png']:
        fig.savefig(a.out/f'full-profile.{ext}', dpi=160)
    plt.close(fig)
    print(json.dumps({'out': str(a.out), 'shortRatio': result['repairedOverPhase126'],
                      'fullRatio': result['fullSinglePairRatio'], 'guardedSeconds': sum(totals.values())}))


if __name__ == '__main__':
    main()
