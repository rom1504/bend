#!/usr/bin/env python3
"""Bounded source-only census. No compiler execution and no deletion authority.
Each source/module is read and lexed once. Dependency closure includes first-class
references, constructor owners, laws, published driver roots and protected gates.
Lexical references conservatively include binder/name collisions. Missing incoming
edges are NOT proof of public API absence; every suggested deletion needs checking.
"""
import argparse, collections, hashlib, json, re, subprocess, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
DECL=re.compile(r'^(?:(@unsafe)[ \t]*\n)?(type|law|def)\s+([A-Za-z_][A-Za-z0-9_.]*)',re.M)
TOKEN=re.compile(r'[A-Za-z_][A-Za-z0-9_.]*')
LEX=re.compile(r'''"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\\n])'|#[^\n]*''',re.S)
MARK=re.compile(r'^# (?:Module|Phase111 module):\s*(\S+?)(?::\d+)?\s*$',re.M)
CACHE={}; PINS={}; PARSED={}
def read(path):
 p=Path(path); p=p if p.is_absolute() else ROOT/p
 p=p.resolve(); key=str(p)
 if key not in CACHE:
  data=p.read_bytes();CACHE[key]=data.decode();PINS[key]={'file':str(p),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
 return CACHE[key]
def js(path):return json.loads(read(path))
def clean(text):return LEX.sub(lambda m:'\n'*m[0].count('\n') if m[0].startswith('#') else ' "STRING" ',text)
def norm(text):return '\n'.join(x.rstrip() for x in text.splitlines() if x.strip() and not x.lstrip().startswith('#'))
def parse(path):
 path=str((ROOT/path).resolve())
 if path in PARSED:return PARSED[path]
 text=read(path); hits=list(DECL.finditer(text)); rows=[]; marks=list(MARK.finditer(text)); mi=0; origin=None; lines=1;prev=0
 for i,h in enumerate(hits):
  start=h.start(); end=hits[i+1].start() if i+1<len(hits) else len(text)
  lines+=text.count('\n',prev,start);prev=start
  while mi<len(marks) and marks[mi].start()<start:origin=marks[mi][1];mi+=1
  raw=text[start:end]; content=norm(raw); nonblank=sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in raw.splitlines())
  rows.append({'kind':h[2],'name':h[3],'line':lines,'physicalLines':len(raw.splitlines()),'codeLines':nonblank,'bytes':len(raw.encode()),'marker':origin,'hash':hashlib.sha256(content.encode()).hexdigest(),'content':content,'raw':raw,'tokens':set(TOKEN.findall(clean(raw)))})
 PARSED[path]=rows
 return rows

def reach(graph, roots):
 seen=set();todo=list(roots)
 while todo:
  n=todo.pop()
  if n in seen or n not in graph:continue
  seen.add(n);todo.extend(graph[n]-seen)
 return seen

