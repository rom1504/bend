#!/usr/bin/env python3
"""P5-011 isolated transport overlay over a genuinely checked frozen project."""
import hashlib,json,pathlib,re,shutil,sys
source=pathlib.Path(sys.argv[1]).resolve(); proof=pathlib.Path(sys.argv[2]).resolve(); out=pathlib.Path(sys.argv[3]).resolve()
assert not out.exists();meta=json.loads(proof.read_text());sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
assert meta['stage']=='upstream-bootstrap' and meta['provenance']['verifiedAfterBuild']
assert sha(meta['apiPath'])==meta['apiSha256'] and sha(meta['source'])==meta['sourceSha256']
inputs=[{'file':str(proof),'sha256':sha(proof)},{'file':meta['apiPath'],'sha256':meta['apiSha256']}]+meta['provenance']['inputs']
for x in inputs:assert sha(x['file'])==x['sha256'],x['file']
for m in meta['modules']:assert sha(source/m['file'])==m['sha256'],m['file']
project=out/'project';project.mkdir(parents=True);shutil.copytree(source/'src',project/'src');(project/'tools').mkdir();(project/'dist').mkdir()
for n in ['typed-driver','stage0-library','assemble','compiler-abi','native-build','node-resource-args']:
 p=source/'tools'/f'{n}.mjs';inputs.append({'file':str(p),'sha256':sha(p)});shutil.copyfile(p,project/'tools'/p.name)
fragment=pathlib.Path(__file__).with_name('parser-errors-render.bend');inputs.extend([{'file':str(pathlib.Path(__file__).resolve()),'sha256':sha(__file__)},{'file':str(fragment.resolve()),'sha256':sha(fragment)}])
def once(s,a,b):
 assert s.count(a)==1,(a,s.count(a));return s.replace(a,b)
def arguments(s,start):
 depth=0;quote=None;esc=False;parts=[];last=start+1
 for i in range(start,len(s)):
  c=s[i]
  if quote:
   if esc:esc=False
   elif c=='\\':esc=True
   elif c==quote:quote=None
  elif c in ['"',"'"]:quote=c
  elif c in '([{':depth+=1
  elif c in ')]}':
   depth-=1
   if depth==0:parts.append(s[last:i]);return parts,i
  elif c==',' and depth==1:parts.append(s[last:i]);last=i+1
 raise AssertionError('unterminated f_result')
for rel in ['src/front/declarations.bend','src/front/validate.bend','src/load/imports.bend']:
 p=project/rel;s=p.read_text().replace('FResult','FRawResult')
 if rel.endswith('declarations.bend'):
  s=once(s,'type FRawResult is Data:\n  FRawResult{+book: List<&2, KDef>, +error: String, +imports: List<&2, KTerm>}', 'type FResult is Data:\n  FResult{+book: List<&2, KDef>, +error: String, +imports: List<&2, KTerm>}\n\n# Internal parser transport only; public FResult remains unchanged.\ntype FRawResult is Data:\n  FRawResult{+book: List<&2, KDef>, +error: KTerm, +imports: List<&2, KTerm>}')
  s=once(s,'law f_parse:\n  for +source: String\n  FRawResult','law f_parse:\n  for +source: String\n  FResult')
  s=once(s,'law f_result:\n  for +book: List<&2, KDef>\n  for +err: String','law f_result:\n  for +book: List<&2, KDef>\n  for +err: KTerm')
  s=once(s,'def f_parse(source):\n  f_tops(f_lex(source, 1, 0, 0, Nil{}), Nil{}, Nil{}, False{})','def f_parse(source):\n  fpe_finish(source, f_tops(f_lex(source, 1, 0, 0, Nil{}), Nil{}, Nil{}, False{}))')
 # Change exactly the second argument; never decode a formatted error string.
 changes=[]
 for m in re.finditer(r'\bf_result\(',s):
  if s[max(0,m.start()-4):m.start()]=='def ':continue
  args,end=arguments(s,m.end()-1);assert len(args)==3
  e=args[1].strip()
  if e.startswith('nm('):
   a,finish=arguments(e,2);assert finish==len(e)-1 and len(a)==1;e=a[0]
  elif e=='""':e='atom("Absent")'
  else:e='kt("Error", '+e+', 0, 0, Nil{})'
  changes.append((m.start(),end+1,'f_result('+args[0]+', '+e+','+args[2]+')'))
 for a,b,t in reversed(changes):s=s[:a]+t+s[b:]
 if rel.endswith('declarations.bend'):
  a='f_err(f_tl(ts), "expected a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")")'
  b='fpe_error(f_tl(ts), "expected a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")", "a fresh constructor name (duplicate declaration: " ++ f_tx(ts) ++ ")")'
  s=once(s,a,b)
 p.write_text(s)
p=project/'src/front/parser.bend';s=p.read_text();s=once(s,'u => f_err(ts, "expected " ++ s))','u => fpe_error(ts, "expected " ++ s, "\'" ++ s ++ "\'"))');p.write_text(s+'\n'+fragment.read_text())
for x in inputs:assert sha(x['file'])==x['sha256'],x['file']
outputs=[{'file':str(p),'sha256':sha(p)}for p in sorted((project/'src').rglob('*'))if p.is_file()]
report={'kind':'phase5-structured-parser-preparation','complete':True,'newBootstrap':False,'baselineApi':meta['apiPath'],'baselineBootstrap':str(proof),'baselineSourceSha256':meta['sourceSha256'],'inputs':inputs,'outputs':outputs,'scope':'Four isolated source files; genuine candidate bootstrap still required.'}
(out/'preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'project':str(project)}))
