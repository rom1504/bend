#!/usr/bin/env python3
"""Render the two reviewed clean latency summaries; never execute a compiler."""
import argparse, hashlib, json, os, statistics, tempfile
from pathlib import Path

HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
SOURCES=[('latency-summary.json','e1dd05c49b2f14fec75d30532f5f466f90ee07b73b3f74685b923905f5b9d598'),
         ('transformation-latency-summary.json','97db288ac8012869455abcd5721dfc726282bc09b82b08ce0103509a9db6e7c6')]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,default=ROOT/'implementation/phase57/figures')
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(ROOT/'implementation/phase57')
outputs=[out/('compiler-latency'+ext) for ext in ['.svg','.png','.json']]
assert not any(x.exists() for x in outputs),'Preserve previously consumed figures'
def identity(file):
 file=Path(file);b=file.read_bytes()
 return dict(file=str(file.resolve()),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
inputs=[];summaries=[]
for name,pin in SOURCES:
 file=ROOT/'implementation/phase57/evidence'/name;item=identity(file)
 assert item['sha256']==pin;inputs.append(item);d=json.loads(file.read_text())
 assert d['complete'] and d['pass'] and d['workerProcesses']==24 and d['checkedRequests']==96
 summaries.append(d)
roles=[['typescript','raw','source','direct'],['raw','equality','choices','source']]
metrics=['importApiAndFirstMs','warmRequestMedianMs']
labels={'typescript':'Handwritten TypeScript','raw':'Raw Bend (upstream JS)',
        'source':'Derived B1','direct':'Direct B2','equality':'Equality only','choices':'+ literal choices'}
colors={'typescript':'#6E7781','raw':'#D55E00','source':'#0072B2','direct':'#009E73',
        'equality':'#CC79A7','choices':'#56B4E9'}
rows=[]
for panel,(d,rr,metric) in enumerate(zip(summaries,roles,metrics)):
 for case in ['test-evening-program','lexer']:
  for role in rr:
   v=d['cases'][case]['roles'][role][metric]
   assert len(v['samples'])==3 and statistics.median(v['samples'])==v['median']
   assert min(v['samples'])==v['min'] and max(v['samples'])==v['max']
   rows.append(dict(panel=panel,case=case,role=role,metric=metric,**v))
out.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='phase57-matplotlib-') as cache:
 os.environ['MPLCONFIGDIR']=cache
 import matplotlib
 matplotlib.use('Agg')
 import matplotlib.pyplot as plt
 from matplotlib.ticker import FuncFormatter
 plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10.5,'svg.fonttype':'none',
                      'svg.hashsalt':'phase57-clean-latency','axes.titleweight':'bold'})
 fig,axes=plt.subplots(1,2,figsize=(14,6.7))
 fig.subplots_adjust(left=.165,right=.975,top=.80,bottom=.18,wspace=.65)
 titles=['Fresh process: load + first request','Later requests: transformation stages']
 for panel,ax in enumerate(axes):
  chosen=[x for x in rows if x['panel']==panel];top=max(x['max'] for x in chosen)*1.25
  positions=[7,6,5,4,2,1,0,-1]
  for y,row in zip(positions,chosen):
   m=row['median'];ax.barh(y,m,height=.64,color=colors[row['role']],zorder=3)
   ax.errorbar(m,y,xerr=[[m-row['min']],[row['max']-m]],fmt='none',ecolor='#20262C',
               capsize=2.5,elinewidth=1,zorder=4)
   ax.text(row['max']+top*.018,y,f'{m:,.1f}',va='center',fontsize=10)
  names=[labels[x['role']] for x in chosen]
  if panel==1:names=['+ tail choices (B1)' if x=='Derived B1' else x for x in names]
  ax.set_yticks(positions,names);ax.tick_params(axis='y',length=0,pad=8)
  ax.set_xlim(0,top);ax.set_ylim(-1.8,8.55)
  ax.set_title(titles[panel],loc='left',fontsize=12,pad=10)
  ax.text(0,8,'Evening',fontweight='bold',fontsize=11)
  ax.text(0,3,'Lexer',fontweight='bold',fontsize=11)
  ax.set_xlabel('Milliseconds',labelpad=9)
  ax.xaxis.set_major_formatter(FuncFormatter(lambda value,_:f'{value:,.0f}'))
  ax.grid(axis='x',color='#E2E6EA',linewidth=.7,zorder=0)
  for edge in ['top','right','left']:ax.spines[edge].set_visible(False)
  ax.spines['bottom'].set_color('#BEC5CC')
 fig.suptitle('Compiler latency across images and transformations',x=.025,y=.965,ha='left',fontsize=17,fontweight='bold')
 fig.text(.025,.91,'Two checked inputs · three fresh processes per image and input · exact output checks',fontsize=11,color='#45515D')
 fig.text(.025,.083,'Right: median of 3 later requests per process, then median across processes; warmed windows, not steady state.',fontsize=9.5,color='#45515D')
 fig.text(.025,.047,'Separate runs in the two panels. Bars: medians. Whiskers: observed process min–max, not confidence intervals.',fontsize=9.5,color='#45515D')
 fig.savefig(outputs[0],metadata={'Date':None,'Description':'Phase57 exact clean summaries; see compiler-latency.json for provenance.'})
 fig.savefig(outputs[1],dpi=180,metadata={'Description':'Phase57 exact clean summaries; see compiler-latency.json for provenance.'})
 plt.close(fig)
 version=matplotlib.__version__
for item in inputs:assert identity(item['file'])==item
receipt=dict(kind='phase57-compiler-latency-figure',complete=True,producer=identity(__file__),
             inputs=inputs,matplotlib=version,panels=titles,rows=rows,
             scope='Data-only rendering; no pooled run, stationary-throughput or statistical-significance claim.',
             outputs=[identity(x) for x in outputs[:2]])
outputs[2].write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(outputs=[identity(x) for x in outputs]),indent=2))
