#!/usr/bin/env python3
"""Freeze bounded upstream inputs and root-only diagnostic jobs; no target launch."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
OUT=ROOT/'selfhost/build/phase145/upstream03'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists();OUT.mkdir(parents=True)
 candidate=ROOT/'implementation/phase144/final04/candidate.json';c=json.loads(candidate.read_text())
 assert c['complete'] and c['sourceChecked'] and c['nativeQualified']
 ref=ROOT/'selfhost/build/phase134/reference03.json';r=json.loads(ref.read_text())
 cases=[dict(name=x['name'],source=x['source'],mode='compile') for x in r['cases']]
 cases += [dict(name='compiler-index-slice',source=pin(ROOT/'selfhost/build/phase144/predicate-proxy-source01/positive.bend'),mode='compile'),dict(name='compiler-prefix1024',source=pin(ROOT/'selfhost/build/phase144/existence-source01/compiler-prefix-1024.bend'),mode='parse-only')]
 upstream=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
 files=[candidate,ref,ROOT/'selfhost/build/phase144/predicate-proxy-source01/manifest.json',ROOT/'selfhost/build/phase144/existence-source01/manifest.json',bun,*[upstream/x for x in ['bend.ts','comp.ts','base.bend']],*[p for p in (upstream/'effs').rglob('*') if p.is_file()],*[p for p in HERE.iterdir() if p.is_file()]]
 inputs={str(Path(p).resolve()):pin(p) for p in files}
 for case in cases:assert pin(case['source']['file'])==case['source'];inputs[case['source']['file']]=case['source']
 counters={
 'bend':{'parse_term':None,'parse_def':None,'parse_fresh':None,'parse_reso':None,'term_check':2,'term_infer':2,'term_compare':2,'compare_go':2,'term_wnf':1,'term_snf':1,'term_higher':0,'term_lower':0,'term_force':0,'Check':0,'def_check':None,'def_inst':2,'pmap_get':0,'pmap_set':0,'pmap_union':0,'book_ctr':None},
 'comp':{'fun_of':None,'term_uses':0,'term_any':0,'term_spine':0,'term_force':0,'lay_of':0,'lay_node':None,'memo':None,'memo_gc':None,'emit_expr':1,'emit_body':1,'file_push':None,'graph_close':None,'name_id':None,'seg_new':None}}
 stages={'bend':['parse_book','book_valid','def_check'],'comp':['file_book','compile_book']}
 config=dict(kind='phase145-upstream-work-comparison',complete=True,targetsRun=False,inputs=list(inputs.values()),candidate=pin(candidate),compilerSource=c['source'],bun=pin(bun),upstream={x:pin(upstream/(x+'.ts'))for x in ['bend','comp']},base=pin(upstream/'base.bend'),cases=cases,counters=counters,stages=stages,artifactDirectory=str(OUT/'artifacts'),out=str(OUT),scope='Same real source inputs; upstream ordinary source-Base load/check/C emission. Prefix1024 parse-only. Separate original, clean transpiled and counted copies. No selfhost or native program build; no proof or promotion.')
 (OUT/'plan.json').write_text(json.dumps(config,indent=2)+'\n')
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';jobs=[]
 def job(name,args,seconds):
  jobs.append(dict(name=name,command=[sys.executable,'-B',str(guard),'--out',str(OUT/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','64','--cpu','3','--',str(bun),*map(str,args)]))
 job('prepare-generated',[HERE/'generate-v03.mjs',OUT/'plan.json'],30)
 for case in cases:
  for variant in ['original','clean','counted']:
   job(case['name']+'-'+variant,[HERE/'worker.mjs',OUT/'plan.json',case['name'],variant,OUT/(case['name']+'-'+variant)],90 if case['mode']=='compile' else 45)
 (OUT/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(OUT/'plan.json'),pin(guard)],jobs=jobs),indent=2)+'\n')
 print(OUT/'jobs.json')
if __name__=='__main__':main()
