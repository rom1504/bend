#!/usr/bin/env python3
"""Plot a verified Phase65 broad B2 summary; no compiler or benchmark execution."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import statistics


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def verify(item):
    actual = identity(item['file'])
    assert actual['sha256'] == item['sha256'], item['file']
    return actual


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--summary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--candidate', required=True)
p.add_argument('--baseline', default='Phase64 State09 B2')
a = p.parse_args()
receipt = a.out.with_suffix('.svg.json')
assert a.out.suffix == '.svg' and not a.out.exists() and not receipt.exists()
d = json.loads(a.summary.read_text())
assert d['kind'] == 'phase65-clean-latency-summary' and d['complete'] and d['pass']
assert d['dataOnly'] and not d['targetExecuted']
assert d['sourceCount'] == 23 and d['rounds'] >= 3
assert set(d['roles']) == {'baseline', 'candidate', 'typescript'}
workers = 23 * 3 * d['rounds']
assert d['successfulWorkers'] == d['exactRawOutputs'] == workers
raw = verify(d['report'])
verify(d['config'])
for role in ['baseline', 'candidate']:
    image = d['images'][role]
    assert image['kind'] == 'direct' and image['strictExact']
    assert image['diagnosticDerivation'] is None
    for field in ['api', 'source', 'emission', 'checkedGenerator']:
        verify(image[field])

clocks = [('firstRequestMs', 'Compilation'),
          ('importApiAndFirstMs', 'Host/API imports + compilation')]
rows = d['sources']
assert len(rows) == len({row['case'] for row in rows}) == 23
for row in rows:
    assert set(row['roles']) == set(d['roles'])
    for role in d['roles']:
        for clock, _ in clocks:
            metric = row['roles'][role][clock]
            assert len(metric['samples']) == d['rounds']
            assert all(math.isfinite(v) and v > 0 for v in metric['samples'])
            assert math.isclose(metric['median'], statistics.median(metric['samples']), rel_tol=1e-12)
    for numerator, denominator in [('baseline', 'typescript'),
                                   ('candidate', 'typescript'),
                                   ('candidate', 'baseline')]:
        pair = numerator + '/' + denominator
        for clock, _ in clocks:
            ratio = row['roles'][numerator][clock]['median'] / row['roles'][denominator][clock]['median']
            assert math.isclose(row['ratios'][pair][clock], ratio, rel_tol=1e-12)
for pair in ['baseline/typescript', 'candidate/typescript', 'candidate/baseline']:
    for clock, _ in clocks:
        values = [row['ratios'][pair][clock] for row in rows]
        mean = math.exp(statistics.mean(map(math.log, values)))
        assert math.isclose(d['aggregate'][pair][clock]['geometricMean'], mean, rel_tol=1e-12)
        assert d['aggregate'][pair][clock]['sources'] == 23

# Delay plotting imports until after rejecting incomplete, B1 or changed inputs.
os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase65-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

rows = sorted(rows, key=lambda row: row['ratios']['candidate/typescript']['firstRequestMs'], reverse=True)
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10,
                     'svg.fonttype': 'none', 'svg.hashsalt': 'bend-phase65-broad'})
fig, axes = plt.subplots(1, 2, figsize=(13.2, 10.8), sharey=True)
labels = [row['case'] for row in rows] + ['Equal-source geometric mean']
for ax, (clock, title) in zip(axes, clocks):
    old = [row['ratios']['baseline/typescript'][clock] for row in rows]
    new = [row['ratios']['candidate/typescript'][clock] for row in rows]
    old.append(d['aggregate']['baseline/typescript'][clock]['geometricMean'])
    new.append(d['aggregate']['candidate/typescript'][clock]['geometricMean'])
    for y, (before, after) in enumerate(zip(old, new)):
        ax.plot([before, after], [y, y], color='#c7ced4', lw=2, zorder=1)
    ax.scatter(old, range(len(labels)), color='#7e8c99', s=32, label=a.baseline, zorder=2)
    ax.scatter(new, range(len(labels)), color='#086bb5', s=38, label=a.candidate, zorder=3)
    ax.axvline(1, color='#333333', ls='--', lw=1, label='TypeScript = 1×')
    ax.axhline(len(rows)-0.5, color='#9aa2a9', lw=.7)
    ax.set_xlim(max(0, min(old+new+[1])-.12), max(old+new+[1])+.12)
    ax.set_title(f'{title}\nGeometric mean: {old[-1]:.3f}× → {new[-1]:.3f}×', fontsize=12, pad=13)
    ax.set_xlabel('Time / pinned TypeScript time (lower is faster)')
    ax.set_yticks(range(len(labels)), labels)
    ax.grid(axis='x', alpha=.17)
    ax.spines[['top', 'right', 'left']].set_visible(False)
    ax.tick_params(axis='y', length=0)
axes[0].invert_yaxis()
fig.suptitle('Bend compiler performance across 23 sources', fontsize=17, y=.979)
fig.text(.5, .938, f"{d['rounds']} fresh processes per source and role · medians · prepared caches · {workers}/{workers} exact output checks", ha='center', fontsize=10)
handles, legend_labels = axes[0].get_legend_handles_labels()
fig.legend(handles, legend_labels, loc='lower center', bbox_to_anchor=(.59, .024), ncol=3, frameon=False)
fig.text(.5, .012, 'Compilation time, not generated-program execution. Medians show descriptive results, not confidence intervals.', ha='center', fontsize=9, color='#50575e')
fig.subplots_adjust(left=.25, right=.975, bottom=.10, top=.875, wspace=.15)
a.out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(a.out, format='svg', metadata={'Date': None, 'Creator': 'Phase65 plot-broad.py',
    'Description': 'Data-only figure; source summary SHA256 ' + identity(a.summary)['sha256']})
plt.close(fig)
# Matplotlib may emit trailing spaces; keep the reviewable SVG whitespace clean.
a.out.write_text('\n'.join(line.rstrip() for line in a.out.read_text().splitlines())+'\n')
record = dict(kind='phase65-broad-figure', dataOnly=True, targetExecuted=False,
              producer=identity(__file__), summary=identity(a.summary), rawReport=raw,
              image=identity(a.out), matplotlib=matplotlib.__version__,
              labels=dict(candidate=a.candidate, baseline=a.baseline),
              scope='Same-campaign median compilation ratios; no program-execution or release-qualification claim.')
with receipt.open('x') as stream:
    stream.write(json.dumps(record, indent=2)+'\n')
print(json.dumps(dict(image=record['image'], receipt=identity(receipt))))
