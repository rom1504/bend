"""Execute frozen ordered experiment gates, retaining every result."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists();a.out.mkdir(parents=True)
raw=a.plan.read_bytes();plan=json.loads(raw);assert plan['complete']
r={'complete':False,'plan':str(a.plan.resolve()),'planSha256':hashlib.sha256(raw).hexdigest(),'jobs':[]};start=time.monotonic()
def save(): (a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
for job in plan['commands']:
    before=time.monotonic()
    with (a.out/(job['name']+'.stdout')).open('xb') as out,(a.out/(job['name']+'.stderr')).open('xb') as err:
        result=subprocess.run(job['argv'],stdout=out,stderr=err,timeout=45)
    r['jobs'].append({'name':job['name'],'command':job['argv'],'returncode':result.returncode,'seconds':time.monotonic()-before});save()
    print(job['name'],result.returncode,flush=True)
    if result.returncode: raise SystemExit(result.returncode)
assert a.plan.read_bytes()==raw
r.update(complete=True,seconds=time.monotonic()-start);save()
