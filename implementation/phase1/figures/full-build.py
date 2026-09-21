import os
os.environ['MPLCONFIGDIR']='/tmp/bend-phase1-matplotlib'
import json,pathlib,matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
out=pathlib.Path(__file__).resolve().parent;e=out.parent/'evidence'
a=json.loads((e/'control-full.json').read_text())['samples'][0];b=json.loads((e/'candidate-full.json').read_text())['samples'][0]
groups=[('Parse / load',['f_parse','f_load_graph_seed']),('Check',['check_from_exact_prefix']),('Annotate',['annotate_selected']),('Layout',['j_layout_error']),('Emit',['j_library_selected'])]
colors=['#79a8cf','#376894','#e4a047','#ba7345','#48897d','#b4bbc4']
plt.rcParams.update({'font.size':10,'svg.fonttype':'none','font.family':'DejaVu Sans'})
fig,ax=plt.subplots(figsize=(9,3.8),layout='constrained')
for index,(row,label) in enumerate([(a,'Original self-emitted'),(b,'Phase 1 self-emitted')]):
 used=0;left=0
 for j,(name,keys) in enumerate(groups):
  ms=sum(row['phases'].get(k,0) for k in keys);used+=ms;minutes=ms/60000
  ax.barh(index,minutes,left=left,color=colors[j],label=name if index==0 else None,height=.46);left+=minutes
 ms=row['compileMs']-used;assert ms>=-1
 ax.barh(index,max(0,ms)/60000,left=left,color=colors[-1],label='Other + host' if index==0 else None,height=.46)
 ax.text(row['compileMs']/60000+.8,index,f"{row['compileMs']/60000:.2f} min",va='center')
ax.set_yticks([0,1],['Original self-emitted','Phase 1 self-emitted']);ax.invert_yaxis();ax.set_xlabel('Checked compilation time (minutes)');ax.set_xlim(0,max(a['compileMs'],b['compileMs'])/60000*1.14)
ax.set_title('One invocation each; identical archived source, warm Base cache, CPU 2.\nShared-host measurements.',loc='left',fontsize=9,pad=12);ax.spines[['top','right','left']].set_visible(False);ax.grid(axis='x',alpha=.18);ax.set_axisbelow(True)
fig.legend(loc='outside lower center',ncol=3,frameon=False)
fig.suptitle('Same-source full compiler build',fontsize=14,weight='bold',x=.03,ha='left')
fig.savefig(out/'full-build.svg',metadata={'Date':None,'Description':'Phase 1 same-source compiler timing. Single observations, not confidence intervals.'})
print(out/'full-build.svg')
