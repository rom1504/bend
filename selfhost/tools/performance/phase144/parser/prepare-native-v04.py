#!/usr/bin/env python3
"""Package exact old/new parser closures; no compiler execution or host compiler."""
import argparse,hashlib,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
METHOD=ROOT/'selfhost/tools/performance/phase131/prepare.py'
s=importlib.util.spec_from_file_location('compose',METHOD);C=importlib.util.module_from_spec(s);s.loader.exec_module(C)
LEXER=ROOT/'selfhost/tools/performance/phase141/census/read-onlyinventory.py'
s=importlib.util.spec_from_file_location('census',LEXER);L=importlib.util.module_from_spec(s);s.loader.exec_module(L)
PREFIX=['p86_plan','p86_plan_header','p86_plan_imported','p86_plan_seed','p86_plan_seeded','p86_plan_completed']
NAMES={n:n.replace('p86_plan','p144pn_parse') for n in PREFIX}
NAMES['p86_plan_loaded']='p144pn_loaded'
def closure(blocks,roots):
 ctors={}
 for name,body in blocks.items():
  if re.match(r'(?:@unsafe\n)?type ',body):
   for c in re.findall(r'^  ([A-Za-z_][\w.]*)\s*\{',L.clean(body),re.M):ctors[c]=name
 seen=set();todo=list(roots)
 while todo:
  name=todo.pop()
  if name in seen:continue
  seen.add(name)
  for tok in re.findall(r'\b[A-Za-z_][A-Za-z0-9_.]*',L.clean(blocks[name])):
   dep=tok if tok in blocks else ctors.get(tok)
   if dep and dep not in seen:todo.append(dep)
 return seen
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
 selection=ROOT/'implementation/phase143/candidate.json';selected=json.loads(selection.read_text());candidate=json.loads(a.candidate.read_text())
 assert candidate['complete'] and candidate['parent']==selected['source']
 fixed=ROOT/'selfhost/build/phase130/p142-indexed-emit01/report.json';request=json.loads(fixed.read_text())['source']
 for pin in [selected['source'],candidate['source'],request]:assert C.pin(pin['file'])==pin
 entry=(HERE/'native-entry-v01.bend').read_text();out.mkdir(parents=True);rows={}
 for role,source in [('original',selected['source']),('candidate',candidate['source'])]:
  before=Path(source['file']).read_text();blocks=C.blocks(before,combine=True)
  masked=L.LEX.sub(lambda m: ''.join('\n' if c=='\n' else ' ' for c in m[0]),before)
  assert [m[1]for m in C.PAT.finditer(before)]==[m[1]for m in C.PAT.finditer(masked)],'Literal declaration boundary disagreement'
  assert 'f_lex_scanned' in L.TOKEN.findall(L.clean(blocks['f_lex_cursor']))
  prefix=''.join(blocks[n] for n in PREFIX)
  for old,new in sorted(NAMES.items(),key=lambda x:-len(x[0])):prefix=re.sub(r'\b'+re.escape(old)+r'\b',new,prefix)
  prefix=prefix.replace('P86PlanError','P144PNError').replace('P86Plan','P144PNResult')
  combined=dict(blocks);combined.update(C.blocks(prefix+entry,combine=True));names=closure(combined,['main','p144pn_result_hash'])
  assert not any(n.startswith(('p111_','p113','p128raw_','nc_','no_')) for n in names)
  hits=list(C.PAT.finditer(before))
  spans=[dict(name=h[1],start=h.start(),stop=hits[i+1].start() if i+1<len(hits) else len(before)) for i,h in enumerate(hits) if h[1] in names and h[1]!='main']
  original=''.join(before[v['start']:v['stop']] for v in spans)
  new_names=[n for n in combined if n in names and n not in blocks]
  new_types=[n for n in new_names if re.match(r'(?:@unsafe\n)?type ',combined[n])]
  order=new_types+[n for n in new_names if n not in new_types]+['main']
  text='import Base\n\n'+original+''.join(combined[n] for n in order)
  dest=out/(role+'.bend');dest.write_text(text)
  rows[role]=dict(source=C.pin(dest),original=source,declarations=[n for n in combined if n in names],lines=len(text.splitlines()),bytes=len(text.encode()),sameNameDeclarationsPreserved=True,extracted=[dict(name=v['name'],sha256=hashlib.sha256(before[v['start']:v['stop']].encode()).hexdigest(),firstLine=before.count('\n',0,v['start'])+1,lastLine=before.count('\n',0,v['stop'])) for v in spans])
  actual=C.blocks(text,combine=True)
  assert all(actual[n]==blocks[n] for n in names if n in blocks and n!='main')
  # Independent row-based graph audit after packaging, separate from closure walk.
  owner_types={}
  for name,body in combined.items():
   if re.match(r'(?:@unsafe\n)?type ',body):
    for token in re.findall(r'\b([A-Z][A-Za-z0-9_]*)\s*\{',L.clean(body)):owner_types.setdefault(token,set()).add(name)
  audited=L.parse(str(dest));missing=set()
  for row in audited:
   missing |= row['tokens'] & set(combined) - names
   for token in row['tokens']:missing |= owner_types.get(token,set()) - names
  assert not missing,('Missing extracted internal dependencies',sorted(missing))
  rows[role]['independentDependencyAudit']=dict(complete=True,rows=len(audited),missingInternalNames=[],lexer=C.pin(LEXER))
 inputs=[C.pin(__file__),C.pin(METHOD),C.pin(LEXER),C.pin(HERE/'native-entry-v01.bend'),C.pin(selection),C.pin(a.candidate),C.pin(fixed),selected['source'],candidate['source'],request]
 report=dict(kind='phase144-native-parser-slices',complete=True,checked=False,targetsRun=False,sourcePair=rows,request=request,
  exports=['p88_cache_prepare','p144pn_parse','p144pn_hash','p144pn_error','p144pn_result_hash'],
  prefixCopies=PREFIX,privateResult='Complete FPrefixLoad plus retained prepared seed; native checksum covers full external FResult.',inputs=inputs,
  scope='Source-only lexical overapproximation followed by required Bend checking; not a semantic cache or host parser. Both native slices must be produced by the same qualified Phase143 N2/runtime. Exact whole-data hosted oracle precedes native timing. Hash is a regression checksum, not a collision-free correctness proof.')
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
 (out/'native-entry.bend').write_text(entry)
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';builder=ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py';jobs=[]
 for role,row in rows.items():
  dest=ROOT/('selfhost/build/phase134/'+out.name+'-'+role)
  command=[sys.executable,'-B',str(guard),'--out',str(out/(role+'-build-guard')),'--seconds','240','--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',sys.executable,'-B',str(builder),'--image',selected['native']['file'],'--source',row['source']['file'],'--carrier-receipt',selected['preferredCarrierReceipt']['file'],'--runtime',selected['runtime']['file'],'--out',str(dest),'--seconds','220']
  jobs.append(dict(role=role,command=command,expectedImage=str(dest/'program'),buildReceipt=str(dest/'report.json')))
 (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[C.pin(out/'manifest.json'),C.pin(guard),C.pin(builder)],jobs=jobs,
  execution='After both checked slice APIs and hosted complete-data/hash oracle pass, run native binaries with --threads 1 --gpu off -- INPUT BASE CARRIER STAMP. Use exact request path and authenticated selected carrier. Record prepare_ms, parse_ms, observe_ms separately; external process time includes all plus file IO.'),indent=2)+'\n')
 print(json.dumps({role:{k:v[k]for k in ['source','lines','bytes']}for role,v in rows.items()}))
if __name__=='__main__':main()
