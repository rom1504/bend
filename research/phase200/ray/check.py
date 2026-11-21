import argparse,hashlib,json,subprocess,time
from pathlib import Path
H=Path(__file__).resolve().parent;ROOT=H.parents[2]
def pin(p):
 p=Path(p);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def checked(p):assert pin(p['file'])['sha256']==p['sha256'];return p['file']
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
f=json.loads((H/'runtime-freeze.json').read_text());r=dict(complete=False,freeze=pin(H/'runtime-freeze.json'),commands=[]);start=time.monotonic()
def save():(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=8);r['commands'].append(dict(argv=list(map(str,cmd)),exit=q.returncode,stdout=q.stdout,stderr=q.stderr));save();assert q.returncode==0,(q.stdout,q.stderr);return q.stdout
try:
 for v in f['inputs']:checked(v)
 cc=checked(f['compiler']);rt=checked(f['runtime']);helper=a.out/'sqrt-keep.o';test=a.out/'check'
 run([cc,'-c','-msse2','-mno-avx',H/'sqrt-keep.s','-o',helper]);r['helper']=pin(helper)
 run([cc,'-O2','-std=c11','-msse2','-mno-avx','-no-pie',H/'sqrt-check.c',H/'register-check.s',helper,rt,'-pthread','-lm','-o',test]);r['test']=pin(test)
 r['result']=json.loads(run([test]));r['complete']=True
except Exception as e:r['error']=repr(e);raise
finally:r['seconds']=time.monotonic()-start;save()
