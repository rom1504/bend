"""Closed-equation certificate for static producer/token-consumer compositions.

No workload/function-name lookup. The reference graph names are internal schema
variables; each is bound to an input definition by complete alpha-equivalence.
Unsupported syntax/equations leave input bytes unchanged. Output remains Bend
and must pass the real native compiler/checker. This is a staged frontend, not
an installed/native compiler pass.
"""
import json,re,importlib.util
from pathlib import Path
P=Path(__file__).resolve().parent
TOKEN=re.compile(r'\s+|\#[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*|\d+n?|[^\s]')
IDENT=re.compile(r'^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*$')
FIXED=set('def type is Data match case U32 Nat String Char Bool True False SCon SNil Chr'.split())
def tokens(s):return [t for t in TOKEN.findall(s) if not t.isspace() and not t.startswith('#')]
def definitions(source):
 masked=list(source)
 for t in TOKEN.finditer(source):
  if t[0].startswith(('\"', "'", '#')):
   for j in range(t.start(),t.end()):
    if masked[j]!='\n':masked[j]=' '
 matches=list(re.finditer(r'(?m)^(def|type)\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\b',''.join(masked)));out={}
 for i,m in enumerate(matches):
  end=matches[i+1].start() if i+1<len(matches) else len(source)
  # A trailing top-level comment belongs to neither declaration semantically.
  text=source[m.start():end];assert m[2] not in out
  out[m[2]]=dict(kind=m[1],start=m.start(),end=end,text=text,tokens=tokens(text))
 return out

def split_args(s):
 depth=0;quote=None;escape=False;parts=[];start=0
 for i,c in enumerate(s):
  if quote:
   if escape:escape=False
   elif c=='\\':escape=True
   elif c==quote:quote=None
  elif c in '\"\'':quote=c
  elif c in '({[<':depth+=1
  elif c in ')}]>':depth-=1
  elif c==',' and depth==0:parts.append(s[start:i].strip());start=i+1
  if depth<0:raise ValueError('delimiter')
 if depth or quote:raise ValueError('delimiter')
 parts.append(s[start:].strip());return parts

def call(s):
 m=re.fullmatch(r'([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\((.*)\)',s,re.S)
 if not m:return None
 return m[1],split_args(m[2])

def certify(source,consumer,producer,gap,schema):
 ds=definitions(source);rs=schema['definitions'];globals_=set(rs)|set(schema['constructors']);bindings={};pending=[];done=set();locals_=[];numbers=[]
 def bind(r,a):
  if not IDENT.fullmatch(a):raise ValueError('global identifier')
  if r in bindings and bindings[r]!=a:raise ValueError('inconsistent global')
  if r not in bindings:
   if a in bindings.values():raise ValueError('global alias')
   bindings[r]=a
   if r in rs:pending.append((r,a))
 bind(schema['consumer'],consumer);bind(schema['producer'],producer);bind(schema['gap'],gap)
 while pending:
  r,a=pending.pop()
  if r in done:continue
  if a not in ds or ds[a]['kind']!=rs[r]['kind']:raise ValueError('missing definition')
  rt=rs[r]['tokens'];at=ds[a]['tokens']
  if len(rt)!=len(at):raise ValueError('equation shape')
  local={}
  for x,y in zip(rt,at):
   if x in globals_:bind(x,y)
   elif IDENT.fullmatch(x) and x not in FIXED and not x.startswith(('U32.','Bool.','String.')):
    if not IDENT.fullmatch(y) or y in FIXED:raise ValueError('local identifier')
    if x in local and local[x]!=y:raise ValueError('local binding')
    if x not in local and y in local.values():raise ValueError('local capture')
    local[x]=y
   elif r in schema['pureNumericBodies'] and x.isdigit() and y.isdigit():
    if int(y)>0xffffffff:raise ValueError('word literal')
    numbers.append([r,x,y])
   elif x!=y:raise ValueError('primitive/equation mismatch')
  locals_.append(set(local.values()));done.add(r)
 if any(names.intersection(bindings.values()) for names in locals_):raise ValueError('global captured by local')
 return bindings,dict(definitions=len(done),numericSpecializations=numbers)

