"""Meaningful runner gates: timeout, ordinary failure, later work and input pin."""
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,fresh_output,write_json,require
out=fresh_output(sys.argv[1],ROOT)
jobs=[dict(id=action,seconds=.25 if action=='timeout' else 2,resultReport=False,
           command=['python3','-B','selfhost/tests/phase176/batch-control-child.py',action])
      for action in ['timeout','fail','pass']]
manifest=dict(kind='phase176-independent-jobs',version=1,
              inputs=[pin('selfhost/tests/phase176/batch-control-child.py')],jobs=jobs)
write_json(out/'manifest.json',manifest)
cmd=[sys.executable,'-B','selfhost/tests/phase176/batch.py','--manifest',str(out/'manifest.json'),'--cpus','3,5','--out',str(out/'batch')]
process=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=10)
(out/'stdout').write_bytes(process.stdout);(out/'stderr').write_bytes(process.stderr)
r=json.loads((out/'batch/report.json').read_text());rows={x['id']:x for x in r['jobs']}
require(process.returncode==1 and not r['complete'],'Failure must propagate')
require(rows['timeout']['timedOut'] and rows['timeout']['exitCode']==-9,'Timeout must kill child')
require(rows['fail']['exitCode']==7 and rows['pass']['complete'],'Preserve failure and continue independent work')
require(r['seconds']<2 and len(r['jobs'])==3,'No blocked lane or skipped job')
manifest['inputs'][0]['sha256']='0'*64;write_json(out/'changed.json',manifest)
cmd[cmd.index('--manifest')+1]=str(out/'changed.json');cmd[-1]=str(out/'rejected')
rejected=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=5)
require(rejected.returncode!=0 and not (out/'rejected').exists(),'Changed input must fail before execution')
write_json(out/'report.json',dict(kind='phase176-runner-controls',complete=True,
    inputs=[pin(__file__),pin('selfhost/tests/phase176/batch.py')],
    checks=['timeout-killed','exit-preserved','later-job-runs','no-blocked-lane','changed-input-refused'],
    batch=pin(out/'batch/report.json'),scope='Fixed nondetaching children only; not a generic detached process-tree supervisor.'))
