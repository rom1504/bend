#!/usr/bin/env python3
"""Plot audited generation medians or later-request trajectories; data only."""
import argparse
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('summary', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
d = json.loads(a.summary.read_text())
assert d['complete'] and d['pass']
assert not a.out.with_suffix('.svg').exists() and not a.out.with_suffix('.png').exists()
labels = {'numeric-recurrence': 'Numeric recurrence', 'test-map-set-ops': 'MapSet',
          'lexer': 'Lexer', 'raytrace-active': 'Active raytrace'}
colors = {'b1': '#777777', 'b2': '#2369a6', 'typescript': '#26834b'}
names = {'b1': 'B1 (equality profile)', 'b2': 'B2 (self emitted)', 'typescript': 'TypeScript'}
plt.rcParams.update({'font.size': 10, 'svg.fonttype': 'none'})
if not d['warmRequests']:
    fig, ax = plt.subplots(figsize=(9, 5.5))
    width = 0.24
    for j, role in enumerate(d['roles']):
        values = [row['roles'][role]['firstRequestMs']['median'] for row in d['cases']]
        bars = ax.barh([i + (j - 1) * width for i in range(len(values))], values,
                       height=width, color=colors[role], label=names[role])
        ax.bar_label(bars, labels=[f'{v:,.1f}' for v in values], padding=4, fontsize=9)
    ax.set_yticks(range(len(d['cases'])), [labels[row['case']] for row in d['cases']])
    ax.invert_yaxis()
    ax.set_xlim(0, ax.get_xlim()[1] * 1.11)
    ax.set_xlabel('First compilation after API load (ms; lower is faster)')
    ax.legend(loc='lower right', frameon=False)
    ax.set_title('Same State08 Bend source: B1 versus B2, with pinned TS reference', loc='left', pad=16)
    fig.text(0.02, 0.018, '4 inputs × 3 balanced rounds × 3 roles; 36 fresh processes. '
             'Prepared Base caches. Full output bytes verified.', fontsize=9)
    axes = [ax]
else:
    fig, axes = plt.subplots(2, 2, figsize=(10, 7), sharex=True)
    for ax, row in zip(axes.flat, d['cases']):
        keys = ['firstRequestMs', *[f'laterRequest{i + 1}Ms' for i in range(d['warmRequests'])]]
        for role in d['roles']:
            values = [row['roles'][role][key]['median'] for key in keys]
            ax.plot(range(len(keys)), values, marker='o', color=colors[role], label=names[role])
            for x, y in enumerate(values):
                ax.annotate(f'{y:.0f}', (x, y), xytext=(3, 5), textcoords='offset points',
                            fontsize=8, color=colors[role])
        ax.set_title(labels[row['case']], loc='left')
        ax.set_ylabel('Compilation time (ms)')
        ax.set_xticks(range(len(keys)), ['First', *[f'Later {i + 1}' for i in range(d['warmRequests'])]])
        ax.set_ylim(bottom=0)
    axes.flat[0].legend(frameon=False)
    fig.suptitle('Same-process request trajectories: B2 and pinned TypeScript', x=0.04, ha='left')
    fig.text(0.04, 0.015, f'{d["rounds"]} fresh processes per role/input; medians at each request index. '
             'Prepared Base caches. No steady-state plateau claim.', fontsize=9)
    axes = list(axes.flat)
for ax in axes:
    ax.spines[['top', 'right']].set_visible(False)
    ax.grid(axis='x' if not d['warmRequests'] else 'y', alpha=0.15)
    ax.set_axisbelow(True)
fig.tight_layout(rect=(0, 0.04, 1, 0.98 if not d['warmRequests'] else 0.96))
a.out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(a.out.with_suffix('.svg'))
fig.savefig(a.out.with_suffix('.png'), dpi=150)
plt.close(fig)
print(a.out.with_suffix('.svg'))
