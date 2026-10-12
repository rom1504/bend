#!/usr/bin/env python3
"""Plot the retained measured02 runtime dataset; no compiler/target execution."""
import argparse
import hashlib
import json
import os
from pathlib import Path

os.environ.setdefault('MPLCONFIGDIR', '/tmp/phase70-native-runtime-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--data', type=Path, default=Path(__file__).with_name('native-runtime-results.json'))
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--preview', type=Path)
args = parser.parse_args()
data = json.loads(args.data.read_text())
assert data['kind'] == 'phase70-compiler02-native-runtime-checkpoint'
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 11,
    'svg.fonttype': 'none', 'svg.hashsalt': 'phase70-native-runtime-measured02'})
old, current = '#8391A2', '#007F73'
fig, axes = plt.subplots(1, 2, figsize=(15.2, 6.4), sharex=True)
fig.subplots_adjust(left=.08, right=.975, bottom=.20, top=.76, wspace=.36)
labels = {'list-pipeline': 'List pipeline', 'bst': 'BST *', 'expression': 'Expression *',
    'array-map': 'Array map', 'tape-observer': 'Tape observer', 'string-order': 'String ordering'}
panels = [('originalSix', 'Original six families'), ('sixAdditions', 'Six additions')]
for ax, (key, title) in zip(axes, panels):
    rows = data['campaigns'][key]['rows']
    assert len(rows) == 6
    positions = list(range(6))
    before = [row['baselineOverUpstream'] for row in rows]
    after = [row['candidateOverUpstream'] for row in rows]
    ax.barh([y-.17 for y in positions], before, height=.28, color=old, zorder=3)
    ax.barh([y+.17 for y in positions], after, height=.28, color=current, zorder=3)
    for y, a, b in zip(positions, before, after):
        box = {'facecolor': 'white', 'edgecolor': 'none', 'pad': .4}
        ax.text(a+.05, y-.17, f'{a:.3f}×', va='center', color='#506072', fontsize=10, bbox=box, zorder=6)
        ax.text(b+.05, y+.17, f'{b:.3f}×', va='center', color='#00675D', fontsize=10, bbox=box, zorder=6)
    ax.set_yticks(positions, [labels.get(row['case'], row['case'].capitalize()) for row in rows])
    ax.invert_yaxis()
    ax.set_xlim(0, 4.25)
    ax.set_xticks([0, 1, 2, 3, 4], ['0', '1×', '2×', '3×', '4×'])
    ax.axvline(1, color='#263548', linewidth=1.25, linestyle=(0, (4, 3)), zorder=4)
    ax.grid(axis='x', color='#E4E8ED', linewidth=.8, zorder=0)
    ax.tick_params(axis='both', length=0, pad=7)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.set_title(title, loc='left', fontweight='bold', fontsize=13, pad=14)
    ax.set_xlabel('Execution time / upstream · lower is better', labelpad=13)
fig.text(.08, .94, 'Bend native program runtime vs upstream', fontsize=20, fontweight='bold', color='#172434')
fig.text(.08, .892, 'B1-emitted C · Clang · paired same-campaign medians · measured compiler02 dataset',
         fontsize=11.5, color='#506072')
fig.legend(handles=[Patch(color=old, label='Phase69 B1'), Patch(color=current, label='Measured compiler02 B1')],
           loc='upper left', bbox_to_anchor=(.075, .865), ncol=2, frameon=False)
fig.text(.08, .093, 'Dashed line: upstream = 1×. Shared scale; all twelve families retained. Three rotated rounds per role.',
         fontsize=10, color='#506072')
fig.text(.08, .058, '* Native performance holdouts; source and prior JavaScript history were known. Stability-repeat samples are excluded.',
         fontsize=9.5, color='#506072')
sha = hashlib.sha256(args.data.read_bytes()).hexdigest()
fig.savefig(args.out, format='svg', metadata={'Date': None,
    'Title': 'Phase70 measured compiler02 native runtime comparison',
    'Description': 'Two separate six-family datasets. Source summary SHA-256 '+sha+'. No compiler03 or promotion claim.'})
if args.preview:
    fig.savefig(args.preview, dpi=130)
plt.close(fig)
print(json.dumps({'output': str(args.out), 'sourceSha256': sha, 'families': 12, 'targetsExecuted': False}))
