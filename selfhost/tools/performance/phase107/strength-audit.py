#!/usr/bin/env python3
"""Full-width modular oracle and native boundary subset for strength reduction."""
import json,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True;HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106';sys.path.insert(0,str(P106))
from reference import Interpreter
out=Path(sys.argv[1]).resolve();ctl=json.loads((out/'controls.json').read_text());report=dict(complete=False,rows=[],models=0,native=0,jobs=[])
(out/'method.py').write_bytes(Path(__file__).read_bytes())
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def run(cmd,want=None,code=0):
 start=time.perf_counter();cmd=list(map(str,cmd));r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
 report['jobs'].append(dict(command=cmd,seconds=time.perf_counter()-start,status=r.returncode,stdout=r.stdout,stderr=r.stderr));assert r.returncode==code,(cmd,r.stderr)
 if want is not None:assert r.stdout==str(want)+'\n' and r.stderr=='',(cmd,r.stdout,want)
try:
 runner=out/'runner.o';run(['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner])
 for row in json.loads((out/'rows.json').read_text()):
  if not row['valid']:assert not row['changed'];continue
  stem=row['stem'];programs=[json.loads(Path(stem+s).read_text())for s in ['.before.json','.json']];cases=[]
  if 'extra'in row:
   e=row['extra'];cases=[([int(x)],int(y))for x,y in zip(e['args'],e['expected'])]
  else:
   width,factor=row['width'],row['factor'];mask=(1<<width)-1
   for x,stored in zip(ctl['valuesByWidth'][str(width)],ctl['expectedProducts'][str(width)][str(factor)]):
    x=int(x);want=(x*factor)&mask;assert want==int(stored)
    cases.extend([([x],want)]if width==32 else [([x,want],1),([x,want^(1<<32)],0)])
  for args,want in cases:
   for p in programs:assert Interpreter(p).run(args)['value']==want,(row['name'],args,want);report['models']+=1
  report['rows'].append(dict(name=row['name'],changed=row['changed'],observations=[dict(args=a,expected=v)for a,v in cases]));save()
  if not row['native']:continue
  for backend in ['gcc','qbe','cl']:
   obj=out/(row['name']+'-'+backend+'.o');binary=out/(row['name']+'-'+backend)
   if backend=='gcc':run(['gcc','-O2','-c',stem+'.c','-o',obj])
   elif backend=='cl':run([ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift',stem+'.json',obj,'speed_and_size'])
   else:run([ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe','-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
   run(['gcc',runner,obj,'-o',binary])
   for args,want in cases:run([binary,'--expect',want,*args],want);report['native']+=1
   run([binary,'--expect',cases[0][1]^1,*cases[0][0]],code=1)
 report['complete']=True
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,programs=len(report['rows']),models=report['models'],native=report['native'])))
