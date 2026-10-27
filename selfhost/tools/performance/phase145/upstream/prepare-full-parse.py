#!/usr/bin/env python3
"""Metadata-only bounded full-source parser extension; reuse qualified diagnostics."""
import copy,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
PARENT=ROOT/'selfhost/build/phase145/upstream03';OUT=ROOT/'selfhost/build/phase145/upstream-full-parse01'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists();plan=copy.deepcopy(json.loads((PARENT/'plan.json').read_text()));gen=json.loads((PARENT/'artifacts/report.json').read_text());summary=json.loads((PARENT/'summary01.json').read_text());assert gen['complete']and summary['complete']
 source=pin(ROOT/'selfhost/build/phase142/indexed-source02/compiler.bend');assert source['bytes']==2946225 and source['sha256']=='15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1'
 for item in plan['inputs']:assert pin(item['file'])==item
 for row in gen['modules']:
  for mode in ['clean','counted']:assert pin(row[mode]['file'])==row[mode]
 plan.update(cases=[dict(name='full-phase142',source=source,mode='parse-only')],out=str(OUT),scope='Exact frozen full Phase142 cold-input source, upstream parse/load only including Base. No checking, erasure, emission, machine build or semantic qualification. Original and counted variants reuse the authenticated upstream03 artifacts; shared loaded-summary oracle only, not AST equality.')
 plan['inputs'] += [pin(__file__),pin(PARENT/'plan.json'),pin(PARENT/'artifacts/report.json'),pin(PARENT/'summary01.json'),source]
 OUT.mkdir(parents=True);(OUT/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';jobs=[]
 for variant in ['original','counted']:
  label='full-phase142-'+variant
  jobs.append(dict(name=label,command=[sys.executable,'-B',str(guard),'--out',str(OUT/(label+'-guard')),'--seconds','30','--rss-mib','3072','--available-mib','16384','--file-mib','64','--cpu','3','--',plan['bun']['file'],str(HERE/'worker.mjs'),str(OUT/'plan.json'),'full-phase142',variant,str(OUT/label)]))
 (OUT/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(OUT/'plan.json'),pin(guard)],jobs=jobs,scope=plan['scope'],estimate='Prefix191922B original load.308s; full2946225B is15.35x input bytes. A few-second parse is plausible, not promised; each target is bounded30s/3GiB. Clean native parser-stage timings include different completion/freshening obligations and are not a same-stage ratio.'),indent=2)+'\n')
 print(OUT/'jobs.json')
if __name__=='__main__':main()
