#!/usr/bin/env python3
"""Append isolated immutable consumer probes and prepare root-only gates."""
import hashlib,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 parent=ROOT/'selfhost/build/phase144/predicate-canonical-source01/manifest.json';pm=json.loads(parent.read_text())
 source=Path(pm['source']['file']);assert pin(source)==pm['source'];assert pm['source']['sha256']=='31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
 out=ROOT/'selfhost/build/phase144/existence-source01';assert not out.exists()
 modules=[HERE/x for x in ['core-v01.bend','controls-v01.bend','workload-v01.bend']]
 spec=importlib.util.spec_from_file_location('C',ROOT/'selfhost/tools/performance/phase141/census/read-onlyinventory.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
 original=source.read_text();old=C.parse(str(source));names={r['name']for r in old};added=[]
 for p in modules:
  for r in C.parse(str(p)):
   assert r['name']not in names;names.add(r['name']);added.append(r['name'])
 text=original+'\n'+''.join(p.read_text()+'\n'for p in modules);assert text.startswith(original)
 out.mkdir(parents=True);target=out/'compiler.bend';target.write_text(text)
 after=C.parse(str(target));assert len(after)==len(old)+len(added)
 # Last old declaration's trailing gap grows; all original bytes stay prefix.
 assert all(a['raw']==b['raw'] for a,b in zip(old[:-1],after[:-1]))
 fixtures=[]
 for count in [256,1024]:
  selected=old[:count];body='import Base\n\n'+''.join(r['raw']for r in selected)
  fixture=out/f'compiler-prefix-{count}.bend';fixture.write_text(body)
  fixtures.append(dict(source=pin(fixture),declarations=count,types=sum(r['kind']=='type'for r in selected),
   extraction='Exact first ordered declarations, including their original law/definition pairs and spans relative to this extracted source; imported Base scope supplied by checked parser. No fabricated KDef payloads.'))
 api=ROOT/'selfhost/build/phase111/p144-existence-api01';finite=ROOT/'selfhost/build/phase144/existence-controls01';screen=ROOT/'selfhost/build/phase144/existence-screen01'
 exports=['p88_cache_prepare','p144ce_controls','p144cet_parse','p144cet_seed_seen','p144cet_original','p144cet_indexed','base_prefix_ctor_disjoint','p144ce_disjoint']
 report=dict(kind='phase144-constructor-existence-isolated-prototype',complete=True,checked=False,targetsRun=False,nativeQualified=False,selected=False,
  source=pin(target),parent=pm['source'],inputs=[pin(__file__),pin(parent),pin(C.__file__),*[pin(p)for p in modules]],added=added,overrides=[],
  originalBytesUnchangedPrefix=True,protectedDeclarations=pm['protectedDeclarations'],unchangedProofDeclarations=pm['unchangedProofDeclarations'],
  fixtures=fixtures,exports=exports,scope='Immutable same-batch constructor-existence facts; ordinary oracles and checker remain unchanged. No shared runtime or BookCache authority changes.')
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';checker=ROOT/'selfhost/tools/performance/phase111/check-api.py';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
 jobs=[]
 def job(name,cmd,seconds):
  jobs.append(dict(name=name,seconds=seconds+20,command=[sys.executable,'-B',str(guard),'--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--cpu','3','--rss-mib','3072','--available-mib','16384','--file-mib','100','--',*map(str,cmd)]))
 job('checked-api',[sys.executable,'-B',checker,'--source',target,'--out',api,*exports],120)
 job('27-independent-controls',[bun,ROOT/'selfhost/tools/performance/phase143/controls-v01.mjs',api/'report.json',finite,'p144ce_controls:27:suffix'],30)
 job('actual-compiler-consumers',[bun,HERE/'screen-v01.mjs',api/'report.json',out/'manifest.json',screen],70)
 (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(out/'manifest.json'),pin(HERE/'screen-v01.mjs')],jobs=jobs),indent=2)+'\n')
 print(json.dumps(dict(complete=True,targetsRun=False,source=pin(target),added=len(added),jobs=str(out/'jobs.json'))))
if __name__=='__main__':main()
