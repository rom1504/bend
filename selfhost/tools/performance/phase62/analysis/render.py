#!/usr/bin/env python3
"""Plot saved Phase62 profile partitions; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

GROUPS = {
    'Imports / API': {'api-load', 'module-compilation', 'typescript-module-stripping'},
    'Base cache / identity': {'base-cache', 'base-identity', 'base-preparation'},
    'Source / completion': {'source-loading', 'source-completion', 'source-graph-freshening', 'source-error-scan'},
    'Checking': {'checker'},
    'Backend analysis / emission': {'owned-foreign-layout', 'book-context', 'roots-and-stops', 'source-reach',
        'annotation', 'emitted-reach', 'final-library', 'final-program', 'host-wrapper', 'foreign-validation',
        'layout-proof', 'foreign-paths', 'foreign-modules', 'foreign-sources', 'ts-file-analysis', 'ts-library', 'ts-program'},
    'GC': {'GC'},
    'Inspector': {'inspector-overhead'},
    'Residual': set(),
}
COLORS = ['#87b8de', '#d5ae65', '#4fa58a', '#7272b8', '#ce737b', '#909090', '#e4b4d2', '#dddddd']


def identity(file):
    p = Path(file).resolve()
    return dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--analysis', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    source = identity(a.analysis)
    data = json.loads(a.analysis.read_text())
    assert data['complete'] and data['pass']
    rows = {(r['mode'], r['case'], r['role']): r for r in data['rows']}
    cases = list(dict.fromkeys(r['case'] for r in data['rows']))
    assert len(cases) == 23
    for c in cases:
        for role in ['b2', 'typescript']:
            assert ('cpu', c, role) in rows and ('allocation', c, role) in rows
    matrix, allocation, details = [], [], []
    for c in cases:
        for role in ['b2', 'typescript']:
            v = rows['cpu', c, role]['views']['counts']
            bins = dict.fromkeys(GROUPS, 0.0)
            for entry in v['exclusiveStages']:
                group = next((g for g, names in GROUPS.items() if entry['name'] in names), 'Residual')
                bins[group] += entry['percent']
            matrix.append([bins[g] for g in GROUPS])
        b = rows['allocation', c, 'b2']['views']['bytes']['total']
        t = rows['allocation', c, 'typescript']['views']['bytes']['total']
        allocation.append(b/t)
        details.append(dict(case=c, allocationB2Bytes=b, allocationTSBytes=t, allocationRatio=b/t))
    values = np.array(matrix)
    positions = np.arange(len(cases))
    fig, (left, right) = plt.subplots(1, 2, figsize=(15, 14), sharey=True, gridspec_kw={'width_ratios': [2.4, 1]})
    y = np.ravel(np.column_stack([positions-.18, positions+.18]))
    bottom = np.zeros(len(matrix))
    for i, group in enumerate(GROUPS):
        left.barh(y, values[:, i], left=bottom, height=.29, color=COLORS[i], label=group, linewidth=0)
        bottom += values[:, i]
    left.set_yticks(positions, cases, fontsize=9)
    left.invert_yaxis()
    left.set_xlim(0, 100)
    left.set_xlabel('Exclusive CPU sample-count share (%)')
    left.set_title('First request: B2 upper bar, TypeScript lower bar', loc='left', fontsize=12)
    left.grid(axis='x', alpha=.2)
    left.set_axisbelow(True)
    left.legend(loc='upper left', bbox_to_anchor=(0, -.055), ncol=3, frameon=False, fontsize=9)
    right.barh(positions, allocation, height=.58, color='#447da6')
    right.axvline(1, color='#303030', linewidth=1, linestyle='--')
    right.set_xlim(0, max(allocation)*1.22)
    right.set_xlabel('Sampled cumulative allocation: B2 / TS')
    right.set_title('Allocation measured in separate processes', loc='left', fontsize=12)
    right.tick_params(axis='y', left=False)
    right.grid(axis='x', alpha=.2)
    right.set_axisbelow(True)
    for pos, ratio in zip(positions, allocation):
        right.text(ratio+.03, pos, f'{ratio:.2f}×', va='center', fontsize=9)
    for axis in (left, right):
        axis.spines[['top', 'right']].set_visible(False)
    fig.suptitle('Phase62: current State08 B2 versus pinned TypeScript, 23 compilation inputs', fontsize=15, x=.02, ha='left', y=.985)
    fig.text(.02, .027, 'One fresh first request per role/input/profile mode; prepared Base cache. CPU 1 ms; allocation 128 KiB including collected objects.\n'
        'Each CPU leaf is counted once. Broad groups combine distinct compiler boundaries; TS backend passes are not asserted identical to Bend passes.\n'
        'Inspector/GC/residual remain visible. These profiles diagnose work; their durations and allocation ratios are not clean speed ratios.', fontsize=9)
    fig.subplots_adjust(left=.195, right=.98, top=.94, bottom=.14, wspace=.09)
    out = a.out.resolve()
    assert not out.exists() and '/selfhost/build/phase62/' in str(out)
    out.mkdir(parents=True)
    outputs = []
    for suffix in ['svg', 'png']:
        file = out/f'cpu-allocation.{suffix}'
        fig.savefig(file, dpi=150)
        outputs.append(identity(file))
    plt.close(fig)
    assert identity(a.analysis) == source
    result = dict(kind='phase62-profile-figure', complete=True, source=source, producer=identity(__file__),
        outputs=outputs, groups={k: sorted(v) for k, v in GROUPS.items()}, allocation=details,
        scope='Saved data only; CPU sample-count shares, independent sampled cumulative allocation ratios; no compiler execution')
    result['pass'] = True
    (out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(out), figures=outputs)))


if __name__ == '__main__':
    main()
