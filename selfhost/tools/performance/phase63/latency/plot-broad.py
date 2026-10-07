#!/usr/bin/env python3
"""Plot an already admitted compact broad summary; runs no compiler or benchmarks."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path

os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase63-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def identity(path):
    path = Path(path).resolve(strict=True)
    return dict(file=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('summary', type=Path)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--candidate', required=True)
p.add_argument('--baseline', default='Phase61 State08')
a = p.parse_args()
receipt = a.out.with_suffix('.svg.json')
assert a.out.suffix == '.svg' and not a.out.exists() and not receipt.exists()
d = json.loads(a.summary.read_text())
assert d['kind'] == 'phase63-balanced-b2-broad-summary' and d['pass_']
assert d['workers'] == 207 and d['sourceCount'] == 23 and d['rounds'] == 3
assert identity(d['report']['file']) == d['report']
names = d['matrixColumns']
rows = [dict(zip(names, row)) for row in d['matrix']]
rows.sort(key=lambda r:r['firstRequestMs:candidate']/r['firstRequestMs:typescript'], reverse=True)
plt.rcParams.update({'font.family':'DejaVu Sans', 'font.size':10, 'svg.fonttype':'none',
                     'svg.hashsalt':'bend-phase63-broad'})
fig, axes = plt.subplots(1, 2, figsize=(12.8, 10.8), sharey=True)
colors = ['#86919c', '#086bb5']
clocks = [('firstRequestMs','Compilation'), ('importApiAndFirstMs','Imports + API + compilation')]
labels = [r['source'] for r in rows] + ['Geometric mean']
for ax,(clock,title) in zip(axes,clocks):
    old = [r[clock+':baseline']/r[clock+':typescript'] for r in rows]
    new = [r[clock+':candidate']/r[clock+':typescript'] for r in rows]
    summary = d['summary'][clock]
    old.append(summary['baseline/typescript']['geometricMean'])
    new.append(summary['candidate/typescript']['geometricMean'])
    for y,(before,after) in enumerate(zip(old,new)):
        ax.plot([after,before],[y,y],color='#c5cbd1',lw=2,zorder=1)
    ax.scatter(old,range(len(labels)),color=colors[0],s=32,label=a.baseline,zorder=2)
    ax.scatter(new,range(len(labels)),color=colors[1],s=38,label=a.candidate,zorder=3)
    ax.axvline(1,color='#333333',ls='--',lw=1,label='TypeScript = 1×')
    ax.axhline(len(rows)-0.5,color='#9aa2a9',lw=.7)
    ax.set_xlim(0.5,math.ceil((max(old+new)+.08)*4)/4)
    ax.set_title(title+'\nGM: '+format(old[-1],'.3f')+'× → '+format(new[-1],'.3f')+'×',fontsize=12,pad=13)
    ax.set_xlabel('Time relative to pinned TypeScript (lower is faster)')
    ax.set_yticks(range(len(labels)),labels)
    ax.grid(axis='x',alpha=.17)
    ax.spines[['top','right','left']].set_visible(False)
    ax.tick_params(axis='y',length=0)
axes[0].invert_yaxis()
fig.suptitle('Fresh-process Bend compiler performance across 23 sources',fontsize=17,y=.979)
fig.text(.5,.938,'3 samples per source and role · median per point · prepared caches · 207/207 raw-output checks pass',ha='center',fontsize=10)
handles,legend_labels=axes[0].get_legend_handles_labels()
fig.legend(handles,legend_labels,loc='lower center',bbox_to_anchor=(.57,.022),ncol=3,frameon=False)
fig.text(.5,.011,'Compilation measurements, not execution speed of generated programs. No significance claim from three samples.',ha='center',fontsize=9,color='#50575e')
fig.subplots_adjust(left=.245,right=.975,bottom=.095,top=.875,wspace=.14)
a.out.parent.mkdir(parents=True,exist_ok=True)
fig.savefig(a.out,format='svg',metadata={'Date':None,'Creator':'Phase63 plot-broad.py',
    'Description':'Data-only figure from '+str(a.summary)+'; raw report SHA256 '+d['report']['sha256']})
plt.close(fig)
record=dict(kind='phase63-broad-figure',dataOnly=True,targetExecuted=False,producer=identity(__file__),
            summary=identity(a.summary),rawReport=d['report'],image=identity(a.out),
            labels=dict(candidate=a.candidate,baseline=a.baseline),matplotlib=matplotlib.__version__)
with receipt.open('x') as stream:stream.write(json.dumps(record,indent=2)+'\n')
print(json.dumps(dict(image=record['image'],receipt=identity(receipt))))
