#!/usr/bin/env python3
"""Run the maintained45 points once, in three complete five-round batches."""
import argparse,json,subprocess,sys,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('candidate',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
R=Path(__file__).resolve().parents[4];C=R/'selfhost/tools/performance/phase37/catalog.json';B=R/'selfhost/build/phase47/baseline/manifest.json';N='/home/ai/.nvm/versions/node/v24.18.0/bin/node'
ids=[c['id'] for c in json.loads(C.read_text())['cases']];assert len(ids)==45
a.out.mkdir(parents=True,exist_ok=False);commands=[]
for i in range(3):
 cmd=[sys.executable,str(R/'selfhost/tools/performance/programs/run.py'),'--catalog',str(C),'--baseline',str(B),'--candidate',str(a.candidate.resolve()),'--cases',','.join(ids[i*15:(i+1)*15]),'--budget','600','--out',str((a.out/f'runtime-{i}').resolve()),'--node',N,'--cpu','3','--rss-mib','2048','--available-mib','4096'];commands.append(cmd)
plan={'kind':'phase47-full-corpus-queue','producerSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'commands':commands,'scope':'Serial maintainedrunner with its own ExecutionGuard; five rotated fresh-process rounds, except existing raytrace policy. No recompilation or profiling.'}
(a.out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
for i,cmd in enumerate(commands):
 print('Starting complete batch',i,flush=True);subprocess.run(cmd,cwd=R,check=True)
subprocess.run([sys.executable,str(R/'selfhost/tools/performance/phase44/summarize-runtime.py'),str(C),str(B),str(a.candidate.resolve()),str((a.out/'summary.json').resolve()),*[str((a.out/f'runtime-{i}/report.json').resolve()) for i in range(3)]],cwd=R,check=True)
