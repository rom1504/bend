"""Export static figures from the retained survey receipts."""
import os,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];OUT=ROOT/'implementation/phase116';os.environ['MPLCONFIGDIR']=str(ROOT/'selfhost/build/phase116/matplotlib-cache')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
r=json.loads((OUT/'results.json').read_text());names={'variation-local-fold-128-0':'Array fold','tree-bitonic':'Tree','coverage-list-pipeline-128':'List pipeline','lexer':'Lexer','variation-ray-active-256-2240':'Active ray','scalar-region-8192':'Scalar loop','coverage-map-churn-128':'Map churn','editdist':'Edit distance'}
plt.rcParams.update({'font.size':10,'svg.fonttype':'none'})
fig,ax=plt.subplots(figsize=(11,5.8));ys=np.arange(len(r['cases']));roles=['qbe','selfhost_c','selfhost_js','upstream_js'];colors=['#d55e00','#009e73','#0072b2','#9b6bb0'];labels=['Selfhost QBE (Phase114)','Selfhost C (Phase102)','Selfhost JavaScript','Upstream JavaScript']
for k,role in enumerate(roles):
 vals=[c['ratiosToUpstreamC'][role] for c in r['cases']];ax.barh(ys+(k-1.5)*.18,vals,height=.17,label=labels[k],color=colors[k]);
ax.set_yticks(ys,[names[c['name']] for c in r['cases']]);ax.invert_yaxis();ax.set_xscale('log');ax.set_xticks([.5,1,2,4,8,16,32],['0.5×','1×','2×','4×','8×','16×','32×']);ax.axvline(1,color='#333',linewidth=1);ax.set_xlim(.5,32);ax.set_xlabel('Execution time / upstream C time (lower is better)');ax.set_title('Matched source, inputs and outputs; eight diagnostic workloads');ax.grid(axis='x',alpha=.15);ax.set_axisbelow(True);ax.legend(loc='lower right',fontsize=9);fig.text(.01,.01,'Three rotated rounds; 120 complete-output checks. Different backend producer versions. This is not the broad45 score.',fontsize=8);fig.tight_layout(rect=[0,.03,1,1]);fig.savefig(OUT/'backend-ratios.svg');plt.close(fig)
categories=['private_worker','constructor_take','ownership_heap','dispatch_transport','generic_primitive','library','other'];lab=['Private workers','Constructor / take','Ownership / heap','Dispatch / transport','Generic primitive','Shared library','Other'];cols=['#0072b2','#d55e00','#e69f00','#cc79a7','#009e73','#777777','#c9c9c9'];rows=[next(p for p in r['nativeProfiles'] if p['case']==c['name'] and p['role']=='qbe') for c in r['cases']]
fig,ax=plt.subplots(figsize=(11,5.8));left=np.zeros(len(rows))
for cat,label,col in zip(categories,lab,cols):
 vals=np.array([100*p['categories'].get(cat,{}).get('fraction',0) for p in rows]);ax.barh(ys,vals,left=left,label=label,color=col);left+=vals
ax.set_yticks(ys,[names[p['case']] for p in rows]);ax.invert_yaxis();ax.set_xlim(0,100);ax.set_xlabel('Share of physical CPU samples (%)');ax.set_title('Where current QBE products execute');ax.legend(loc='upper center',bbox_to_anchor=(.5,-.12),ncol=4,fontsize=9);fig.text(.01,.01,'Two sampling periods; zero dropped/overrun samples. Leaf categories are exclusive; callees are not charged to callers.',fontsize=8);fig.tight_layout(rect=[0,.08,1,1]);fig.savefig(OUT/'qbe-profile-shares.svg');plt.close(fig)
print('Exported two SVG figures')
