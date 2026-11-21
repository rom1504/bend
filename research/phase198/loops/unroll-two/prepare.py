"""Freeze a source-only two-cell fold falsifier; performs no target execution."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
live=ROOT/'selfhost/build/phase198/orbit-live-plan01/manifest.json';meta=ROOT/'selfhost/build/phase198/orbit-live-plan01/report.json'
m=json.loads(live.read_text());rt=json.loads(meta.read_text())['inputs']['live']
def pin(p):return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(p):assert pin(Path(p['file']))==p
replacement=(HERE/'replacement.bend').read_text();rows=[]
for case in ['local-fold','variation-local-fold-8192-123']:
 c=next(c for c in m['cases']if c['id']==case);verify(c['source']);old=Path(c['source']['file']).read_text()
 start=old.index('def fold.loop(');end=old.index('\ndef fold.finish(',start)
 before=old[start:end];assert before.count('case ')==2 and 'fold.loop(q, U32.inc(i), fold.cell(i, st))'in before
 new=old[:start]+replacement+'\n'+old[end:];assert old.split('# Phase93:',1)[1]==new.split('# Phase93:',1)[1]
 dest=HERE/(case+'.bend');dest.write_text(new)
 report=ROOT/'selfhost/build/phase198/orbit-native45-01'/case/'machine/report.json';auth=json.loads(report.read_text());assert auth['complete']
 jobs={j['label']:j['command']for j in auth['jobs']}
 command_inputs=[pin(Path(v))for cmd in jobs.values()for v in cmd if Path(v).is_absolute()and Path(v).is_file()]
 rows.append(dict(commandInputs=command_inputs,id=case,ordinary=c['source'],source=pin(dest),point=c['point'],nativeReport=pin(report),compiler=auth['request']['image'],compilerCommand=jobs['compiler'],linkCommand=jobs['link'],ordinaryObject=c['products']['candidate']['generatedSource'],ordinaryExecutable=c['products']['candidate']['artifact'],baseline={k:c['products']['live'][k]for k in ['artifact','runtimeArgumentConvention']},c={k:c['products']['c'][k]for k in ['artifact','runtimeArgumentConvention']}))
inputs=[pin(p)for p in [live,meta,HERE/'replacement.bend',Path(__file__),ROOT/'selfhost/build/phase194/assets.json',HERE/'run.py',HERE/'model.py',HERE/'model-plan.json',ROOT/'selfhost/build/phase195/hardware-tool01/acquisition.json',ROOT/'research/phase198/reuse/mca/run.py']]
report=dict(status='prepared-unchecked',scope='Source-level unroll-two only; exactly two sizes from one family, not independent-family transfer. Frozen orbit compiler and live runtime, unchanged ordinary mature C oracle.',inputs=inputs,runtime=rt,ordinaryRuntime=json.loads(meta.read_text())['inputs']['original'],rows=rows,edgeCases=[[0,0],[1,4294967295],[2,17],[3,123],[127,123],[128,0],[129,4294967295],[130,0],[255,17],[256,4294967295],[257,123],[4095,17],[4097,17],[8191,123],[8193,123]],prediction='Must emit two ordered array-cell updates per steady backedge with no extra per-cell runtime calls; otherwise early stop. Gain beyond generic coalescing is unknown. Allocation and full harness unchanged.')
(HERE/'frozen.json').write_text(json.dumps(report,indent=2)+'\n')
argv=['python3','research/phase198/qualification/job.py','--rss-mib','1024','fold-unroll-two01','30','48','python3','-B',str(HERE.relative_to(ROOT)/'run.py'),'--out','selfhost/build/phase198/fold-unroll-two01']
(HERE/'argv.json').write_text(json.dumps(argv,indent=2)+'\n')
print(json.dumps({'cases':[r['id']for r in rows],'argv':argv}))
