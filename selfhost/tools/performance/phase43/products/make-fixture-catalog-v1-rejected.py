"""Independent tiny source qualification catalog; does not compile or execute."""
from pathlib import Path
import hashlib,json
base=Path(__file__).resolve().parent
sources={name:base/'fixtures'/name for name in ['prefix-controls.bend','pair-controls.bend']}
cases=[]
def add(file,export,args,expected):
 p=sources[file];data=p.read_bytes()
 cases.append(dict(id='products-'+export.replace('.','-')+'-'+ '-'.join(map(str,args)),family='products-source-controls',category='diagnostic',partition='development',description='Independent Phase43 source admission/refusal and pair ordering controls',source=dict(path='fixtures/'+file,sha256=hashlib.sha256(data).hexdigest(),bytes=len(data),provenance=dict(kind='phase43-authored-products-control',design='design/phase43/products.md')),point=dict(exportName=export,args=args,expected=expected),sets=['core','broad','full'],oracle='Independent Python ordered U32 recurrence and explicit zero BST checksum'))
add('prefix-controls.bend','bench',[0,0],0)
for n,seed in [(0,0),(1,17),(7,17),(32,4294967295)]:
 a,b=seed,1
 for _ in range(n):a,b=(3*a+b)&0xffffffff,(a-b)&0xffffffff
 add('pair-controls.bend','p43.pair.result',[n,seed],(17*a+b)&0xffffffff)
 a,b=(1,seed)if n%2 else(seed,1)
 add('pair-controls.bend','p43.pair.shared.result',[n,seed],(17*a+b)&0xffffffff)
 add('pair-controls.bend','p43.pair.escape.result',[n,seed],(17*seed+1)&0xffffffff)
base.joinpath('fixture-catalog.json').write_text(json.dumps(dict(schemaVersion=1,upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',scope='Authored source qualification; not prevalence or timing evidence',cases=cases,oracleProducer=dict(path='make-fixture-catalog.py',sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())),indent=2)+'\n')
print(base/'fixture-catalog.json')
