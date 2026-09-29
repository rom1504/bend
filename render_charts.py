#!/usr/bin/env python3
"""Render the published PR1207 report figures from source-linked chart-data.json."""
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter

HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / 'chart-data.json').read_text())
OUT = HERE / 'figures'
OUT.mkdir(exist_ok=True)
BLUE, TEAL, ORANGE, GRAY = '#2458a6', '#087f75', '#bb5b22', '#566376'
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10,
    'axes.spines.top': False, 'axes.spines.right': False,
    'axes.titleweight': 'bold', 'axes.labelcolor': '#25344a',
    'text.color': '#17263b', 'axes.edgecolor': '#ccd3dc',
    'figure.facecolor': 'white', 'axes.facecolor': 'white',
    'svg.fonttype': 'none', 'savefig.facecolor': 'white'})

def save(fig, name):
    for ext in ['png', 'svg', 'pdf']:
        fig.savefig(OUT / f'{name}.{ext}', dpi=160, bbox_inches='tight')

def style(ax):
    ax.grid(axis='y', color='#e7ebf1', linewidth=.7)
    ax.set_axisbelow(True)
    ax.tick_params(axis='both', length=0, pad=7)

def speed(ax):
    rows = DATA['checking']
    xs = np.arange(len(rows))
    vals = [r['ratio'] for r in rows]
    colors = [BLUE if r['upstream'].startswith('b2111') else TEAL for r in rows]
    for x,r,color in zip(xs,rows,colors):
        if r['baseline_ratio'] is not None:
            ax.vlines(x, r['ratio'], r['baseline_ratio'], colors=color, linewidth=2, alpha=.6)
            ax.scatter([x],[r['baseline_ratio']],facecolors='white',edgecolors=GRAY,s=45,zorder=2)
    ax.scatter(xs, vals, c=colors, s=48, zorder=3)
    for x, y in zip(xs, vals):
        ax.annotate(f'{y:.2f}×', (x, y), xytext=(0, 8), textcoords='offset points',
                    ha='center', fontsize=9, weight='bold')
    ax.axhline(1, color=GRAY, linestyle=':', linewidth=1)
    ax.set_yscale('log')
    ax.set_ylim(.85, 130)
    ax.set_yticks([1, 3, 10, 30, 100], ['1×', '3×', '10×', '30×', '100×'])
    ax.set_xticks(xs, [f"P{r['phase']}\n{r['commit'][:7]}" for r in rows], fontsize=8)
    ax.set_ylabel('Compiler process time / paired TypeScript time\nLower is better · logarithmic scale')
    ax.set_title('1  Compiler checking cost: progressively less work', loc='left', pad=15)
    ax.text(0, 1.015, 'Filled = release; hollow = predecessor on the same input. Separate checking-only windows; sources evolve.',
            transform=ax.transAxes, fontsize=9, color=GRAY)
    split = next((i for i,r in enumerate(rows) if not r['upstream'].startswith('b2111')), None)
    if split is not None:
        ax.axvline(split-.5, color=GRAY, ls='--', lw=.8)
        ax.text(split-.42, 80, 'New pin', fontsize=8, color=TEAL)
    ax.set_xlim(-.6, len(rows)-.4)
    style(ax)

def conformance(ax):
    rows = DATA['conformance']
    xs = np.arange(len(rows))
    targets = list(dict.fromkeys(r['upstream'] for r in rows))
    for target, color in zip(targets, [ORANGE, BLUE, TEAL]):
        inds = [i for i,r in enumerate(rows) if r['upstream']==target]
        vals = [rows[i]['different'] for i in inds]
        ax.plot(inds, vals, color=color, marker='o', linewidth=2, markersize=6)
        first, last = inds[0], inds[-1]
        ax.text((first+last)/2, 2700, f"{rows[first]['total']:,} comparisons · {target[:7]}",
                ha='center', fontsize=8, color=color)
        if first:
            ax.axvline(first-.5, color=GRAY, ls='--', lw=.8)
    for x,r in zip(xs, rows):
        ax.annotate(f"{r['different']:,}", (x, r['different']), xytext=(0, 8),
                    textcoords='offset points', ha='center', fontsize=9, weight='bold')
    ax.set_yscale('symlog', linthresh=3)
    ax.set_ylim(-1.4, 4500)
    ax.set_yticks([0, 2, 10, 100, 1000], ['0', '2', '10', '100', '1,000'])
    ax.set_xticks(xs, [f"{r['label']}\n{r['commit'][:7]}" for r in rows], fontsize=8)
    ax.set_ylabel('Remaining exact frontend differences\nLower is better · symlog scale')
    ax.set_title('2  Conformance: exact agreement within each pinned frontend suite', loc='left', pad=15)
    ax.text(0, 1.015, 'Pin/suite changes break the line. Zero differences is finite tested agreement, not universal conformance.',
            transform=ax.transAxes, fontsize=9, color=GRAY)
    ax.set_xlim(-.6, len(rows)-.4)
    style(ax)

