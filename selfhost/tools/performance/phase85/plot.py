#!/usr/bin/env python3
"""Plot measured compiler CPU attribution; no compiler execution."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'implementation/phase85'
p=json.loads((OUT/'timeline.json').read_text())
rows={(j['job']['case'],j['job']['role']):j['phases']['request1'] for j in p['jobs']}
fig,axes=plt.subplots(1,2,figsize=(11,4.1),sharex=True)
colors=['#176B87','#64CCC5','#F4A261','#C5CDD3']
labels=['Main-thread V8 compilation','Background TurboFan','Background Maglev','Other CPU (includes execution)']
for ax,case,title in zip(axes,['numeric','functions65'],['Numeric','Functions65']):
    for y,role in enumerate(['b2','typescript']):
        r=rows[case,role];parts=[r['mainCompileExcludingObservedGcCpuMs']['lower'],r['backgroundTurboFan']['containedCpuMs'],r['backgroundMaglev']['containedCpuMs']]
        parts.append(r['processCpuMs']-sum(parts));left=0
        for i,value in enumerate(parts):
            ax.barh(y,value,left=left,color=colors[i],label=labels[i] if y==0 else None)
            if value>=60:ax.text(left+value/2,y,f'{value:.0f}',ha='center',va='center',fontsize=9)
            left+=value
        ax.text(left+12,y,f'{left:.0f} ms',va='center',fontsize=9)
    ax.set_yticks([0,1],['B2','Upstream TS']);ax.invert_yaxis();ax.set_title(title);ax.set_xlabel('Process CPU during the first request (ms)')
    ax.set_xlim(0,1100);ax.spines[['top','right']].set_visible(False)
fig.suptitle('A large part of the cold compilation gap is V8 compiling the compiler',fontsize=13,y=.99)
fig.legend(*axes[0].get_legend_handles_labels(),loc='lower center',ncol=2,frameon=False,fontsize=9,bbox_to_anchor=(.5,.015))
fig.text(.5,.005,'One instrumented request per role and source, one CPU; attribution is not a promised speedup.',ha='center',fontsize=8)
fig.tight_layout(rect=[0,.18,1,.93])
fig.savefig(OUT/'v8-cpu.png',dpi=150);fig.savefig(OUT/'v8-cpu.svg')
