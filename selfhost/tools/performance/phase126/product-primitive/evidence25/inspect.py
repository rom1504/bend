"""Static QBE structure only. Never executes or compiles a target."""
from pathlib import Path
import re,json,collections,hashlib
ROOT=Path(__file__).resolve().parents[6]
OUT=Path(__file__).resolve().parent
CASES=['coverage-record-aggregation-256','test-evening-program','coverage-map-churn-128']
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def decode(s):
 m=re.fullmatch(r'(.*?)FID_((?:\d+_)+)',s)
 return m[1]+''.join(chr(int(n)) for n in m[2].split('_') if n) if m else s
def functions(p):
 text=p.read_text(); found=list(re.finditer(r'^(?:export )?function .*?\$([^\s(]+)\(',text,re.M));out={}
 for i,m in enumerate(found):
  end=found[i+1].start() if i+1<len(found) else len(text)
  body=text[m.start():end];body=body[:body.index('\n}')+2]
  out[decode(m[1])]=(m[1],text[:m.start()].count('\n')+1,body)
 return out
def summary(f):
 sym,line,body=f;calls=collections.Counter(decode(s) for s in re.findall(r'call \$([^\s(]+)',body))
 ops=collections.Counter(re.findall(r'call \$p111_rt_op\(l %state, w (\d+)',body))
 return dict(symbol=sym,line=line,lines=len(body.splitlines()),calls=dict(calls),ops=dict(ops))
report=dict(targetsRun=False,scope='Static sites and function identities only; not dynamic counts, samples, cycles or speed.',inputs=[pin(Path(__file__))],cases=[])
for name in CASES:
 parent=ROOT/'selfhost/build/phase118'/('p125-final-remaining06' if name=='test-evening-program' else 'p125-verified-families06')/(name+'.ssa')
 candidate=ROOT/'selfhost/build/phase118/p126-observer25-emit'/(name+'.ssa')
 a,b=functions(parent),functions(candidate);pa={k:v for k,v in a.items() if k.startswith('p113d_')};pb={k:v for k,v in b.items() if k.startswith('p113d_')}
 report['inputs'] += [pin(parent),pin(candidate)]
 row=dict(name=name,parentPrivateCount=len(pa),candidatePrivateCount=len(pb),addedPrivate=sorted(set(pb)-set(pa)),removedPrivate=sorted(set(pa)-set(pb)),functions={})
 for variant,funcs in [('parent',a),('candidate',b)]:
  selected={k:v for k,v in funcs.items() if any(k.endswith(n) for n in ['$direct.Map.bit','$direct.Map.bit.at','$direct.Map.bit.go','$product.Map.bit','$product.Map.bit.at','$product.Map.bit.go','$p118borrow.read.Map.bit.go'])}
  row['functions'][variant]={k:summary(v) for k,v in selected.items()}
  for k,v in selected.items():
   label=re.sub(r'[^A-Za-z0-9_-]','-',k)
   text=re.sub(r'FID_(?:\d+_)+',lambda m:decode(m[0]),v[2])
   (OUT/(name+'-'+variant+'-'+label+'.ssa')).write_text(text+'\n')
 report['cases'].append(row)
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
for row in report['cases']:
 print(row['name'],row['parentPrivateCount'],row['candidatePrivateCount'],'added',len(row['addedPrivate']))
 print('\n'.join(row['addedPrivate']))
 print(json.dumps(row['functions']['candidate'],indent=2))