def complexity(ax):
    rows = DATA['complexity']
    xs = np.arange(len(rows))
    vals = [r['physicalLines'] for r in rows]
    ax.plot(xs, vals, color=BLUE, marker='o', lw=2, label='Physical lines')
    ax.plot(xs, [r['nonblankLines'] for r in rows], color=TEAL, marker='.', lw=1.5,
            label='Nonblank lines')
    for x,y in zip(xs, vals):
        ax.annotate(f'{y:,}', (x,y), xytext=(0,9), textcoords='offset points',
                    ha='center', fontsize=9, weight='bold')
    baseline = DATA['complexity_baseline']['physicalLines']
    ax.axhline(baseline*.5, color=ORANGE, ls=':', lw=1)
    ax.text(.05, baseline*.5+300, 'Original 50% reduction target: not achieved', color=ORANGE, fontsize=9)
    ax.set_ylim(0, 19100)
    ax.set_yticks([0, 5000, 10000, 15000], ['0', '5,000', '10,000', '15,000'])
    ax.set_xticks(xs, [f"{r['chartLabel']}\n{r['commit'][:7]}" for r in rows], fontsize=8)
    ax.set_ylabel('Bend compiler source lines\nExact membership from each Git revision')
    ax.set_title('3  Simplicity: meaningful consolidation, with later growth for correctness', loc='left', pad=15)
    ax.text(0, 1.015, 'Canonical compiler Bend modules: includes backends/driver; excludes host/runtime, generated files and tests.',
            transform=ax.transAxes, fontsize=9, color=GRAY)
    ax.legend(loc='lower right', frameon=False, ncol=2)
    ax.set_xlim(-.6, len(rows)-.4)
    style(ax)

fig, axs = plt.subplots(3, 1, figsize=(15, 13.5))
fig.subplots_adjust(top=.88, bottom=.075, left=.12, right=.97, hspace=.70)
fig.suptitle('Bend compiler implemented in Bend: the measured history',
             x=.12, y=.996, ha='left', fontsize=20, weight='bold')
fig.text(.12,.959,'Selected checkpoints, 21–29 September 2026 · PR #1207 · head 5350b2f\n'
         'Agent-generated research report. Milestones are equally spaced, not an elapsed-time axis.',
         fontsize=10, color=GRAY, va='top')
speed(axs[0]); conformance(axs[1]); complexity(axs[2])
fig.text(.12,.005,'Sources, full commits, commands and scope: chart-data.json, history tables and report.md.\n'
         'Checking: 2–3 samples/image; Bend uses validated Base caches, TypeScript checks Base.\n'
         'Earlier ≈40× self-emission has a different compiler generation and timing boundary; it is not joined to the checking series.',
         fontsize=9, color=GRAY)
save(fig, 'historical-metrics'); plt.close(fig)

for name,func in [('checking-history',speed),('conformance-history',conformance),('complexity-history',complexity)]:
    fig,ax=plt.subplots(figsize=(15,5.7))
    fig.subplots_adjust(top=.83,bottom=.24,left=.12,right=.97)
    func(ax)
    footer='Agent-generated report for PR #1207 · milestone spacing · immutable sources in chart-data.json · head 5350b2f'
    if name=='checking-history':
        footer+='\n2–3 samples/image; Bend uses validated Base caches, TypeScript checks Base. Process includes startup and provenance hashing.'
    fig.text(.12,.025,footer,
             fontsize=9,color=GRAY)
    save(fig,name);plt.close(fig)

