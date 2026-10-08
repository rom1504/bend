#!/usr/bin/env python3
"""Freeze explicit backend source-control recipes; never execute targets."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
NEW='059266225b77c8ca256ac6b25ee5c21449bab151'
def pin(p):
 p=p.resolve(strict=True);b=p.read_bytes();return {'file':str(p),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--attempt',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--catalog',choices=['backend','legacy'],default='backend');ap.add_argument('--roles',default='typescript-new,bend-direct,bend-legacy');ap.add_argument('--lanes',default='js');ap.add_argument('--include-printable-witness',action='store_true');a=ap.parse_args()
 a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase66') and not a.out.exists()
 attempt=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt;m=json.loads(attempt.read_text());assert m['checked'] and m['kind']=='bend-development-attempt'
 snapshot=Path(m['snapshot']['root']);up=ROOT/'selfhost/.bootstrap/upstream-phase66';assert Path(m['config']['upstream']).resolve()==up.resolve()
 assert json.loads((snapshot/'src/compiler.json').read_text())['upstream']==NEW
 for k in ['api','runtime','base','node']:assert pin(Path(m[k]['file']))['sha256']==m[k]['sha256']
 assert pin(up/'bend2/base.bend')['sha256']==m['base']['sha256']
 frozen={}
 for row in m['snapshot']['sources']:
  f=row['frozen'];p=Path(f['file']);assert pin(p)['sha256']==f['sha256'];rel=p.relative_to(snapshot);assert str(rel) not in frozen;frozen[str(rel)]=pin(p)
 roles=a.roles.split(',');assert roles and len(roles)==len(set(roles)) and set(roles)<={'typescript-new','bend-direct','bend-legacy'}
 lanes=a.lanes.split(',');assert lanes and len(lanes)==len(set(lanes)) and set(lanes)<={'js','native'}
 cat=Path(__file__).parent/('source-controls-v1.json' if a.catalog=='backend' else 'legacy-source-controls-v1.json');catalog=json.loads(cat.read_text());assert catalog['upstreamRevision']==NEW
 sources=[]
 for row in catalog['cases']:
  p=up/row['path'];assert pin(p)['sha256']==row['sha256'];sources.append((row,p,p.read_text()))
 witness=Path(__file__).parent/'printable-key-controls-v1/main.bend'
 if a.include_printable_witness:
  wm=json.loads((Path(__file__).parent/'printable-key-v1.json').read_text())
  for f in wm['sources']:assert pin(ROOT/f['path'])['sha256']==f['sha256']
  sources.append(({'path':'phase66/printable-name-collision.bend'},witness.resolve(),witness.read_text()))
 a.out.mkdir(parents=True);images=[];commands=[]
 for role in roles:
  project=a.out/role/'project';project.mkdir(parents=True);copies=[]
  for rel,identity in frozen.items():
   dst=project/rel;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(Path(identity['file']).read_bytes());assert pin(dst)['sha256']==identity['sha256'];copies.append({'source':identity,'copy':pin(dst)})
  api=project/'dist/conformance-api.mjs';api.parent.mkdir(parents=True,exist_ok=True);api.write_bytes(Path(m['api']['file']).read_bytes());(project/'dist/typed-api.mjs').write_bytes(api.read_bytes());(project/'dist/base.bend').write_bytes(Path(m['base']['file']).read_bytes())
  adapter=project/'tools/conformance/adapters'/('upstream.mjs' if role=='typescript-new' else 'typed.mjs');original=pin(adapter);text=adapter.read_text()
  if role=='bend-direct':
   needle='backend:lane,combinedOutput:true';assert text.count(needle)==1;text=text.replace(needle,"backend:lane==='js'?'direct':lane,combinedOutput:true");adapter.write_text(text)
  if role=='typescript-new':assert "term.$==='ADT'?[term,...term.c]:[term]" in text, 'Require current ADT own-kind declaration trust traversal'
  if role=='typescript-new' and "list.map(key=>'- '+key+'\\n').join('')" in text:
   needle="list.map(key=>'- '+key+'\\n').join('')";assert text.count(needle)==1;adapter.write_text(text.replace(needle,"list.map(key=>'- '+B.name_key(key)+'\\n').join('')"))
  selected=[];excluded=[]
  for row,p,text in sources:
   is_main=bool(re.search(r'^(def|law) main(?:\(|:)',text,re.M));foreign=re.findall(r'^\s*import\s+"[^"\n]+\.(c|js)"',text,re.M)
   ls=[l for l in lanes if not foreign or ('js' if l=='js' else 'c') in foreign] if is_main else ['check']
   if role=='bend-legacy' and row.get('legacyExpectation')=='explicit-refusal-of-new-operation':
    # The exact runtime refusals are separate frozen controls, not passes for
    # an upstream source's positive oracle. Preserve this declared gap.
    excluded.append({'path':row['path'],'reason':'declared unsupported new legacy timed-send operation','functions':row['refusedFunctions']});continue
   if not ls:
    excluded.append({'path':row['path'],'reason':'No provider for requested source backend lanes'});continue
   entry={'id':row['path'].removeprefix('tests/'),'lanes':ls}
   if row['path'].startswith('phase66/'):entry['file']=str(p)
   selected.append(entry)
  dest=a.out/role/'observations';dest.mkdir();selection=dest/'selection.json';selection.write_text(json.dumps({'cases':selected},indent=2)+'\n')
  environment={'BEND_UPSTREAM':str(up),'BEND_BASE':m['base']['file'],'BEND_TYPED_API':str(api),'BEND_TYPED_RUNTIME':str(project/'src/runtime.mjs'),'BEND_TYPED_TRACE':'','NODE_OPTIONS':'','NODE_PATH':''}
  command=[m['node']['file'],'--stack-size=4096','--max-old-space-size=1024',str(project/'tools/conformance/run.mjs'),'--upstream',str(up),'--adapter',str(adapter),'--output',str(dest/'report.json'),'--jobs','1','--timeout','30000','--worker-mode','isolated','--rss-limit-mb','1536','--stack-kb','4096','--heap-mb','1024','--lanes',','.join(['check']+lanes),'--retain','all','--selected-exit','1','--selection',str(selection)]
  guard=['python3','-B',str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py'),'--seconds','600','--rss-mib','2048','--available-mib','4096',str(dest/'supervisor'),'--','taskset','-c','3','env',*[k+'='+v for k,v in environment.items()],*command]
  commands.append({'name':role,'command':guard,'expectedExitCodes':[0,1],'expectedObservations':sum(len(x['lanes']) for x in selected),'selection':pin(selection),'report':str(dest/'report.json'),'excludedDeclaredGaps':excluded,'interpretation':'Closed report exit1 is observed failures/unsupported, never a pass. Crashes/timeouts separate. Actual TS and Bend pin must match; direct versus legacy is explicit.'})
  images.append({'role':role,'compilerImage':pin(api),'compilerManifest':pin(project/'src/compiler.json'),'adapterBefore':original,'adapterAfter':pin(adapter),'copies':copies})
 recipe={'kind':'phase66-backend-source-control-recipe','version':1,'targetExecuted':False,'producer':pin(Path(__file__)),'attempt':pin(attempt),'catalog':pin(cat),'upstreamRevision':NEW,'upstreamFiles':[pin(up/'bend2'/f) for f in ['bend.ts','comp.ts','base.bend','main.ts']],'roles':roles,'lanes':lanes,'images':images,'commands':commands}
 out=a.out/'recipe.json';out.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps({'recipe':pin(out),'commands':len(commands),'targetExecuted':False}))
if __name__=='__main__':main()
