#!/usr/bin/env python3
"""Static frozen-source comparison; no target/compiler execution and no raw scan."""
import hashlib,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
BASE='5ec82b3a92d92f46547215eca274c5bfecf47796'
ATTEMPT=ROOT/'selfhost/build/phase42/checked15/attempt.json'
OUT=ROOT/'selfhost/tools/performance/phase42/facts/complexity-source15.json'
def stats(b):
 t=b.decode();ls=t.splitlines();return dict(physicalLines=len(ls),nonblankLines=sum(bool(x.strip()) for x in ls),bytes=len(b),**{k:len(re.findall('^'+v+r'\b',t,re.M)) for k,v in [('defs','def'),('laws','law'),('types','type')]})
def identity(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def old(name):return subprocess.check_output(['git','show',BASE+':selfhost/'+name],cwd=ROOT)
def inventory(manifest,read):
 names=json.loads(manifest)['modules'];assert len(names)==len(set(names))
 rows=[dict(name=n,sha256=hashlib.sha256(read(n)).hexdigest(),counts=stats(read(n))) for n in names]
 totals={k:sum(x['counts'][k] for x in rows) for k in rows[0]['counts']};totals['modules']=len(rows)
 return dict(manifestSha256=hashlib.sha256(manifest).hexdigest(),counts=totals,files=rows)
a=json.loads(ATTEMPT.read_text());snap=Path(a['snapshot']['root']);newread=lambda n:(snap/n).read_bytes()
baseline=inventory(old('src/compiler.json'),old);current=inventory(newread('src/compiler.json'),newread)
assert baseline['counts']==dict(physicalLines=18898,nonblankLines=16187,bytes=777508,defs=2108,laws=640,types=71,modules=70)
expected={x['frozen']['file']:x['frozen']['sha256'] for x in a['snapshot']['sources']}
for x in current['files']:assert expected[str(snap/x['name'])]==x['sha256']
oldrows={x['name']:x for x in baseline['files']};newrows={x['name']:x for x in current['files']};changed=[]
for n in sorted(oldrows.keys()|newrows.keys()):
 b=oldrows.get(n);c=newrows.get(n)
 if b and c and b['sha256']==c['sha256']:continue
 changed.append(dict(name=n,baseline=b,current=c,delta={k:(c['counts'][k] if c else 0)-(b['counts'][k] if b else 0) for k in ['physicalLines','nonblankLines','bytes','defs','laws','types']}))
newSymbols=[]
for row in changed:
 name=row['name'];newSymbols.extend(sorted(set(re.findall(r'^def ([^ (]+)',newread(name).decode(),re.M))-set(re.findall(r'^def ([^ (]+)',old(name).decode(),re.M))))
symbolGroups={}
for name in newSymbols:
 family='_'.join(name.split('_')[:2]);symbolGroups.setdefault(family,[]).append(name)
runtime={role:dict(sha256=hashlib.sha256(b).hexdigest(),counts=stats(b)) for role,b in [('baseline',old('src/runtime.mjs')),('source15',newread('src/runtime.mjs'))]}
runtime['delta']={k:runtime['source15']['counts'][k]-v for k,v in runtime['baseline']['counts'].items()}
for role,b in [('baseline',old('src/runtime.mjs')),('source15',newread('src/runtime.mjs'))]:runtime[role]['namedJSFunctionDeclarations']=len(re.findall(r'^\s*function\s+[$\w]+\s*\(',b.decode(),re.M))
runtime['namedJSFunctionDeclarationDelta']=runtime['source15']['namedJSFunctionDeclarations']-runtime['baseline']['namedJSFunctionDeclarations']
# Runtime split files are maintenance source, not a second effective runtime.
fragments=[]
for p in sorted((snap/'src/runtime/js').glob('*.mjs')):
 name=str(p.relative_to(snap));b=old(name);c=p.read_bytes();fragments.append(dict(name=name,baselineSha256=hashlib.sha256(b).hexdigest(),source15Sha256=hashlib.sha256(c).hexdigest(),counts=stats(c),delta={k:stats(c)[k]-v for k,v in stats(b).items()}))
# Supplemental scope is deliberately bounded; never walk selfhost/build/raw.
scopes=['selfhost/tools/performance/phase42','design/phase42','implementation/phase42','experiments/phase42']
files=[]
for scope in scopes:
 for p in sorted((ROOT/scope).rglob('*')):
  if not p.is_file() or p==OUT or p==ROOT/'implementation/phase42/complexity.md' or p.suffix=='.pyc' or '__pycache__' in p.parts:continue
  rel=str(p.relative_to(ROOT));size=p.stat().st_size
  if p.suffix in ['.gz','.tar','.zip','.png','.pdf']:
   files.append(dict(file=rel,category='archived-or-binary-artifacts',bytes=size));continue
  if '/design/' in '/'+rel or '/implementation/' in '/'+rel or '/experiments/' in '/'+rel or p.suffix=='.md':category='documentation-and-review'
  elif p.suffix in ['.patch','.diff'] or any(x in p.parts for x in ['ablation01','retained']) or any('candidate' in x or x.startswith('held-rollback') for x in p.parts):category='isolated-proposals-and-copied-source'
  elif p.suffix=='.bend':category='fixtures-and-proposed-bend'
  elif any(x in p.name for x in ['controls','oracle','probe','fixture']):category='controls-oracles-and-probes'
  else:category='tooling-and-config-evidence'
  b=p.read_bytes()
  try:t=b.decode();lines=len(t.splitlines());nonblank=sum(bool(x.strip()) for x in t.splitlines())
  except UnicodeDecodeError:category='archived-or-binary-artifacts';lines=nonblank=0
  files.append(dict(file=rel,category=category,bytes=size,physicalLines=lines,nonblankLines=nonblank))
groups={}
for x in files:
 g=groups.setdefault(x['category'],dict(files=0,bytes=0,physicalLines=0,nonblankLines=0));g['files']+=1
 for k in ['bytes','physicalLines','nonblankLines']:g[k]+=x.get(k,0)
baseSupplement=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--',*scopes],cwd=ROOT,text=True).splitlines()
# Only metadata/hash identities for generated API; no counting its JS as compiler source.
apiCurrent=Path(a['api']['file']);baseAttempt=ROOT/'selfhost/build/phase41/checked01/attempt.json';ba=json.loads(baseAttempt.read_text());apiBase=Path(ba['api']['file'])
r=dict(kind='phase42-frozen-source15-static-complexity',complete=True,baselineCommit=BASE,attempt=identity(ATTEMPT),producer=identity(Path(__file__)),convention='Maintained Phase32/40/41: physical splitlines, nonblank stripped lines, UTF8 bytes, top-level ^def/^law/^type regex; compiler manifest modules only.',compiler=dict(baseline=baseline,source15=current,delta={k:current['counts'][k]-v for k,v in baseline['counts'].items()},changedFiles=changed,newDefinitionFamilies=symbolGroups),runtime=runtime,runtimeSplitMaintenance=fragments,supplemental=dict(scope=scopes,baselineTrackedFiles=baseSupplement,currentGroups=groups,currentFiles=files,scopeLimit='Descriptive bounded Phase42 evidence volume at accounting time, not frozen compiler inventory; excludes all selfhost/build/raw and these two generated complexity outputs to avoid self-reference; generated compiler source in proposals is never added to canonical compiler count.'),generatedCompilerAPI={role:dict(file=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=data['api']['sha256'],attempt=str(ap.relative_to(ROOT))) for role,p,data,ap in [('baseline',apiBase,ba,baseAttempt),('source15',apiCurrent,a,ATTEMPT)]},programGeneratedJS='No program module aggregate from mixed checked versions: source15 final acquisition/cost gate pending; prior screen13 output bytes recorded separately.',limitations=['Static size/definition deltas are not compilation/runtime speed or causal cache attribution.','Request cache adds definitions and ephemeral retained graphs, removes repeated execution rather than deleting walkers.','Supplied source15 snapshot/API identity is used; no installed-release or final performance claim.'])
OUT.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(out=str(OUT),compilerDelta=r['compiler']['delta'],runtimeDelta=runtime['delta'],groups=groups,changed=[dict(name=x['name'],delta=x['delta']) for x in changed]),indent=2))
