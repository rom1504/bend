#!/usr/bin/env python3
"""Plot the committed Phase112 broad result table; no target execution."""
import csv
import os
from pathlib import Path

os.environ.setdefault('MPLCONFIGDIR', '/tmp/phase112-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[4]
REPORT = ROOT / 'implementation/phase112'
rows = list(csv.DictReader((REPORT / 'broad-runtime.csv').open()))
rows = [r for r in rows if r['facts_upstream_ratio']]
assert len(rows) == 44
rows.sort(key=lambda r: float(r['facts_upstream_ratio']))
plt.rcParams.update({'font.size': 9, 'svg.hashsalt': 'phase112-results-v1'})
fig, ax = plt.subplots(figsize=(11, 15))
fig.subplots_adjust(left=.37, right=.97, top=.91, bottom=.08)
for y, row in enumerate(rows):
    a, b = float(row['word_upstream_ratio']), float(row['facts_upstream_ratio'])
    ax.plot([a, b], [y, y], color='#b5c1ca', linewidth=1.5, zorder=1)
ax.scatter([float(r['word_upstream_ratio']) for r in rows], range(44),
           s=26, color='#b5662f', label='Word checkpoint', zorder=2)
ax.scatter([float(r['facts_upstream_ratio']) for r in rows], range(44),
           s=26, color='#007d91', label='Final facts', zorder=3)
ax.axvline(1, color='#353b40', linestyle='--', linewidth=1)
ax.set_xscale('log')
ax.set_xlim(.85, 220)
ax.set_xticks([1, 2, 5, 10, 20, 50, 100, 200],
              labels=['1×', '2×', '5×', '10×', '20×', '50×', '100×', '200×'])
ax.set_yticks(range(44), labels=[r['program'] for r in rows])
ax.set_ylim(-1, 44)
ax.grid(axis='x', color='#e3e7e9', linewidth=.6)
ax.set_axisbelow(True)
ax.set_xlabel('Runtime / pinned upstream C program (log scale; lower is faster)')
ax.legend(loc='lower right', frameon=False)
for side in ['top', 'right', 'left']:
    ax.spines[side].set_visible(False)
ax.tick_params(axis='y', length=0)
fig.suptitle('Direct QBE: gains across the full timed corpus', x=.37, y=.966,
             ha='left', fontsize=16, fontweight='bold')
fig.text(.37, .932, 'Geometric mean: 24.87× → 15.94× upstream runtime\n'
         'All 45 programs pass; the zero-work control is excluded from ratios.', fontsize=10)
fig.text(.03, .025, 'Three-round medians; same frozen sources, repetition profile and toolchain. Word and facts are separate controlled campaigns.\n'
         '44 points represent 23 historical families. No confidence interval or universal speed guarantee is inferred.', fontsize=8)
output = REPORT / 'broad-runtime.svg'
if output.exists():
    raise FileExistsError('Use a fresh output or explicitly review regeneration: ' + str(output))
fig.savefig(output, format='svg', metadata={'Date': None, 'Creator': 'Phase112 plot-results.py / Matplotlib'})
print(output)
