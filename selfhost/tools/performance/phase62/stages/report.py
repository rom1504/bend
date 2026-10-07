#!/usr/bin/env python3
"""Data-only compact evidence and standard plot of the admitted stage survey."""
import argparse,hashlib,json,statistics
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('summary',type=Path);p.add_argument('clean',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
assert not a.out.exists()
def identity(f):return dict(file=str(f.resolve()),sha256=hashlib.sha256(f.read_bytes()).hexdigest())
s=json.loads(a.summary.read_text());clean=json.loads(a.clean.read_text());assert s['complete'] and s['pass'] and clean['complete'] and clean['pass'] and clean['mode']=='clean'
roles=['b2','typescript'];pairs={}
for row in s['rows']:pairs.setdefault(row['case'],{})[row['role']]=row
assert len(pairs)==23 and all(set(v)==set(roles) for v in pairs.values())
means={}
for role in roles:
 rows=[v[role] for v in pairs.values()];keys=set().union(*(r['stagesExclusiveMs'] for r in rows))
 means[role]=dict(compileMs=statistics.mean(r['clockCompileMs'] for r in rows),
  groupsExclusiveMs={k:statistics.mean(r['groupsExclusiveMs'][k] for r in rows) for k in rows[0]['groupsExclusiveMs']},
  stagesExclusiveMs={k:statistics.mean(r['stagesExclusiveMs'].get(k,0) for r in rows) for k in sorted(keys)},
  equalSourceMeanGroupShare={k:statistics.mean(r['groupsExclusiveMs'][k]/r['clockCompileMs'] for r in rows) for k in rows[0]['groupsExclusiveMs']})
extra={k:means['b2']['groupsExclusiveMs'][k]-means['typescript']['groupsExclusiveMs'][k] for k in means['b2']['groupsExclusiveMs']}
rows=[];perturbation=[]
for case,pair in pairs.items():
 b,t=pair['b2'],pair['typescript'];e={k:b['groupsExclusiveMs'][k]-t['groupsExclusiveMs'][k] for k in b['groupsExclusiveMs']}
 rows.append(dict(case=case,extraCompileMs=b['clockCompileMs']-t['clockCompileMs'],extraGroupMs=e,
  roles={role:{k:x[k] for k in ['firstRequestMs','combinedFirstMs','clockCompileMs','groupsExclusiveMs','stagesExclusiveMs','result','output']} for role,x in pair.items()}))
 if case in clean['statistics']:
  for role in roles:
   med=clean['statistics'][case][role]['firstRequestMs']['median'];diag=pair[role]['firstRequestMs']
   perturbation.append(dict(case=case,role=role,cleanMedianMs=med,diagnosticMs=diag,diagnosticOverClean=diag/med))
out=dict(kind='phase62-current-stage-cost-survey',version=1,complete=True,diagnosticOnly=True,
 inputs=dict(summary=identity(a.summary),clean=identity(a.clean),producer=identity(Path(__file__))),
 method='23 sources x two roles x one diagnostic run. Exclusive event partitions. Means are arithmetic equal-source ms, not headline geometric mean ratios. Single-run diagnostic/clean comparisons include run variation and cannot isolate instrumentation overhead.',
 means=means,meanExtraCompileMs=means['b2']['compileMs']-means['typescript']['compileMs'],meanExtraGroupMs=extra,
 checkStageB2LowerCount=sum(v['b2']['groupsExclusiveMs']['check']<v['typescript']['groupsExclusiveMs']['check'] for v in pairs.values()),
 perturbation=perturbation,rows=rows,
 limitations=['TS book_load/book_valid/js_lib are coarse unchanged calls. Bend cache+load+check form comparable combined pre-backend work; individual inner stage labels are not algorithm equivalence.',
 'Prepared Base cache transport exists only on Bend; TS Base parsing/checking is accounted in its load/check stages. The cache cost is not a standalone avoidable overhead claim.',
 'Wall stages include GC and scheduling; no independent GC cost subtraction. Private driver try/finally can affect V8 optimization.',
 'Backend total contains dependency discovery/annotation/layout/export conversion and text production; it is not solely source-string emission.',
 'No compiler modification, generated-program speed claim or semantic admission beyond byte-preserving diagnostic requests.'])
out['pass']=True;a.out.mkdir(parents=True);(a.out/'stages-summary.json').write_text(json.dumps(out,indent=2)+'\n')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fig=plt.figure(figsize=(11.5,12));grid=fig.add_gridspec(2,1,height_ratios=[1.5,6],hspace=.38);ax=fig.add_subplot(grid[0]);bx=fig.add_subplot(grid[1])
colors={'cache':'#6c89bb','load':'#e4b64a','check':'#a5bb79','backend':'#be705d','request-other':'#777777'}
labels={'cache':'Base cache','load':'Load/complete','check':'Check/complete','backend':'Backend','request-other':'Other'}
left=[0.,0.]
for key in colors:
 vals=[means[r]['groupsExclusiveMs'][key] for r in roles];ax.barh([1,0],vals,left=left,color=colors[key],label=labels[key]);left=[a+b for a,b in zip(left,vals)]
ax.set_yticks([1,0],['Bend B2','TypeScript']);ax.set_xlabel('Arithmetic mean compilation milliseconds across 23 sources');ax.set_title('Current compiler cost: one diagnostic request per source and compiler',loc='left',fontweight='bold');ax.legend(ncol=5,loc='upper center',bbox_to_anchor=(.48,-.36),frameon=False,fontsize=9);ax.set_xlim(0,1050)
for y,r in [(1,'b2'),(0,'typescript')]:ax.text(means[r]['compileMs']+8,y,f"{means[r]['compileMs']:.0f} ms",va='center',fontsize=10)
ordered=sorted(rows,key=lambda r:r['extraCompileMs'],reverse=True);y=list(range(len(ordered)));front=[sum(r['extraGroupMs'][k] for k in ['cache','load','check']) for r in ordered];back=[r['extraGroupMs']['backend'] for r in ordered];other=[r['extraGroupMs']['request-other'] for r in ordered]
bx.barh(y,front,color='#759ab4',label='Loading + Base + checking difference');bx.barh(y,back,left=front,color=colors['backend'],label='Backend difference');bx.barh(y,other,left=[a+b for a,b in zip(front,back)],color=colors['request-other'],label='Other difference')
bx.set_yticks(y,[r['case'] for r in ordered],fontsize=9);bx.invert_yaxis();bx.set_xlabel('Bend B2 minus TypeScript compilation milliseconds');bx.set_title('Where the extra time occurs',loc='left',fontweight='bold');bx.legend(loc='lower right',frameon=False,fontsize=9);bx.set_xlim(0,1050);bx.grid(axis='x',alpha=.2);bx.set_axisbelow(True)
for a in [ax,bx]:a.spines[['top','right']].set_visible(False)
fig.text(.02,.017,'Diagnostic wall clocks include hook/GC/scheduling effects. Prepared Base cache costs belong to Bend; TypeScript Base work is in load/check.\nThese arithmetic stage totals are not the clean headline speed ratio. Source and compiler outputs were checked byte-for-byte.',fontsize=9,color='#444444')
fig.subplots_adjust(left=.23,right=.98,top=.96,bottom=.07)
for suffix in ['svg','png']:fig.savefig(a.out/('stages-costs.'+suffix),dpi=160)
print(json.dumps(dict(evidence=str(a.out/'stages-summary.json'),meanExtraCompileMs=out['meanExtraCompileMs'],figures=['stages-costs.svg','stages-costs.png'])))
