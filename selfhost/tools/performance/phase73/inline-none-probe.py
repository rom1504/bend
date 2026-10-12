#!/usr/bin/env python3
"""Saved-C inlining falsifier; only compiler-emitted private worker hints change."""
import argparse,importlib.util,json,time,statistics,sys,re,difflib
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,ROOT/p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=mod('support','selfhost/tools/performance/programs/support.py');O=mod('oracle73','selfhost/tools/performance/phase70/coverage/oracle-v2.py');O6=mod('oracle6','selfhost/tools/performance/phase46/oracle.py')
read=lambda p:json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--acquired',nargs='+',required=True);p.add_argument('--cases',default='expression,tree,array-map,lexer');a=p.parse_args();a.out.mkdir(exist_ok=False)
rows={};pins=[S.identity(__file__),S.identity(O.__file__),S.identity(O6.__file__)]
for path in a.acquired:
 ar=read(Path(path)/'report.json');assert ar['complete'];recipe=read(ar['recipe']['path']);pins+=[ar['recipe'],S.identity(Path(path)/'report.json')]
 for row in ar['records']:
  if row['role']=='selfhost':rows[row['case']]=(row,recipe)
catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase70/coverage/cases-v2.json')};cat6={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')};plan=read(ROOT/'selfhost/build/phase73/counts.json');plan.update(tree=dict(repetitions=1280,warmups=160),lexer=dict(repetitions=448,warmups=48))
report=dict(complete=False,diagnosticOnly=True,inputs=pins,records=[],builds=[])
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 def run(cmd,d,secs=90):return g.run(['taskset','-c','3',*map(str,cmd)],d,time.monotonic()+secs)
 for case in a.cases.split(','):
  row,recipe=rows[case];source=Path(row['nativeSource']['path']);assert S.identity(source)==row['nativeSource'];out=a.out/case;out.mkdir();original=source.read_text()
  candidate,n=re.subn(r'(?m)^NF_INLINE Term (NF_FID_)',r'INLINE Term \1',original);assert n
  code=out/'program.c';code.write_text(candidate);(out/'delta.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),candidate.splitlines(True),fromfile=str(source),tofile=str(code))))
  exe=out/'program';b=dict(case=case,original=row['nativeSource'],source=S.identity(code),changedHints=n);report['builds'].append(b);b['build']=run([recipe['clang'],*recipe['clangArgs'],code,*recipe['linkArgs'],'-o',exe],out/'build');S.save(a.out/'report.json',report);assert b['build']['complete'];b['executable']=S.identity(exe)
  binaries={'baseline':row['executable'],'candidate':b['executable']};n,w=plan[case]['repetitions'],plan[case]['warmups'];o,c=(O,catalog[case]) if case in catalog else (O6,cat6[case]);expected=[c['expected'],o.digest(o.points(c),w),o.digest(o.points(c),n)]
  for round in range(4):
   roles=list(binaries);roles=roles[round%2:]+roles[:round%2]
   for role in roles:
    dest=out/(role+str(round));binary=binaries[role];assert S.identity(binary['path'])==binary
    proc=run(['python3',ROOT/'selfhost/tools/performance/phase46/execute.py',dest/'child.json',binary['path'],'--threads','1','--gpu','off','--',n,w],dest,45);child=read(dest/'child.json');words=child['stdout'].splitlines();ok=proc['complete'] and child['returncode']==0 and not child['stderr'] and len(words)==4 and list(map(int,words[:3]))==expected;ms=int(words[-1]) if ok else None;r=dict(case=case,role=role,round=round,process=proc,child=child,expected=expected,correct=ok,elapsedMs=ms,qualified=ok and 100<=ms<=child['processSeconds']*1000+2);report['records'].append(r);S.save(a.out/'report.json',report);assert r['qualified'],r
  medians={role:statistics.median(r['elapsedMs'] for r in report['records'] if r['case']==case and r['role']==role) for role in binaries};b['medians']=medians;print(json.dumps(dict(case=case,medians=medians)),flush=True)
report['complete']=True;S.save(a.out/'report.json',report)
