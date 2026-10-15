#!/usr/bin/env python3
"""Render the measured native program ratios; the zero-work control has no bar."""
import json, os
from pathlib import Path
os.sched_setaffinity(0,{0})
os.environ.setdefault('MPLCONFIGDIR','/tmp/phase93-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[4]
out=ROOT/'implementation/phase93'
summary=json.loads((out/'summary.json').read_text())
rows=summary['rows']
fig,ax=plt.subplots(figsize=(11,15))
for i,row in enumerate(rows):
    ratio=row['ratio']
    if ratio is None:
        ax.text(.27,i,'undefined: zero-work batch optimized away',va='center',fontsize=8,color='#606770')
    else:
        ax.barh(i,ratio,color='#287d8e' if ratio<=1 else '#bd663a',height=.65)
        ax.text(ratio*1.035,i,f'{ratio:.2f}×',va='center',fontsize=8)
ax.set_yticks(range(len(rows)),[r['id'].replace('coverage-','').replace('variation-','var-') for r in rows],fontsize=8)
ax.invert_yaxis();ax.set_xscale('log');ax.set_xlim(.25,4.6)
ax.set_xticks([.25,.5,1,2,4],['0.25×','0.5×','1×','2×','4×'])
ax.axvline(1,color='#222222',linewidth=1)
ax.axvline(summary['equalPointGeomean'],color='#7a5195',linestyle='--',linewidth=1)
ax.set_xlabel('Our native-generated program time / upstream-generated C program time (log scale)')
ax.set_title(f"Original 45 native runtime comparison\n44 measurable points: {summary['equalPointGeomean']:.3f}× geometric mean; lower is faster",loc='left',fontsize=13,pad=14)
ax.grid(axis='x',alpha=.18);ax.set_axisbelow(True)
for side in ['top','right','left']:ax.spines[side].set_visible(False)
fig.text(.02,.008,'Same fixed inputs, Clang22 C11/O3, one CPU thread, GPU off. Three samples per role; medians shown; validation included. Native B1/B2 emit identical C.',fontsize=8)
fig.tight_layout(rect=[0,.025,1,1])
fig.savefig(out/'runtime-ratios.svg');fig.savefig(out/'runtime-ratios.png',dpi=140)
svg=out/'runtime-ratios.svg'
svg.write_text('\n'.join(line.rstrip() for line in svg.read_text().splitlines())+'\n')
print('Saved runtime-ratios.svg and runtime-ratios.png')
