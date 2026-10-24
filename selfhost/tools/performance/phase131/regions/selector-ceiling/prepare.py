"""Freeze actual selector source and independent scalar-selection oracle; no targets."""
import hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]
SOURCE=ROOT/'selfhost/build/phase131/combined-literals-source01/compiler.bend'

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def save(name,data):
 p=HERE/name;s=data if isinstance(data,str)else json.dumps(data,indent=2,ensure_ascii=False)+'\n'
 if p.exists():assert p.read_text()==s
 else:p.write_text(s)
 return pin(p)
assert pin(SOURCE)['sha256']=='1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
text=SOURCE.read_text();lines=text.splitlines(keepends=True);parts=[];spans=[]
for name in ['KTerm','KDef','p88_string_eq_go','p98_eq_finish','p88_string_eq','kc','kt','atom','dn','dk','da','dx','dc','missing','index_first','index_child_list','index_find','index_bucket']:
 start=next(i for i,l in enumerate(lines)if re.match(r'^(?:def|type) '+re.escape(name)+r'(?:\(| is)',l));end=start+1
 while end<len(lines)and(not lines[end].strip()or lines[end][0].isspace()or lines[end].startswith(') -> ')):end+=1
 while not lines[end-1].strip():end-=1
 if start and lines[start-1].strip()=='@unsafe':start-=1
 block=''.join(lines[start:end]);parts.append(block);spans.append(dict(name=name,firstLine=start+1,lastLine=end,sha256=hashlib.sha256(block.encode()).hexdigest()))
# Independent map algebra returns the selected value, then projects its capacity.
def entry(name,cap):return ('record',name,'local',3,cap,[])
def leaf(h,values):return ('leaf',h,values)
def node(h,mask,a,b):return ('node',h,mask,a,b)
def legacy(kind,h,mask,values):return ('record','',kind,h,mask,values)
missing=('record','','Absent',0,0,[])
def nameof(t):return t[1]if t[0]=='record'else''
def cap(t):return t[4]if t[0]=='record'else(0 if t[0]=='leaf'else t[2])
def bucket(xs,name):return next((t for t in xs if nameof(t)==name),missing)
def lookup(t,name,h):
 if t[0]=='record':
  _,_,kind,stored,mask,xs=t
  if kind=='Absent':return missing
  if mask==0:return bucket(xs,name)if stored==h else missing
  at=int(bool(h&mask));return lookup(xs[at]if len(xs)>at else missing,name,h)
 if t[0]=='leaf':return bucket(t[2],name)if t[1]==h else missing
 if t[2]==0:return bucket([t[3],t[4]],name)if t[1]==h else missing
 return lookup(t[4]if h&t[2]else t[3],name,h)
a,b,u=entry('alpha',11),entry('beta',22),entry('λ雪',33);l=leaf(7,[a,b]);left=leaf(2,[a]);right=leaf(3,[b]);n=node(0,1,left,right);z=node(7,0,a,b);odd=node(0,99,missing,missing)
cases=[(l,'alpha',7),(l,'absent',7),(l,'alpha',8),(leaf(7,[a,entry('alpha',99)]),'alpha',7),(leaf(7,[u]),'λ雪',7),(legacy('Leaf',7,0,[a,b]),'beta',7),(legacy('Absent',7,0,[a,b]),'alpha',7),(n,'alpha',2),(n,'beta',3),(n,'beta',2),(z,'beta',7),(z,'alpha',7),(z,'beta',8),(node(7,0,odd,entry('',55)),'',7),(missing,'',7),(legacy('Node',0,1,[left,right]),'alpha',2)]
values=[cap(lookup(t,k,h))for t,k,h in cases];assert values==[11,0,0,11,33,22,0,11,22,0,22,11,0,99,0,11]
stdout=''.join(str(v)+'\n'+str(v)+'\n'for v in values)+'11\n22\n'
expected=save('expected.json',dict(status=0,stdout=stdout,stderr=''));save('expected.stdout',stdout)
base='import Base\n\n'+'\n'.join(parts)+'\n'+(HERE/'workload.bend').read_text()
needle='def p131sc_query(tree: KDef, name: String, hash: U32) -> U32:\n  p131sc_old(tree,name,hash)';assert base.count(needle)==1
manifest=[]
for role,s in [('original',base),('fused',base.replace(needle,'def p131sc_query(tree: KDef, name: String, hash: U32) -> U32:\n  p131sc_find(tree,name,hash,32)'))]:
 source=save(role+'.bend',s);manifest.append(dict(name='selector-'+role,source=source,expected=expected,expectedStdoutEvidence=expected))
save('cases.json',dict(complete=True,cases=manifest))
save('oracle.json',dict(complete=True,targetsRun=False,frozenBeforeExecution=True,inputs=[pin(SOURCE),pin(__file__),pin(HERE/'workload.bend')],spans=spans,values=values,expected=expected,timed=dict(entries=64,hash=7,eachRepeat=1,stdoutPrefix='1\nREPETITIONS\n',elapsed='milliseconds'),scope='Exact owning selector and projection vs explicit scalar continuation fusion. Samechecked producer andruntime, no borrowed-return ABI or production edit. Existing independent root/alias controls are supplemented by scalar lookup cases; no whole-compiler gain claim.'))
print(json.dumps(dict(prepared=True,cases=str(HERE/'cases.json'),values=values)))
