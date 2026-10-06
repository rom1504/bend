#!/usr/bin/env python3
"""Static charts from verified Phase58 clean and allocation summaries; no targets."""
import argparse, hashlib, json, os, statistics, tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('clean',type=Path);p.add_argument('allocation',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(ROOT/'implementation/phase58') and not out.exists()
def identity(file):
 file=Path(file).resolve();b=file.read_bytes()
 return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
inputs=[]
def read(file,mode):
 i=identity(file);inputs.append(i);s=json.loads(Path(file).read_text())
 assert s['kind']=='phase58-latency-emission-analysis' and s['complete'] and s['pass']
 assert s['dataOnly'] and not s['targetExecuted']
 assert s['producer']['sha256']=='200f9daae7217af9e1450b7ca01aacd006859c943f42d1d56a83868ec9d6d73d'
 assert identity(s['producer']['file'])['sha256']==s['producer']['sha256']
 cs={Path(c['report']['file']).parent.name.split('-')[0]:c for c in s['campaigns']}
 assert set(cs)=={'b1','b2'} and len(s['campaigns'])==2 and all(c['mode']==mode for c in cs.values())
 return cs
clean=read(a.clean,'clean');allocation=read(a.allocation,'allocation')
roles=['baseline','candidate','typescript'];cases=['test-evening-program','lexer']
colors={'baseline':'#D55E00','candidate':'#009E73','typescript':'#6E7781'}
labels={'baseline':'Old','candidate':'New','typescript':'TypeScript'};rows=[];images={}
for image in ['b1','b2']:
 images[image]={}
 for role in ['baseline','candidate']:
  x=clean[image]['roles'][role];y=allocation[image]['roles'][role]
  assert x['image']['api']['sha256']==y['image']['api']['sha256']
  assert x['subject']['source']['sha256']==y['subject']['source']['sha256']
  images[image][role]=dict(api=x['image']['api'],source=x['subject']['source'])
 for metric in ['importApiAndFirstMs','warmRequestMedianMs']:
  for case in cases:
   for role in roles:
    v=clean[image]['cases'][case]['roles'][role][metric]
    assert len(v['samples'])==3 and statistics.median(v['samples'])==v['median']
    assert min(v['samples'])==v['min'] and max(v['samples'])==v['max']
    rows.append(dict(kind='latency',image=image,metric=metric,case=case,role=role,**v))
 for role in roles:
  v=allocation[image]['allocation']['lexer']['roles'][role]
  assert len(v['samples'])==1 and v['samples'][0]==v['median']
  rows.append(dict(kind='allocation',image=image,metric='estimatedBytesPerRequest',case='lexer',role=role,**v))
for role in ['baseline','candidate']:
 assert images['b1'][role]['source']['sha256']==images['b2'][role]['source']['sha256']
out.mkdir(parents=True)
with tempfile.TemporaryDirectory(prefix='phase58-plot-') as cache:
 os.environ['MPLCONFIGDIR']=cache
 import matplotlib
 matplotlib.use('Agg')
 import matplotlib.pyplot as plt
 from matplotlib.ticker import FuncFormatter
 plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'svg.fonttype':'none',
  'svg.hashsalt':'phase58-clean-and-allocation','axes.titleweight':'bold'})
 def style(ax,xmax,label):
  ax.set_xlim(0,xmax);ax.set_xlabel(label);ax.grid(axis='x',color='#E2E6EA',linewidth=.7,zorder=0)
  ax.xaxis.set_major_formatter(FuncFormatter(lambda v,_:f'{v:,.0f}'))
  ax.tick_params(axis='y',length=0,pad=7)
  for edge in ['top','right','left']:ax.spines[edge].set_visible(False)
  ax.spines['bottom'].set_color('#BEC5CC')
 fig,axes=plt.subplots(2,2,figsize=(13,9.6))
 fig.subplots_adjust(left=.09,right=.97,top=.86,bottom=.14,hspace=.48,wspace=.25)
 for col,image in enumerate(['b1','b2']):
  for row,metric in enumerate(['importApiAndFirstMs','warmRequestMedianMs']):
   ax=axes[row,col];rs=[x for x in rows if x['kind']=='latency' and x['image']==image and x['metric']==metric]
   xmax=max(x['max'] for x in rs)*1.26;positions=[6,5,4,2,1,0]
   for y,x in zip(positions,rs):
    m=x['median'];ax.barh(y,m,height=.66,color=colors[x['role']],zorder=3)
    ax.errorbar(m,y,xerr=[[m-x['min']],[x['max']-m]],fmt='none',ecolor='#20262C',capsize=2,elinewidth=1,zorder=4)
    ax.text(x['max']+.017*xmax,y,f'{m:,.1f}',va='center',fontsize=9)
   ax.set_yticks(positions,[labels[x['role']] for x in rs]);ax.set_ylim(-.65,7.2)
   ax.text(0,6.8,'Evening',fontweight='bold');ax.text(0,2.8,'Lexer',fontweight='bold')
   title='Import + API load + first request' if row==0 else 'Later requests: process medians'
   ax.set_title(image.upper()+': '+title,loc='left',fontsize=11);style(ax,xmax,'Milliseconds')
 fig.suptitle('Compiler latency: old and new images versus TypeScript',x=.035,y=.965,ha='left',fontsize=16,fontweight='bold')
 fig.text(.035,.915,'Two inputs; 3 fresh processes per role/input. Bars are medians; whiskers are observed min–max, not confidence intervals.',fontsize=10)
 fig.text(.035,.074,'Later statistic: median across 3 process medians, each from 3 later requests. These windows are still warming.',fontsize=9)
 caption='Sources '+images['b1']['baseline']['source']['sha256'][:8]+' → '+images['b1']['candidate']['source']['sha256'][:8]+'. '
 caption+='B1 '+images['b1']['baseline']['api']['sha256'][:8]+' → '+images['b1']['candidate']['api']['sha256'][:8]+'. '
 caption+='B2 '+images['b2']['baseline']['api']['sha256'][:8]+' → '+images['b2']['candidate']['api']['sha256'][:8]+'.'
 fig.text(.035,.04,caption,fontsize=9)
 outputs=[]
 for ext in ['svg','png']:
  file=out/('compiler-latency.'+ext);fig.savefig(file,dpi=180,metadata={'Description':'See comparison.json for exact saved-data provenance.'});outputs.append(file)
 plt.close(fig)
 fig,axes=plt.subplots(1,2,figsize=(12,4.8));fig.subplots_adjust(left=.09,right=.97,top=.76,bottom=.23,wspace=.30)
 xmax=max(x['median']/1e6 for x in rows if x['kind']=='allocation')*1.23
 for ax,image in zip(axes,['b1','b2']):
  rs=[x for x in rows if x['kind']=='allocation' and x['image']==image]
  for y,x in zip([2,1,0],rs):
   value=x['median']/1e6;ax.barh(y,value,height=.60,color=colors[x['role']],zorder=3)
   ax.text(value+.018*xmax,y,f'{value:,.1f}',va='center')
  ax.set_yticks([2,1,0],[labels[x['role']] for x in rs]);ax.set_ylim(-.65,2.65)
  ax.set_title(image.upper()+' / lexer',loc='left',fontsize=12);style(ax,xmax,'Sampled decimal MB / request')
 fig.suptitle('Cumulative allocation per ordinary compiler request',x=.035,y=.96,ha='left',fontsize=16,fontweight='bold')
 fig.text(.035,.86,'One profile process per role, after ordinary warm requests. Includes collected objects; not retained heap or peak RSS.',fontsize=10)
 fig.text(.035,.12,'128 KiB sampling; estimates include accounting warnings preserved in the report. Each panel uses its own TypeScript run.',fontsize=9)
 fig.text(.035,.055,caption,fontsize=9)
 for ext in ['svg','png']:
  file=out/('compiler-allocation.'+ext);fig.savefig(file,dpi=180,metadata={'Description':'See comparison.json for exact saved-data provenance.'});outputs.append(file)
 plt.close(fig);version=matplotlib.__version__
for item in inputs:assert identity(item['file'])==item
receipt=dict(kind='phase58-compiler-comparison-figures',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),inputs=inputs,images=images,rows=rows,matplotlib=version,
 outputs=[identity(x) for x in outputs],scope='Separate campaigns and sampled allocations; no pooled timing, stationary rate, significance or single-pass causal claim.')
(out/'comparison.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(receipt=identity(out/'comparison.json'),figures=len(outputs))))
