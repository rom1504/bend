#!/usr/bin/env python3
"""P68-018 exact saved-C intervention; no production compiler changes."""
import importlib.util,json,re,time,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def module(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=module('support',ROOT/'selfhost/tools/performance/programs/support.py');O=module('oracle',ROOT/'selfhost/tools/performance/phase46/oracle.py')
read=lambda p:json.loads(Path(p).read_text())
source_report=ROOT/'selfhost/build/phase68/native-scalar20-rest/report.json';acq=read(source_report);assert acq['complete']
recipe=read(acq['recipe']['path']);catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')}
out=ROOT/'selfhost/build/phase68/user-seal-diagnostic02';out.mkdir(exist_ok=False)
pins=[S.identity(__file__),S.identity(source_report),acq['recipe'],*recipe['inputs']];arms={};changes=[]
for name in ['tree','map','lexer']:
 row=next(r for r in acq['records'] if r['case']==name);assert row['correct']
 pins += [row[k] for k in ['nativeSource','executable','emissionReceipt','source']]
 source=Path(row['nativeSource']['path']).read_text();assert '#define NATIVE_UNSHARED_ARRAYS 1\n' in source
 ids=re.findall(r'^#define (CID__CTOR_\w+) \d+$',source,re.M)
 before='  if (term_tag(t) != TAG_CTR || term_rfc(t)) {\n';assert source.count(before)==1
 after='  if (term_tag(t) != TAG_CTR || term_rfc(t)'+(' || '+' || '.join('term_aux(t) == '+v for v in ids) if ids else '')+') {\n'
 cfile=out/(name+'.c');cfile.write_text(source.replace(before,after));pins.append(S.identity(cfile))
 changes.append(dict(case=name,input=row['nativeSource'],output=S.identity(cfile),before=before,after=after))
 arms[name]={'baseline':row['executable'],'candidate':str(out/(name+'-candidate'))}
for pin in pins:assert S.identity(pin['path'])==pin
counts={'tree':1280,'map':1152,'lexer':448}
S.save(out/'plan.json',dict(inputs=pins,changes=changes,counts=counts,rounds=3))
report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),builds=[],records=[])
try:
 with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  for name in counts:
   exe=arms[name]['candidate'];command=['taskset','-c','3',recipe['clang'],*recipe['clangArgs'],str(out/(name+'.c')),*recipe['linkArgs'],'-o',exe]
   build=guard.run(command,out/(name+'-build'),time.monotonic()+90);report['builds'].append(build);assert build['complete']
   arms[name]['candidate']=S.identity(exe);pins.append(arms[name]['candidate'])
   n=counts[name];warm=(n//8//16)*16;values=O.points(catalog[name]);expected=[catalog[name]['expected'],O.digest(values,warm),O.digest(values,n)]
   for round in range(3):
    for role in (['baseline','candidate'] if round%2==0 else ['candidate','baseline']):
     dest=out/(name+'-'+role+'-'+str(round));cmd=['taskset','-c','3','python3',str(ROOT/'selfhost/tools/performance/phase46/execute.py'),str(dest/'child.json'),arms[name][role]['path'],'--threads','1','--gpu','off','--',str(n),str(warm)]
     proc=guard.run(cmd,dest,time.monotonic()+45);child=read(dest/'child.json');words=child['stdout'].strip().splitlines()
     correct=proc['complete'] and child['returncode']==0 and not child['stderr'] and len(words)==4 and list(map(int,words[:3]))==expected
     assert correct
     ms=int(words[3]);assert 100<=ms<=child['processSeconds']*1000+2
     report['records'].append(dict(case=name,role=role,round=round,elapsedMs=ms,correct=correct,process=proc,child=child,executable=arms[name][role]));S.save(out/'report.json',report)
 for pin in pins:assert S.identity(pin['path'])==pin
 report['rows']=[]
 for name in counts:
  med={role:statistics.median(r['elapsedMs'] for r in report['records'] if r['case']==name and r['role']==role) for role in ['baseline','candidate']}
  report['rows'].append(dict(case=name,mediansMs=med,speedup=med['baseline']/med['candidate']))
 report['complete']=True
finally:
 report['finished']=time.time();S.save(out/'report.json',report)
print(json.dumps(report.get('rows',[])))
