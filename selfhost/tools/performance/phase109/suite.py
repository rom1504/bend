#!/usr/bin/env python3
"""Serial bounded ownership slice suite. Run under the Phase86 process-tree guard."""
import argparse,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
HERE=ROOT/'selfhost/tools/performance/phase109'
p=argparse.ArgumentParser(description=__doc__)
for name in ['out','api','capture','derived','runtime','production-runtime','harness']:
 p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--policies',nargs='+',choices=['raw','trusted','fused'],default=['raw','trusted','fused'])
p.add_argument('--rounds',type=int,default=3)
a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists();out.mkdir(parents=True)
report=dict(kind='phase109-owned-suite',complete=False,jobs=[]);save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def run(name,cmd):
 job=dict(name=name,command=list(map(str,cmd)));report['jobs'].append(job);save();start=time.monotonic()
 with (out/(name+'.stdout')).open('xb') as so,(out/(name+'.stderr')).open('xb') as se:
  child=subprocess.run(job['command'],cwd=ROOT,stdout=so,stderr=se,timeout=60)
 job.update(status=child.returncode,seconds=time.monotonic()-start);save()
 if child.returncode:raise RuntimeError(name+' failed: '+str(out/(name+'.stderr')))
save()
try:
 for policy in a.policies:
  for variant in ['reverse','discard','duplicate']:
   label=policy+'-'+variant;emitted=out/(label+'-emitted');kernel=out/(label+'-kernel')
   run(label+'-emit',[ROOT/'selfhost/.bootstrap/bun-1.4.3/bun',HERE/'emit.mjs',a.api,a.capture if variant=='reverse' else a.derived,emitted,variant,policy])
   variants=['direct-qbe','direct-clang']
   if variant=='reverse':variants+=['production-gcc','production-clang','production-qbe']
   run(label+'-kernel',[sys.executable,'-B',HERE/'kernel.py','--out',kernel,'--emitted',emitted,'--runtime',a.runtime,'--production-runtime',a.production_runtime,'--harness',a.harness,'--rounds',str(a.rounds if variant=='reverse' else 0),'--only',*variants])
 report['complete']=True;save();print(json.dumps(dict(complete=True,jobs=len(report['jobs']))))
except BaseException as e:report['error']=repr(e);save();raise
