#!/usr/bin/env python3
"""Execute an explicit bounded release-job plan serially, stopping on failure."""
import argparse,json,subprocess,sys,time,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
raw=a.plan.read_bytes();plan=json.loads(raw);a.out.mkdir(parents=True,exist_ok=False)
r={'kind':'phase174-serial-jobs','complete':False,'plan':{'file':str(a.plan.resolve()),'sha256':hashlib.sha256(raw).hexdigest()},'jobs':[]}
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
for j in plan['jobs']:
 assert a.plan.read_bytes()==raw,'Plan changed'
 c=[sys.executable,'-B','selfhost/tests/phase174/job.py','--rss-mib',str(j.get('rssMiB',2048)),j['name'],str(j['seconds']),str(j['diskMiB']),*j['command']]
 row={'name':j['name'],'started':time.time(),'command':c};r['jobs'].append(row);save()
 print('START '+j['name'],flush=True)
 with (a.out/(j['name']+'.log')).open('x') as f: rc=subprocess.run(c,stdout=f,stderr=subprocess.STDOUT).returncode
 row.update(returncode=rc,finished=time.time());save();print('FINISH '+j['name']+' exit '+str(rc),flush=True)
 if rc:print((a.out/(j['name']+'.log')).read_text()[-4000:],flush=True);sys.exit(rc)
r['complete']=True;save()
