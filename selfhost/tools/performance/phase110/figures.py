#!/usr/bin/env python3
"""Render Phase110 figures from saved receipts; executes no compiler or worker."""
import argparse
import hashlib
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT / 'implementation/phase110'):
    raise ValueError('fresh Phase110 report output required')
out.mkdir()
build = ROOT / 'selfhost/build/phase110'
paths = [build / n for n in ['final-selection02.json', 'final-heldout01/report.json',
         'production-compare01/report.json', 'loop-relink01/fused-qbe-accounting.json']]
selection, heldout, production, loop = [json.loads(f.read_text()) for f in paths]
assert all(d['complete'] for d in [selection, heldout, production, loop])
assert selection['selectionFrozen'] and heldout['evaluationOnly']
pin = lambda f: dict(file=str(f.relative_to(ROOT)), bytes=f.stat().st_size,
                    sha256=hashlib.sha256(f.read_bytes()).hexdigest())
plt.rcParams.update({'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False})
blue, orange = '#206a9f', '#b35806'
names = ['compact-general-qbe', 'wrapper-spare-clang']
fig, axes = plt.subplots(1, 2, figsize=(11, 4.5), gridspec_kw={'width_ratios': [1.6, 1]})
labels = ['Selected QBE\ntraining', 'Selected QBE\nfresh held-out',
          'Clang control\ntraining', 'Clang control\nfresh held-out']
values = [selection['referenceRatios'][names[0]]['ratio'], heldout['comparisons'][names[0]]['ratio'],
          selection['referenceRatios'][names[1]]['ratio'], heldout['comparisons'][names[1]]['ratio']]
axes[0].bar(range(4), values, color=[blue, blue, orange, orange])
axes[0].set_xticks(range(4), labels)
axes[0].set_title('Reverse workloads: common fused-QBE baseline')
axes[0].set_ylabel('Worker time / baseline time (lower is better)')
axes[0].axhline(1, color='gray', linestyle='--', linewidth=1)
axes[0].set_ylim(0, 1.12)
for i, v in enumerate(values): axes[0].text(i, v + .025, f'{v:.3f}×', ha='center')
v = production['ratio']
axes[1].bar([0, 1], [1, v], color=['#888888', blue])
axes[1].set_xticks([0, 1], ['Production\nClang', 'Selected\ndirect QBE'])
axes[1].set_title('Separate matched 65,536-cell kernel')
axes[1].set_ylabel('Worker time / production Clang time')
axes[1].set_ylim(0, 1.12)
axes[1].text(1, v + .025, f'{v:.3f}×', ha='center')
fig.suptitle('Phase110: separate experiments and denominators', fontweight='bold')
fig.text(.5, .01, 'Kernel clocks exclude setup, checking and release. These are not full-compiler or upstream ratios.', ha='center', fontsize=9)
fig.tight_layout(rect=[0, .05, 1, .95])
fig.savefig(out / 'performance.svg'); fig.savefig(out / 'performance.png', dpi=160); plt.close(fig)

labels = ['List unique', 'List root shared', 'List tail shared', 'List head shared',
          'String unique', 'String root shared', 'String tail shared',
          'Parser list unique', 'Parser list tail shared', 'Checker string unique', 'Checker string shared']
cases = heldout['cases']
assert len(cases) == len(labels)
fig, ax = plt.subplots(figsize=(10, 6.5))
for shift, name, color, label in [(-.18, names[0], blue, 'Selected QBE'), (.18, names[1], orange, 'Clang control')]:
    vals = [heldout['comparisons'][name]['caseRatios'][case] for case in cases]
    ax.barh([i + shift for i in range(len(cases))], vals, height=.34, color=color, label=label)
ax.set_yticks(range(len(cases)), labels); ax.invert_yaxis()
ax.axvline(1, color='gray', linestyle='--', linewidth=1)
ax.set_xlabel('Worker time / unchanged fused-QBE time (lower is better)')
ax.set_title('Eleven fresh held-out inputs; policies frozen before execution')
ax.legend(loc='lower right'); ax.set_xlim(0, 1.12)
fig.tight_layout(); fig.savefig(out / 'heldout.svg'); plt.close(fig)

phases = loop['phasesNanoseconds']
keys = ['observation', 'resultAndAliasDrop', 'setup', 'liveAccountingAndClose', 'workerEnvelope']
labels = ['Independent observation', 'Release result and aliases', 'Graph and alias setup', 'Lifetime accounting / close', 'Worker execution envelope']
vals = [100 * phases[k] / loop['outerNanoseconds'] for k in keys]
fig, ax = plt.subplots(figsize=(10, 3.8))
ax.barh(range(len(vals)), vals, color=['#888888'] * 4 + [blue])
ax.set_yticks(range(len(vals)), labels); ax.invert_yaxis(); ax.set_xlim(0, 60)
for i, v in enumerate(vals): ax.text(v + .4, i, f'{v:.2f}%', va='center')
ax.set_xlabel('Share of one diagnostic evaluation run')
ax.set_title('Faster workers alone barely shorten this research loop')
fig.tight_layout(); fig.savefig(out / 'research-loop.svg'); plt.close(fig)
for svg in out.glob('*.svg'):
    svg.write_text('\n'.join(line.rstrip() for line in svg.read_text().splitlines()) + '\n')
report = dict(kind='phase110-figures', complete=True, inputs=[pin(Path(__file__)), *map(pin, paths)],
              outputs=[pin(f) for f in sorted(out.iterdir())],
              scope='Rendered from saved measurements; no new target execution, selection or statistical inference.')
(out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(complete=True, files=len(report['outputs']))))
