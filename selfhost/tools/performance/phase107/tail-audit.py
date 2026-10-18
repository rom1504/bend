#!/usr/bin/env python3
import importlib.util,json,sys,subprocess,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
out=Path(sys.argv[1]).resolve();report=dict(complete=False,rows=[],native=[],jobs=[])
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def run(cmd,expected=None):
 cmd=list(map(str,cmd));start=time.perf_counter();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=20);report['jobs'].append(dict(command=cmd,seconds=time.perf_counter()-start,returncode=r.returncode,stdout=r.stdout,stderr=r.stderr));save();assert r.returncode==0,(cmd,r.stderr)
 if expected is not None:assert r.stdout==str(expected)+'\n'
qbe=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe';cl=ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift';runner=out/'runner.o';run(['gcc','-O2','-c',HERE.parent/'phase106/cranelift/runner.c','-o',runner])
try:
 for row in json.loads((out/'rows.json').read_text()):
  name,stem=row['name'],row['stem'];before=json.loads(Path(stem+'.before.json').read_text());after=json.loads(Path(stem+'.json').read_text());report['rows'].append(C.audit_tail(name,before,after));save()
  if name not in ['tail_sum','tail_snapshot','tail_reset']:continue
  controls=[r for r in json.loads((HERE/'inline/tail-controls.json').read_text())['cases'] if r['fixture']==name]
  for backend in ['gcc','qbe','cl']:
   obj=out/(name+'-'+backend+'.o');binary=out/(name+'-'+backend)
   if backend=='gcc':run(['gcc','-O2','-c',stem+'.c','-o',obj])
   elif backend=='cl':run([cl,stem+'.json',obj,'speed_and_size'])
   else:run([qbe,'-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
   run(['gcc',runner,obj,'-o',binary])
   for control in controls:
    run([binary,'--expect',control['expected'],*control['args']],control['expected']);report['native'].append(dict(name=name,backend=backend,**control))
 report['complete']=True
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,pairs=len(report['rows']),native=len(report['native']))))
