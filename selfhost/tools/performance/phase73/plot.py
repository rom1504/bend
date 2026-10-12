#!/usr/bin/env python3
"""Plot the selected finite runtime comparison; no benchmark execution."""
import json, os
from pathlib import Path
os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase73-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / 'implementation/phase73'
data = json.loads((OUT / 'measurements.json').read_text())
rows = data['runtime']
names = {'numeric': 'Numeric', 'array': 'Array', 'closures': 'Closures',
         'tree': 'Tree', 'map': 'Map', 'lexer': 'Lexer',
         'list-pipeline': 'List pipeline', 'bst': 'BST',
         'expression': 'Expression AST', 'array-map': 'Array.map',
         'tape-observer': 'Tape observer', 'string-order': 'String order'}
old = [r['mediansMs']['baseline72'] / r['mediansMs']['upstream'] for r in rows]
new = [r['candidateOverUpstream'] for r in rows]
fig, ax = plt.subplots(figsize=(9, 7.5), layout='constrained')
y = list(range(len(rows)))
ax.barh([v - .19 for v in y], old, height=.34, color='#a5acb5', label='Phase72')
ax.barh([v + .19 for v in y], new, height=.34, color='#177b8b', label='Phase73')
for i, value in enumerate(new):
    ax.text(value + .04, i + .19, f'{value:.2f}x', va='center', fontsize=9)
ax.set_yticks(y, [names[r['case']] for r in rows])
ax.invert_yaxis()
ax.axvline(1, color='#404040', linestyle='--', linewidth=1)
ax.set_xlabel('Execution time / upstream C output (lower is faster)')
ax.set_title('C execution: 1.37x → 1.05x equal-family geometric mean\n'
             '12 fixed families · six rotated rounds · one worker', loc='left')
ax.set_xlim(0, max(old + new) + .25)
ax.legend(loc='lower right')
ax.spines[['top', 'right']].set_visible(False)
ax.grid(axis='x', alpha=.15)
ax.set_axisbelow(True)
dest = OUT / 'runtime.svg'
assert not dest.exists()
fig.savefig(dest, metadata={'Date': None})
print(dest)
