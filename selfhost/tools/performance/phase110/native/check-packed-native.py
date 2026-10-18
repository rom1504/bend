#!/usr/bin/env python3
"""Check the exact packed-byte matcher as an acquired native program; guard externally."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__)
for n in ['prepared','image','out']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists()
pin=lambda p:dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(r):assert pin(Path(r['file']))['sha256']==r['sha256'] and pin(Path(r['file']))['bytes']==r['bytes']
m=json.loads((a.prepared/'manifest.json').read_text());build=json.loads((a.image/'report.json').read_text());assert m['complete'] and m['inverseExact'] and build['complete']
text=Path(m['base']['file']).read_text(); change=lambda at:text[:at]+('y' if text[at]=='x' else 'x')+text[at+1:]
cases=[('exact',text,True),('empty','',False),('prefix-truncated',text[:1024],False),('last-truncated',text[:-1],False),('suffix',text+'\n',False),('prefix',' '+text,False),('first',change(0),False),('middle',change(len(text)//2),False),('chunk-last',change(m['chunkLimit']-1),False),('chunk-first',change(m['chunkLimit']),False),('last',change(len(text)-1),False)]
for name,at in [('same-low-byte-first',0),('same-low-byte-boundary',m['chunkLimit']),('same-low-byte-last',len(text)-1)]:cases.append((name,text[:at]+chr(ord(text[at])+256)+text[at+1:],False))
inputs=[pin(Path(__file__)),pin(a.prepared/'manifest.json'),m['source'],m['module'],m['base'],pin(a.image/'report.json'),build['binary']]
for r in inputs:verify(r)
out.mkdir();rows=[]
for name,value,expected in cases:
 file=out/(name+'.input');file.write_text(value);rows.append(dict(name=name,input=pin(file),expected=('True' if expected else 'False')+'\n'))
plan=dict(kind='phase110-native-packed-matcher-controls',complete=True,targetsRun=False,frozen=time.time(),inputs=inputs,cases=rows);(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
r=dict(kind=plan['kind'],complete=False,inputs=[*inputs,pin(out/'plan.json')],rows=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
try:
 for case in rows:
  verify(case['input']);cmd=[build['binary']['file'],'--threads','1','--gpu','off','--','chunk-probe',case['input']['file']];t=time.monotonic();c=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=10)
  row=dict(name=case['name'],command=cmd,status=c.returncode,seconds=time.monotonic()-t,stdout=c.stdout.decode(),stderr=c.stderr.decode(),expected=case['expected']);r['rows'].append(row);save();assert c.returncode==0 and c.stdout.decode()==case['expected'] and not c.stderr,case['name']
 for item in r['inputs']:verify(item)
 r['complete']=True;save();print(json.dumps(dict(complete=True,controls=len(rows))))
except BaseException as error:r['error']=repr(error);save();raise
