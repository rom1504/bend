#!/usr/bin/env python3
"""Diagnostic only: remove eager sealing from emitted constructor stores."""
import argparse,difflib,importlib.util,json,time,statistics,sys,re
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,ROOT/p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=mod('support','selfhost/tools/performance/programs/support.py');O=mod('oracle73','selfhost/tools/performance/phase70/coverage/oracle-v2.py')
read=lambda p:json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();a.out.mkdir(exist_ok=False)
rows={};pins=[S.identity(__file__),S.identity(O.__file__)]
for role,paths in [('baseline',['phase72/compiler02-coverage-rest','phase72/compiler02-coverage02']),('upstream',['phase70/coverage-baseline01','phase70/compiler02-coverage-baseline-holdouts01'])]:
 for path in paths:
  ar=read(ROOT/'selfhost/build'/path/'report.json');assert ar['complete'];recipe=read(ar['recipe']['path']);pins.append(ar['recipe'])
  for row in ar['records']:
   if row['role']==('selfhost' if role=='baseline' else role):rows[row['case'],role]=(row,recipe)
catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase70/coverage/cases-v2.json')};plan=read(ROOT/'selfhost/build/phase73/counts.json');report=dict(complete=False,diagnosticOnly=True,inputs=pins,records=[],builds=[])
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 def run(cmd,d,secs=90):return g.run(['taskset','-c','3',*map(str,cmd)],d,time.monotonic()+secs)
 for case in ['list-pipeline','bst','array-map']:
  row,recipe=rows[case,'baseline'];source=Path(row['nativeSource']['path']);assert S.identity(source)==row['nativeSource'];out=a.out/case;out.mkdir();original=source.read_text()
  candidate,n=re.subn(r'(e.mem\[nd_\d+ \+ \d+\] = )rfc_seal\(e, ([^\n;]+)\);',r'\1\2;',original);assert n
  code=out/'program.c';code.write_text(candidate);(out/'delta.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),candidate.splitlines(True),fromfile=str(source),tofile=str(code))))
  exe=out/'program';b=dict(case=case,original=row['nativeSource'],source=S.identity(code),removedSourceSites=n);report['builds'].append(b);b['build']=run([recipe['clang'],*recipe['clangArgs'],code,*recipe['linkArgs'],'-o',exe],out/'build');S.save(a.out/'report.json',report);assert b['build']['complete'];b['executable']=S.identity(exe)
  binaries={'baseline':row['executable'],'candidate':b['executable'],'upstream':rows[case,'upstream'][0]['executable']};n,w=plan[case]['repetitions'],plan[case]['warmups'];expected=[catalog[case]['expected'],O.digest(O.points(catalog[case]),w),O.digest(O.points(catalog[case]),n)]
  for round in range(3):
   roles=list(binaries);roles=roles[round:]+roles[:round]
   for role in roles:
    dest=out/(role+str(round));binary=binaries[role];assert S.identity(binary['path'])==binary
    proc=run(['python3',ROOT/'selfhost/tools/performance/phase46/execute.py',dest/'child.json',binary['path'],'--threads','1','--gpu','off','--',n,w],dest,45);child=read(dest/'child.json');words=child['stdout'].splitlines();ok=proc['complete'] and child['returncode']==0 and not child['stderr'] and len(words)==4 and list(map(int,words[:3]))==expected;ms=int(words[-1]) if ok else None;r=dict(case=case,role=role,round=round,process=proc,child=child,expected=expected,correct=ok,elapsedMs=ms,qualified=ok and 100<=ms<=child['processSeconds']*1000+2);report['records'].append(r);S.save(a.out/'report.json',report);assert r['qualified'],r
  medians={role:statistics.median(r['elapsedMs'] for r in report['records'] if r['case']==case and r['role']==role) for role in binaries};b['medians']=medians;print(json.dumps(dict(case=case,medians=medians)),flush=True)
report['complete']=True;S.save(a.out/'report.json',report)
