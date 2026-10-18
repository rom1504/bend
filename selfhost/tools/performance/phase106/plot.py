#!/usr/bin/env python3
"""Render measured Phase106 backend tradeoffs; no target execution."""
import argparse
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--analysis', type=Path, required=True)
p.add_argument('--confirmation', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
data = json.loads(a.analysis.read_text())
confirmation = json.loads(a.confirmation.read_text())
assert data['complete'] and confirmation['complete']
names = list(data['table'])
y = np.arange(len(names))
fig, axes = plt.subplots(1, 3, figsize=(14, 5), gridspec_kw={'width_ratios': [1.2, 1.2, 1]})
colors = ['#235789', '#da7b23']
for index, (policy, label) in enumerate([('c-o2', 'Clang O2'), ('cl-size', 'Cranelift size')]):
    build = [1000 * sum(data['table'][n][policy][k]['median'] for k in
                        ['emissionSeconds', 'compileSeconds', 'linkSeconds']) for n in names]
    run = [1000 * data['table'][n][policy]['executeSeconds']['median'] for n in names]
    for ax, values in zip(axes[:2], [build, run]):
        ax.barh(y + (index - .5) * .32, values, height=.30, color=colors[index], label=label)
for ax, title in zip(axes[:2], ['Construct executable', 'Execute checked batch']):
    ax.set_yticks(y, names)
    ax.invert_yaxis()
    ax.set_title(title)
    ax.set_xlabel('Milliseconds (log scale; lower is better)')
    ax.set_xscale('log')
    ax.grid(axis='x', alpha=.18)
axes[0].legend(frameon=False, fontsize=9)
names2 = list(confirmation['summary']['table'])
ratios = []
for name in names2:
    t = confirmation['summary']['table'][name]
    sums = {policy: sum(s['oneShotK1CostSeconds'] for s in t[policy]['sizes'].values())
            for policy in ['c-o2', 'cl-size']}
    ratios.append(sums['cl-size'] / sums['c-o2'])
axes[2].barh(np.arange(len(names2)), ratios, color=colors[1], height=.5)
axes[2].set_yticks(np.arange(len(names2)), names2)
axes[2].invert_yaxis()
axes[2].axvline(1, color=colors[0], linestyle='--', linewidth=1)
axes[2].set_xlim(0, 1.12)
axes[2].set_title('Fresh one-shot confirmation')
axes[2].set_xlabel('Build + checked run / Clang O2')
for i, value in enumerate(ratios):
    axes[2].text(value + .025, i, f'{value:.2f}×', va='center')
axes[2].text(.98, .96, 'Clang O2 = 1', transform=axes[2].transAxes,
             ha='right', va='top', fontsize=9, color=colors[0])
fig.suptitle('Native IR prototype: faster construction trades against execution speed', fontsize=14)
fig.text(.5, .02, 'Three rounds, CPU3. Left/middle: fixed workload-specific batches. Right: two fresh sizes, one call per run.\n'
         'Directly constructed IR; these are not full-compiler speedups. Shared tool acquisition is excluded.',
         ha='center', fontsize=9)
fig.tight_layout(rect=[0, .10, 1, .94])
a.out.mkdir(parents=True, exist_ok=True)
for suffix in ['png', 'svg']:
    fig.savefig(a.out / ('backend-tradeoffs.' + suffix), dpi=160)
svg = a.out / 'backend-tradeoffs.svg'
svg.write_text('\n'.join(line.rstrip() for line in svg.read_text().splitlines()) + '\n')
