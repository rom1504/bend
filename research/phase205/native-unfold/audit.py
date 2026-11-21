"""Read-only shape audit of an independently captured checked AST; not Bend execution."""
import gzip,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
P=ROOT/'selfhost/build/phase200/p205-shapes01/lexer.json.gz'
def clean(t):
 if t['t']=='Ann':return clean(t['k'][0])
 d={k:v for k,v in t.items() if k!='k'};d['k']=[] if t['t'] in ('Var','Ref') else list(map(clean,t.get('k',[])));return d
def walk(t):
 yield t
 for x in t.get('k',[]):yield from walk(x)
def call(t):
 args=[]
 while t['t']=='App':args.insert(0,t['k'][1]);t=t['k'][0]
 return (t['n'],args) if t['t']=='Ref' else ('',[])
def check(d):
 b=clean(d['checked']);index=0
 while b['t']=='Lam':index+=1;b=b['k'][0]
 if b['t']!='Mat' or b['n']!='SNil':return None
 z,con=b['k'];assert con['t']=='Mat' and con['n']=='SCon' and con['k'][1]['t']=='Efq'
 b=con['k'][0]
 if b['t']=='Mat':assert b['n']=='Chr' and b['k'][1]['t']=='Efq';b=b['k'][0]
 assert b['t']=='Lam' and b['k'][0]['t']=='Lam'
 tail=b['k'][0];name=d['name'];refs=[x for x in walk(b) if x['t']=='Ref' and x['n']==name]
 assert len(refs)==1 and not any(x['t']=='Ref' and x['n']==name for x in walk(z))
 allcalls=[call(x) for x in walk(tail['k'][0]) if x['t']=='App'];calls=[args for n,args in allcalls if n==name and len(args)==d['arity']]
 assert len(calls)==1;arg=calls[0][index]
 assert arg['t']=='Var' and arg['i']==tail['i']
 assert sum(x['t']=='Var' and x['i']==tail['i'] for x in walk(tail['k'][0]))==1
 return dict(name=name,arity=d['arity'],stringArgument=index,selfCalls=1,tailUses=1)
def main():
 data=json.loads(gzip.decompress(P.read_bytes()));defs={r['name']:r for r in data['defs']};row=check(defs['gen']);lit=clean(defs['tpl']['checked']);assert lit['t']=='Lit' and lit['n']=='String'
 line=clean(defs['line']['checked']);calls=[a for n,a in (call(x) for x in walk(line)) if n=='gen' and len(a)==3]
 assert len(calls)==1 and calls[0][0]['t']=='Ref' and calls[0][0]['n']=='tpl'
 row.update(literalCharacters=len(lit['s']),predictedSelections=len(lit['s'])+1,caller='line',literalSource='nullary exact String literal',status='independent captured-AST shape audit only; native evaluator not executed')
 report=dict(capture=str(P.relative_to(ROOT)),captureSHA256=hashlib.sha256(P.read_bytes()).hexdigest(),witness=row)
 out=Path(__file__).with_name('shape-audit.json');out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(row))
if __name__=='__main__':main()