def transform(source):
 if '@' in source or re.findall(r'(?m)^import\s+([^\n]+)',source)!=['Base']:
  return source,dict(admitted=False,reason='unsupported imports/attributes')
 schema=json.loads((P/'schema.json').read_text());ds=definitions(source)
 for d in ds.values():
  if d['kind']=='type' and set(re.findall(r'(?m)^\s+([A-Za-z_]\w*)\{',d['text'])).intersection({'True','False','SCon','SNil','Chr'}):
   return source,dict(admitted=False,reason='base constructor shadow')
 if any(n in FIXED or n.startswith(('U32.','Bool.','String.')) for n in ds):return source,dict(admitted=False,reason='primitive shadow')
 spec=importlib.util.spec_from_file_location('token_algebra',P/'prepare-v2.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
 refusals=[]
 for name,d in ds.items():
  if d['kind']!='def':continue
  # Only an entire final return expression is replaced. Earlier bindings stay.
  lines=d['text'].splitlines(keepends=True);significant=[i for i,l in enumerate(lines) if l.strip() and not l.lstrip().startswith('#')]
  if not significant:continue
  last=significant[-1];expr=lines[last].strip()
  if len(significant)!=2 or not re.search(r'->\s*U32\s*:',lines[0]):continue
  try:
   outer=call(expr)
   if not outer or len(outer[1])!=2:continue
   inner=call(outer[1][0]);state=outer[1][1]
   if not inner or len(inner[1])!=3 or inner[1][2]!='0':continue
   sm=re.fullmatch(r'\(([A-Za-z_]\w*)\{\},\s*0\)',state)
   if not sm:continue
   value=inner[1][0];tc=call(value)
   if tc and tc[1]==['']:
    if tc[0] not in ds:continue
    td=ds[tc[0]]['text'];value=''.join(l.strip() for l in td.splitlines()[1:] if l.strip() and not l.lstrip().startswith('#'))
   if not value.startswith('"') or '\\' in value:continue
   template=json.loads(value)
   bindings,proof=certify(source,outer[0],inner[0],sm[1],schema)
   entry_names=set(re.findall(r'([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\s*:',lines[0]))
   if entry_names.intersection(bindings.values()):raise ValueError('entry shadows helper')
   plan,certificate=mod.specialize(template,'p200.plan')
   if not certificate['admitted']:
    refusals.append(dict(entry=name,reason='template class boundary',certificate=certificate));continue
   if any(n.startswith('p200.') for n in tokens(source)):raise ValueError('fresh namespace collision')
   # Kernel calls bind to the discovered source definitions; no user spelling
   # is used to decide admission. The immutable schema defines these roles.
   helper=mod.KERNEL+'\n'+plan
   substitutions={r:bindings[r] for r in ['prng','fnv','mix','salt']}
   helper=re.sub(r'\b(?:prng|fnv|mix|salt)\b',lambda m:substitutions[m[0]],helper)
   # Before the discovered entry, so ordinary declaration checking sees helpers.
   prefix=''.join(lines[:last]);suffix=''.join(lines[last+1:]);indent=lines[last][:-len(lines[last].lstrip())]
   replacement=helper+'\n'+prefix+indent+'p200.plan('+inner[1][1]+')\n'+suffix
   result=source[:d['start']]+replacement+source[d['end']:]
   return result,dict(admitted=True,entry=name,bindings=bindings,proof=proof,template=template,certificate=certificate)
  except (ValueError,KeyError,AssertionError) as e:refusals.append(dict(entry=name,reason=str(e)))
 return source,dict(admitted=False,refusals=refusals)

if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 s,report=transform(a.source.read_text());a.out.write_text(s);print(json.dumps(report,indent=2,ensure_ascii=False))
