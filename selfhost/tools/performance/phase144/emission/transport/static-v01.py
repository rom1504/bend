"""Streaming read-only transport census and focused QBE extraction."""
import collections,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent

def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
events=json.loads((HERE/'profile-events.json').read_text());freq=collections.Counter(e['dispatchContext']['symbol'] for e in events['events'] if e.get('dispatchContext'));owners={e['dispatchContext']['symbol']:e['dispatchContext']['loweredOwner'] for e in events['events'] if e.get('dispatchContext')}
oldmap=json.loads(Path(events['inputs'][-1]['file']).read_text());old=Path(oldmap['identities']['qbe']['file']);new=ROOT/'selfhost/build/phase130/p144-final03-q3/program.ssa'
func=re.compile(r'^(?:export )?function \w+ \$([^ (]+)\(');call=re.compile(r'call \$(p111_rt_jump|p111_rt_return|p111_rt_apply)\((.*)\)')
result=dict(kind='phase144-streamed-transport-census',complete=False,inputs=[pin(__file__),pin(HERE/'profile-events.json'),pin(old),pin(new)],products=[])
for label,p in [('profiled',old),('final03',new)]:
 counts=collections.Counter();fcounts=collections.Counter();wanted={};current=None;body=[];line0=0;descriptor=None
 for number,line in enumerate(p.open(),1):
  m=func.match(line)
  if m:current=m[1];line0=number;body=[]
  if current in freq:body.append(line)
  cm=call.search(line)
  if cm:
   target,args=cm.groups();last=args.rsplit(',',1)[-1].strip();count=int(last[2:]) if last.startswith('w ') and last[2:].isdigit() else ('2' if target=='p111_rt_apply' else 'dynamic')
   counts[(target,str(count))]+=1
   if current in freq:fcounts[(current,target,str(count))]+=1
  if line.startswith('export data $p111_program ='):descriptor=line.strip()
  if line.strip()=='}' and current:
   if current in freq:
    raw=''.join(body);wanted[current]=dict(line=line0,lines=len(body),bytes=len(raw.encode()),sha256=hashlib.sha256(raw.encode()).hexdigest(),profileSamples=freq[current],owner=owners[current],calls=[dict(helper=k[1],count=k[2],sites=v) for k,v in fcounts.items() if k[0]==current])
    if current in [n for n,_ in freq.most_common(8)]:
     name=''.join(c if c.isalnum() or c in '-_.' else '_' for c in owners[current]);(HERE/f'{label}-{line0}-{name}.ssa').write_text(raw)
   current=None;body=[]
 singleton=collections.Counter();ambiguous=0
 for n,x in wanted.items():
  shapes={(v['helper'],v['count']) for v in x['calls']}
  if len(shapes)==1:singleton[next(iter(shapes))]+=x['profileSamples']
  else:ambiguous+=x['profileSamples']
 result['products'].append(dict(label=label,qbe=pin(p),descriptor=descriptor,staticCalls=[dict(helper=k[0],count=k[1],sites=v) for k,v in sorted(counts.items())],sampledContextFunctions=sorted(wanted.values(),key=lambda x:-x['profileSamples']),contextSingleTransferShape=[dict(helper=k[0],count=k[1],contextSamples=v) for k,v in singleton.most_common()],contextAmbiguousSamples=ambiguous,scope='Static call counts are not dynamic frequencies. Single-shape active contexts are conditional attribution, not a recovered caller or logical stack.'))
result['complete']=True;(HERE/'static-v01.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps([{k:r[k] for k in ['label','staticCalls','contextSingleTransferShape','contextAmbiguousSamples']} for r in result['products']],indent=2))
