#!/usr/bin/env python3
"""Assemble concrete new-owner acquisition/control commands; execute no target."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
OUT='${OUT}';NODE='${NODE}';ATTEMPT='${ATTEMPT}'
def main():
 steps=[];owners=[]
 def absfile(rel):return str(ROOT/rel)
 def supervise(name,argv,seconds=120):
  steps.append(dict(name='phase43-'+name,lockOwner=True,argv=['python3',absfile('selfhost/tools/performance/phase32/bounded-run.py'),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','2048',OUT+'/run-'+name,'--',*argv]))
 def node(tool,*args):return ['taskset','-c','3',NODE,'--stack-size=4096','--max-old-space-size=1024',absfile(tool),*args]
 supervise('new-owner-directories',['python3','-c',"import pathlib,sys;pathlib.Path(sys.argv[1]).mkdir(parents=True,exist_ok=False)",OUT+'/new-owner-modules'])
 def emit(name,source,catalog,selection=ATTEMPT):
  module=OUT+'/new-owner-modules/'+name+'.mjs'
  supervise('emit-'+name,node('selfhost/tools/performance/programs/emit-worker.mjs',selection,absfile(source),module,absfile(catalog)),150)
  return module
 def owner(name,module,args,derive=None,aux=None,rawInput=None):
  policy=json.loads((HERE/'owner-catalogue-v6.json').read_text())[name]
  supervise('raw-'+name,node(policy['controller'],*args,OUT+'/raw-'+name))
  owners.append(dict(owner=name,rawReport=OUT+'/raw-'+name+'/report.json',rawExecution=OUT+'/run-raw-'+name+'/run.json',rawCommandInput=rawInput or (derive if derive else module),emittedModules=[module] if module else [],derivations=[derive+'/derive.json'] if derive else [],auxiliaryInputs=aux or []))
 # Callback successor subsumes the historical32 boundaries and adds7 guard controls.
 data=json.loads((ROOT/'selfhost/tools/performance/phase43/callbacks/final-owner-data-v3.json').read_text())
 for emission in data['emissions']:
  argv=emission['argv'];supervise('emit-'+Path(emission['module']).stem,['taskset','-c','3',argv[0],'--stack-size=4096','--max-old-space-size=1024',*argv[1:]],150)
 derive=data['derivationCommand'];supervise('derive-callbacks-environment',['taskset','-c','3',derive['argv'][0],*derive['argv'][1:]])
 chosen=['callbacks-number-count','callbacks-number-count-noncommutative','callbacks-admission']
 for row in data['owners']:
  if row['owner'] not in chosen:continue
  command=next(r for r in data['rawCommands'] if r['name']=='phase43-raw-'+row['owner'])
  argv=command['argv'];supervise('raw-'+row['owner'],['taskset','-c','3',argv[0],'--stack-size=4096','--max-old-space-size=1024',*argv[1:]])
  owners.append(row)
 # Read-only actual compiler predicates; never substitutes executable Map admission.
 proofsource=absfile('selfhost/tools/performance/phase37/fixtures-new/map-churn.bend')
 owner('map-compiler-proof',None,[ATTEMPT,proofsource,'bench'],aux=[OUT+'/raw-map-compiler-proof/inputs.json',OUT+'/raw-map-compiler-proof/completion.json'],rawInput=proofsource)
 # Source14 Map profiles: inventories frozen from checked AST before controls.
 mapdata=json.loads((ROOT/'selfhost/tools/performance/phase43/products/map-actual/final-owner-data-v5.json').read_text());assert mapdata['profilesComplete'] is True
 for profile in mapdata['profiles']:
  for step in profile['steps']:
   argv=step['command'];args=[absfile(arg) if arg.startswith('selfhost/') else arg for arg in argv[1:]]
   supervise(step['id'],['taskset','-c','3',NODE,'--stack-size=4096','--max-old-space-size=1024',*args],150 if step['id'].endswith('-candidate') or step['id'].endswith('-baseline') else 120)
  name=profile['id'];module=OUT+'/new-owner-modules/'+name+'.mjs';derived=OUT+'/derive-'+name
  owners.append(dict(owner=name,rawReport=OUT+'/raw-'+name+'/report.json',rawExecution=OUT+'/run-'+name+'-controls/run.json',rawCommandInput=derived,emittedModules=[module],derivations=[derived+'/derive.json'],auxiliaryInputs=[OUT+'/trace-'+name+'/inputs.json',OUT+'/trace-'+name+'/completion.json']))
 # Full native String graph and independent renamed/computed literal controls.
 cat37='selfhost/tools/performance/phase37/catalog.json';catstr='selfhost/tools/performance/phase43/strings/fixture-catalog-v4.json'
 instr='selfhost/tools/performance/phase43/strings/source-instrument-v5.mjs'
 lexsource='selfhost/tools/performance/phase37/fixtures-historical/lexer.bend'
 lexer=emit('lexer',lexsource,cat37);derived=OUT+'/derive-strings-source'
 supervise('derive-strings-source',node(instr,absfile('selfhost/build/phase42/integration03/full-preparation/modules/lexer.mjs'),lexer,derived))
 owner('strings-source',lexer,[derived],derive=derived)
 owner('strings-types',None,[ATTEMPT,absfile(lexsource)],rawInput=absfile(lexsource))
 for name,source in [('strings-literal-graph','typed-components-v3'),('strings-renamed','typed-components-renamed-v3'),('strings-negative-literal0','negative-literal0-v3')]:
  module=emit(name,'selfhost/tools/performance/phase43/strings/'+source+'.bend',catstr);derived=OUT+'/derive-'+name
  supervise('derive-'+name,node(instr,absfile('selfhost/build/phase43/string-fixture-baseline04/modules/'+source+'.mjs'),module,derived))
  owner(name,module,[derived+'/original.mjs',derived+'/full.mjs','negative-literal0' if name=='strings-negative-literal0' else 'renamed'],derive=derived,rawInput=derived+'/original.mjs')
 # Actual BST scalar wrapper and ordinary pair worker must both activate.
 bst=emit('bst','selfhost/tools/performance/phase37/fixtures-new/bst.bend',cat37)
 owner('products-bst',bst,[bst,absfile('selfhost/build/phase42/integration03/full-preparation/modules/bst.mjs'),'--scalar-wrapper','--pair-state'])
 # Product controllers place output as positional third argument; repair argv below.
 products='selfhost/tools/performance/phase43/products/'
 modules=[('products-fixture','products-fixture','fixtures/prefix-controls.bend','fixture-catalog-v4.json','selfhost/build/phase43/product-fixture-baseline04/modules/prefix-controls.mjs',['--fixture','--scalar-wrapper','--pair-state']),('products-pair-precedence','pair-precedence','fixtures/pair-controls.bend','fixture-catalog-v4.json','selfhost/build/phase43/product-fixture-baseline04/modules/pair-controls.mjs',['--precedence-control']),('products-pair-ignored-precedence','pair-ignored-precedence','fixtures/pair-ignored-controls.bend','pair-ignored-catalog-v2.json','selfhost/build/phase43/product-ignored-baseline02/modules/pair-ignored-controls.mjs',['--precedence-control'])]
 for name,stem,src,cat,baseline,flags in modules:
  module=emit(stem,products+src,products+cat)
  owner(name,module,[module,absfile(baseline),*flags])
 # Independent prefix BST fixture qualifies actual pair activation.
 # Plain pair targetv2 remains failed ordinary-activation evidence, not a positive owner.
 baseline=emit('pair-ignored-target-checked16',products+'fixtures/pair-bst-ignored-controls-v1.bend',products+'pair-bst-ignored-catalog-v1.json',absfile('selfhost/build/phase42/checked16'))
 module=emit('pair-ignored-target',products+'fixtures/pair-bst-ignored-controls-v1.bend',products+'pair-bst-ignored-catalog-v1.json')
 owner('products-bst-pair-ignored',module,[module,baseline],aux=[baseline+'.json'])
 for step in steps:
  if step['name'].startswith('phase43-raw-products-'):
   argv=step['argv'];output=argv.pop();idx=argv.index('--max-old-space-size=1024')+4;argv.insert(idx,output)
 # Actual U32 host capability controller emits JSON directly to supervisor stdout.
 module=emit('list-pipeline','selfhost/tools/performance/phase37/fixtures-new/list-pipeline.bend',cat37);derived=OUT+'/derive-u32-guards'
 supervise('derive-u32-guards',['python3',absfile('selfhost/tools/performance/phase43/guards/derive-actual-v1.py'),'--candidate',module,'--baseline',absfile('selfhost/build/phase42/integration03/full-preparation/modules/list-pipeline.mjs'),'--baseline-receipt',absfile('selfhost/build/phase42/integration03/full-preparation/modules/list-pipeline.mjs.json'),'--out',derived])
 supervise('raw-u32-guards',node('selfhost/tools/performance/phase43/guards/oracle-actual-v1.mjs',derived))
 owners.append(dict(owner='u32-guards',rawReport=OUT+'/run-raw-u32-guards/stdout.log',rawExecution=OUT+'/run-raw-u32-guards/run.json',rawCommandInput=derived,emittedModules=[module],derivations=[derived+'/derivation.json'],auxiliaryInputs=[]))
 config=dict(kind='phase43-concrete-new-owner-config',reviewed=False,executed=False,scope='Source14 callbacks bounded Number count with genuine BigInt fallback, native String source/refusal, actual ordinary and independent-prefix BST pair activation/scalar precedence and U32 host capabilities. Main and two independent Map source profiles with frozen checked14 AST inventories; inherited16 mandatory owners remain in recipe.',steps=steps,owners=owners)
 (HERE/'final-owner-config-v6.json').write_text(json.dumps(config,indent=2)+'\n')
 print(json.dumps(dict(complete=True,executed=False,steps=len(steps),owners=[r['owner'] for r in owners])))
if __name__=='__main__':main()
