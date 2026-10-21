"""Render frozen measurements only; never execute compiler/benchmark targets."""
import argparse,hashlib,json,math,os
from pathlib import Path
os.environ.setdefault('MPLCONFIGDIR','/tmp/phase118-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=json.loads(a.input.read_text());assert r['complete'] and r['timedCases']==44 and r['observations']==405
rows=[x for x in r['cases'] if x['timed']];assert len(rows)==44
base=[x['medianMs']['baseline']/x['medianMs']['upstream'] for x in rows]
cand=[x['medianMs']['candidate']/x['medianMs']['upstream'] for x in rows]
gm=lambda xs:math.exp(sum(map(math.log,xs))/len(xs))
assert abs(gm(cand)-r['candidateVsUpstream'])<1e-12
assert not a.out.exists();a.out.mkdir(parents=True)
fig,ax=plt.subplots(figsize=(10.5,13.5));ys=list(range(len(rows)))
ax.barh([y-.19 for y in ys],base,height=.36,label=f'Phase117 — {gm(base):.3f}× geometric mean',color='#aab4c5')
ax.barh([y+.19 for y in ys],cand,height=.36,label=f'Phase118 — {gm(cand):.3f}× geometric mean',color='#007e87')
labels=[x['name'].replace('coverage-','').replace('variation-','').replace('test-','') for x in rows]
ax.set_yticks(ys,labels,fontsize=8);ax.invert_yaxis();ax.axvline(1,color='#c24343',ls='--',lw=1,label='Pinned upstream C/Clang')
ax.set_xlabel('Median runtime / pinned upstream runtime (lower is better)');ax.set_title('Phase118: original 44 timed programs',loc='left',weight='bold')
ax.grid(axis='x',alpha=.17);ax.set_axisbelow(True);ax.legend(loc='lower right',fontsize=9)
fig.text(.03,.012,'Three rotated rounds per role; complete output/count checks. Zero-work sentinel excluded.\nHosted Bend compiler emits native QBE programs; this is not compiler throughput. No confidence intervals claimed.',fontsize=8)
fig.tight_layout(rect=(0,.045,1,1));fig.savefig(a.out/'runtime.png',dpi=150);fig.savefig(a.out/'runtime.svg');plt.close(fig)
b=a.input.read_bytes();(a.out/'provenance.json').write_text(json.dumps({'input':str(a.input.resolve()),'inputSha256':hashlib.sha256(b).hexdigest(),'methodSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'targetsRun':False,'baselineGeometricRatio':gm(base),'candidateGeometricRatio':gm(cand),'observations':405},indent=2)+'\n')
print(json.dumps({'output':str(a.out),'candidate':gm(cand),'baseline':gm(base)}))
