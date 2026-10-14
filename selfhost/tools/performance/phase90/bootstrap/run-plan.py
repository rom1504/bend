#!/usr/bin/env python3
"""Run recorded bootstrap jobs serially through one resource guard per target."""
import hashlib,json,subprocess,sys
from pathlib import Path

root=Path(__file__).resolve().parents[5]
plan=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve()
out.mkdir(parents=True,exist_ok=False)
pin=lambda p:dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
inputs=[pin(plan),pin(Path(__file__).resolve())]
report=dict(complete=False,inputs=inputs,rows=[])
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
save()
for row in json.loads(plan.read_bytes())['commands']:
    command=row['command'];seconds=60
    if 'bounded-run.py' in ' '.join(command):
        seconds=int(command[command.index('--seconds')+1])
        assert command[command.index('--rss-mib')+1]=='2048'
        assert command[command.index('--available-mib')+1]=='4096'
        command=command[command.index('--')+1:]
    target=[sys.executable,'-B',str(root/'selfhost/tools/performance/phase86/guard.py'),
            '--out',str(out/row['name']),'--seconds',str(seconds),'--rss-mib','2048',
            '--available-mib','4096','--cpu','3','--',*command]
    print(json.dumps(dict(starting=row['name'])),flush=True)
    result=subprocess.run(target,cwd=root)
    report['rows'].append(dict(name=row['name'],original=row['command'],command=target,returncode=result.returncode))
    save()
    if result.returncode:sys.exit(result.returncode)
for p in inputs:assert pin(Path(p['file']))==p
report['complete']=True;save()