rows=DATA['paired']
fig,axs=plt.subplots(1,2,figsize=(14,5.4),gridspec_kw={'width_ratios':[1.45,1]})
fig.subplots_adjust(top=.81,bottom=.17,wspace=.38,left=.10,right=.96)
ax=axs[0]
ys=np.arange(len(rows))
gains=[100*(1-r['compiler_s']/r['baseline_s']) for r in rows]
ax.barh(ys,gains,color=BLUE,height=.62)
ax.set_yticks(ys,[r['label'] for r in rows]);ax.invert_yaxis()
for y,v,r in zip(ys,gains,rows):
    ax.text(v+1,y,f"−{v:.1f}%  ({r['baseline_s']:.2f} → {r['compiler_s']:.2f}s)",va='center',fontsize=9)
ax.set_xlim(0,103)
ax.set_xlabel('Process-time reduction within each paired experiment (%)')
ax.set_title('Paired release comparisons',loc='left',pad=15)
style(ax)
ax=axs[1]
b=DATA['complexity_baseline'];f=DATA['complexity'][-1]
labels=['Physical lines','Nonblank lines','Source bytes','Definitions']
keys=['physicalLines','nonblankLines','bytes','defs']
deltas=[100*(f[k]/b[k]-1) for k in keys]
ax.barh(np.arange(4),deltas,color=[TEAL if v<0 else ORANGE for v in deltas],height=.58)
for y,v in enumerate(deltas):
    ax.text(v+(0.8 if v>=0 else -0.8),y,f'{v:+.2f}%',va='center',ha='left' if v>=0 else 'right',fontsize=10)
ax.axvline(0,color=GRAY,lw=1)
ax.set_yticks(np.arange(4),labels);ax.invert_yaxis();ax.set_xlim(-13,25)
ax.set_xlabel('Current change from the 16,509-line baseline (%)')
ax.set_title('Why lines alone are incomplete',loc='left',pad=15)
style(ax)
fig.suptitle('Where the gains are established — and where the tradeoff remains',x=.10,y=.98,ha='left',fontsize=18,weight='bold')
fig.text(.10,.91,'Separate same-window comparisons; percentages are not compounded. Declaration counts are not a count of concepts.',fontsize=10,color=GRAY)
fig.text(.10,.035,'Agent-generated report · sources and exact identities in chart-data.json · emitted-program runtime has no comparable longitudinal series.',fontsize=9,color=GRAY)
save(fig,'paired-gains-and-tradeoffs');plt.close(fig)

fig,ax=plt.subplots(figsize=(14,7.5));ax.axis('off')
fig.subplots_adjust(left=.04,right=.98,top=.88,bottom=.10)
fig.suptitle('The main pattern: remove repeated work and duplicated authority',x=.055,y=.97,ha='left',fontsize=19,weight='bold')
cards=[
 ('P9 · binder freshness', 'Scan preceding definitions\nfor each chronological law fill',
  'Compute one binder bound;\nkeep visibility environments separate',
  '4 / 8 / 16 fills: full-book scans 5 / 9 / 17 → 1 / 1 / 1'),
 ('P16 · compact literals', 'Expand literals into constructor trees;\ncopy, freshen and encode the trees',
  'Keep scalar/string payloads compact;\nexpose a constructor view on demand',
  'Same-source census: 2,171,045 → 152,620 freshened terms (−92.97%)'),
 ('P22 · contextual frontend', 'Parse first; reconstruct scope later;\nrepeat completion and diagnostics',
  'Resolve at the right parsing checkpoint;\none contextual completion authority',
  'Main: 2 → 0 differences; broader: 57 → 0; net compiler source: −300 lines')]
for i,(title,left,right,detail) in enumerate(cards):
    y=.92-i*.31
    ax.text(.01,y,title,fontsize=12,weight='bold',va='top')
    ax.text(.01,y-.085,left,fontsize=11,va='top',bbox={'boxstyle':'round,pad=.6','fc':'#f2f4f8','ec':'none'})
    ax.annotate('',xy=(.55,y-.115),xytext=(.43,y-.115),arrowprops={'arrowstyle':'->','color':BLUE,'lw':2})
    ax.text(.59,y-.085,right,fontsize=11,va='top',bbox={'boxstyle':'round,pad=.6','fc':'#e8f4f1','ec':'none'})
    ax.text(.01,y-.22,detail,fontsize=10,color=GRAY)
fig.text(.055,.035,'Agent-generated report · operation counts describe named probes, not whole-compiler speedups.\n'
         'Source-level structure also matters: direct Boolean workers can lower to loops instead of allocating branch closures.',fontsize=10,color=GRAY)
save(fig,'main-findings');plt.close(fig)
print('Wrote',len(list(OUT.iterdir())),'figure files to',OUT)