def pinpath(item):
 if isinstance(item,dict):return item.get('file',item.get('path'))
 return item if isinstance(item,str) else None

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--out',required=True);args=ap.parse_args();out=ROOT/args.out
 if out.exists():raise SystemExit('fresh output required')
 start=time.monotonic()
 cases=[('qualified137','selfhost/build/phase137/integrated-source03/compiler.bend','selfhost/build/phase137/integrated-source03/manifest.json','selfhost/build/phase111/p137-integrated-api01/report.json'),('prototype140','selfhost/build/phase140/native-source18/compiler.bend','selfhost/build/phase140/native-source18/manifest.json','selfhost/build/phase111/p140-native-api18/report.json')]
 # Bounded actual selected provenance chain: only manifests, sourceManifest and
 # parentManifest, plus direct Bend inputs; do not scan historical build trees.
 maintained_paths=set('selfhost/'+p for p in js('selfhost/src/compiler.json')['modules'])
 module_paths=set(maintained_paths)
 # Only 27 bounded prior-phase source directories, ~3.3MB total at this HEAD.
 # Exact body matches provide provenance candidates, not active-module status.
 for phase in range(111,138):
  module_paths.update(str(p) for p in (ROOT/f'selfhost/tools/performance/phase{phase}').rglob('*.bend'))
 manifests={};todo=[x[2] for x in cases];limit=48
 while todo and len(manifests)<limit:
  p=str((ROOT/todo.pop()).resolve());
  if p in manifests:continue
  d=js(p);manifests[p]=d
  for k in ('sourceManifest','parentManifest'):
   q=pinpath(d.get(k))
   if q and q.endswith('.json') and Path(q).exists():todo.append(q)
  for item in d.get('modules',[])+d.get('inputs',[]):
   q=pinpath(item)
   if q and q.endswith('.bend') and '/tools/' in q and Path(q).exists():module_paths.add(q)
 # Read module declarations once; provenance exact modulo comments/blank indent.
 provenance=collections.defaultdict(list);module_stats=[]
 for p in sorted(module_paths):
  rows=parse(p);text=read(p)
  module_stats.append({'file':str((ROOT/p).resolve()),'physicalLines':len(text.splitlines()),'codeLines':sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in text.splitlines()),'declarations':len(rows)})
  for r in rows:provenance[(r['kind'],r['name'],r['hash'])].append({'file':str((ROOT/p).resolve()),'line':r['line']})
 driver=read('selfhost/tools/typed-driver.mjs')
 root_literals=[]
 m=re.search(r'const roots\s*=\s*\[([^]]+)\]',driver)
 if m:root_literals+=re.findall(r"'([^']+)'",m[1])
 for m in re.finditer(r'exports\.push\(([^;]+?)\)',driver):root_literals+=re.findall(r"'([^']+)'",m[1])
 published=set(root_literals)
 results={}
 for label,source,manifest,api in cases:
  rows=parse(source);d=js(manifest);a=js(api);text=read(source);names={r['name'] for r in rows};byname=collections.defaultdict(list)
  for r in rows:byname[r['name']].append(r)
  constructors={}
  for r in rows:
   if r['kind']=='type':
    for name in re.findall(r'\b([A-Z][A-Za-z0-9_]*)\s*\{',clean(r['raw'])):constructors[name]=r['name']
  graph={n:set() for n in names}
  for r in rows:
   graph[r['name']]|=(r['tokens']&names)|{constructors[t] for t in r['tokens'] if t in constructors}
  # A named controls entry must expose List<Bool> or List<String> finite-test protocol.
  control_roots={n for n,rs in byname.items() if re.search(r'_controls(?:_v[0-9]+)?$',n) and any(re.search(r'List\s*<\s*&2\s*,\s*(?:Bool|String)\s*>',r['raw']) for r in rs)}
  # Actual checked-API fixture exports defined in explicit controls modules
  # are controls, even when their exported name is an observation helper.
  control_module_exports={r['name'] for r in rows if r['name'] in a['exports'] and any('/controls' in x['file'] or '-controls' in x['file'] for x in provenance.get((r['kind'],r['name'],r['hash']),[]))}
  control_module_declarations={r['name'] for r in rows if any('/controls' in x['file'] or '-controls' in x['file'] for x in provenance.get((r['kind'],r['name'],r['hash']),[]))}
  control_roots|=control_module_exports|control_module_declarations
  controls=reach(graph,control_roots)
  protected=set(d.get('protectedDeclarations',[]));proof=set(d.get('unchangedProofDeclarations',[]))
  if protected and isinstance(next(iter(protected)),dict):raise RuntimeError('unsupported protected schema')
  actual_exports=set(a['exports'])
  production_roots=({'main'}|published|protected|proof|actual_exports)-control_roots
  # Test adapter exports in actual API are retained as research API roots, not
  # silently declared dead. Report excluding such exports only as separate view.
  prod=reach(graph,production_roots);native=reach(graph,{'main'});only_control=controls-prod;unreached=names-prod-controls
  group=collections.defaultdict(lambda:collections.Counter());decls=[];duplicates=collections.defaultdict(list)
  for r in rows:
   matches=provenance.get((r['kind'],r['name'],r['hash']),[])
   category='production/API/proof' if r['name'] in prod else 'controls-only' if r['name'] in only_control else 'unreached-not-deletion-proof'
   origin=matches[0]['file'] if matches else ('marker-only:'+r['marker'] if r['marker'] else 'unmapped-overlay')
   key=origin
   for field in ('physicalLines','codeLines','bytes'):group[key][field]+=r[field]
   group[key][category+'CodeLines']+=r['codeLines'];group[key]['declarations']+=1
   rr={k:v for k,v in r.items() if k not in ('content','raw','tokens')};rr.update(category=category,nativeReachable=r['name'] in native,exactProvenance=matches,dependencies=sorted(graph[r['name']]-{r['name']}));decls.append(rr)
   if r['kind']=='def':
    body=re.sub(r'^(@unsafe\s+)?def\s+'+re.escape(r['name']),lambda m:(m[1] or '')+'def NAME',r['content'],count=1)
    duplicates[hashlib.sha256(body.encode()).hexdigest()].append(rr)
  dup=[{'hash':h,'codeLinesPerCopy':xs[0]['codeLines'],'copies':[{'name':x['name'],'line':x['line'],'category':x['category']} for x in xs]} for h,xs in duplicates.items() if len(xs)>1]
  dup.sort(key=lambda r:r['codeLinesPerCopy']*(len(r['copies'])-1),reverse=True)
  totals={cat:{'declarations':sum(r['category']==cat for r in decls),'codeLines':sum(r['codeLines'] for r in decls if r['category']==cat),'names':len({r['name'] for r in decls if r['category']==cat})} for cat in ('production/API/proof','controls-only','unreached-not-deletion-proof')}
  kindstats={kind:{'declarations':sum(r['kind']==kind for r in rows),'codeLines':sum(r['codeLines'] for r in rows if r['kind']==kind),'physicalLines':sum(r['physicalLines'] for r in rows if r['kind']==kind)} for kind in ('type','law','def')}
  summary={'kinds':kindstats,'source':PINS[str((ROOT/source).resolve())],'physicalLines':len(text.splitlines()),'codeLines':sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in text.splitlines()),'declarations':len(rows),'distinctNames':len(names),'groups':totals,'nativeEntryReachableCodeLines':sum(r['codeLines'] for r in decls if r['nativeReachable']),'moduleProvenanceExactCodeLines':sum(r['codeLines'] for r in decls if r['exactProvenance']),'provenanceCaveat':'Remaining marker origins are assembly hints; later overriding bodies can invalidate them.','rootSets':{'publishedTypedDriver':sorted(published&names),'publishedMissing':sorted(published-names),'actualApi':sorted(actual_exports),'controlsProtocol':sorted(control_roots),'protected':sorted(protected),'proof':sorted(proof)},'modules':sorted([dict(file=k,**v) for k,v in group.items()],key=lambda r:r['codeLines'],reverse=True),'exactDuplicateBodies':dup,'unreachedNames':sorted(unreached)}
  results[label]=summary
  out.mkdir(parents=True,exist_ok=True)
  (out/(label+'-declarations.json')).write_text(json.dumps(decls,indent=2)+'\n')
 # Mechanical parser duplicate audit is stronger than a guessed near-duplicate.
 clone=js('selfhost/tools/performance/phase140/parser/clone-v02.json');selected=parse(cases[1][1]);cn=set(clone['functions']);nn={'p140p_'+n[2:] for n in cn}
 parser={side:{'names':sorted(ns),'declarations':sum(r['name'] in ns for r in selected),'codeLines':sum(r['codeLines'] for r in selected if r['name'] in ns),'physicalDeclarationLines':sum(r['physicalLines'] for r in selected if r['name'] in ns)} for side,ns in [('original',cn),('clone',nn)]}
 parser['derivation']=clone
 parser['externalCallers']={side:[{'caller':r['name'],'line':r['line'],'targets':sorted(r['tokens']&ns)} for r in selected if r['name'] not in ns and r['tokens']&ns] for side,ns in [('original',cn),('clone',nn)]}
 report={'kind':'phase141-read-only-source-census-v1','complete':True,'compilerTargetsRun':False,'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'seconds':time.monotonic()-start,'scope':'Two exact selected source images, current maintained src modules, bounded selected provenance chains, typed-driver and actual API roots. Conservative lexical graph, not a semantic dead-code proof.','provenanceManifestCount':len(manifests),'provenanceLimitReached':bool(todo),'moduleInventory':module_stats,'maintainedSourceModules':[x for x in module_stats if x['file'] in {str((ROOT/p).resolve()) for p in maintained_paths}],'images':results,'mechanicalParserClone':parser,'inputs':list(PINS.values()),'method':{'file':str(Path(__file__).resolve()),'sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}}
 (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({k:{x:v[x] for x in ('physicalLines','codeLines','declarations','groups','nativeEntryReachableCodeLines','moduleProvenanceExactCodeLines')} for k,v in results.items()},indent=2));print('parser',json.dumps({k:v for k,v in parser.items() if k!='derivation'}));print('seconds',report['seconds'])
if __name__=='__main__':main()
