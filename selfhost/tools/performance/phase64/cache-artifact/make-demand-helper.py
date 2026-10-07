#!/usr/bin/env python3
"""Create a separate diagnostic helper; never edit the consumed decoder."""
import argparse, hashlib, json
from pathlib import Path

TRACKER = r'''
// Phase64 diagnostic only. Decoding still materializes every node. Proxies count
// reads of original Base nodes; their overhead is not a speed measurement.
const demandNodeIds=new WeakMap(),demandViews=new WeakMap(),demandNodes=[];
const demandPhases=new Map(),demandAccessed=new Set();
let demandPhase='cache-admission',demandWrapped=0;
function demandRegister(nodes) {
  for(let i=0;i<nodes.length;i++)if(!demandNodeIds.has(nodes[i])){
    demandNodeIds.set(nodes[i],demandNodes.length);demandNodes.push(nodes[i]);
  }
}
function demandView(value) {
  if(value===null||typeof value!=='object'||!demandNodeIds.has(value))return value;
  if(demandViews.has(value))return demandViews.get(value);
  const id=demandNodeIds.get(value);
  const view=new Proxy(value,{
    get(target,key,receiver) {
      if(typeof key==='string'&&Object.hasOwn(target,key)){
        let phase=demandPhases.get(demandPhase);
        if(!phase){phase={reads:0,nodes:new Set(),fields:new Map(),bodies:new Map()};demandPhases.set(demandPhase,phase);}
        phase.reads++;phase.nodes.add(id);demandAccessed.add(id);
        const field=target.$+'.'+key;phase.fields.set(field,(phase.fields.get(field)??0)+1);
        if(target.$==='KDef'&&key==='value')phase.bodies.set(id,{definition:target.name,node:id,valueNode:demandNodeIds.get(target.value)});
      }
      return demandView(Reflect.get(target,key,receiver));
    },
    set(){throw TypeError('Diagnostic prepared Base is read-only');},
    defineProperty(){throw TypeError('Diagnostic prepared Base is read-only');},
    deleteProperty(){throw TypeError('Diagnostic prepared Base is read-only');},
    preventExtensions(){throw TypeError('Diagnostic demand views do not support freezing');}
  });
  demandViews.set(value,view);demandWrapped++;return view;
}
export function setDemandPhase(name) {
  if(typeof name!=='string')throw TypeError('Demand phase must be a string');
  const old=demandPhase;demandPhase=name;return old;
}
export function getDemandReport() {
  const phases=[...demandPhases].map(([name,p])=>({name,reads:p.reads,nodeCount:p.nodes.size,nodeIds:[...p.nodes].sort((a,b)=>a-b),
    fields:Object.fromEntries([...p.fields].sort((a,b)=>b[1]-a[1])),definitionBodies:[...p.bodies.values()]}));
  return {schema:'phase64-base-demand-1',decodedNodes:demandNodes.length,wrappedNodes:demandWrapped,accessedNodes:demandAccessed.size,
    accessedNodeIds:[...demandAccessed].sort((a,b)=>a-b),phases,
    limits:['Proxy instrumentation is diagnostic and can perturb execution substantially.','Every node was eagerly decoded; accessed-node counts estimate demand, not actual selective allocation.','Current driver TODO scanning may touch all nodes; separate its phase or repeat after prepared TODO facts.','One fresh request only; persistent inspector freezing is intentionally unsupported by diagnostic proxies.']};
}
'''

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('helper');ap.add_argument('output');args=ap.parse_args()
    p=Path(args.helper);s=p.read_text();needle='  return {roots,nodes,kinds};'
    assert s.count(needle)==1,'Unexpected decoder return boundary'
    transformed=s.replace(needle,'  demandRegister(nodes);\n  return {roots:roots.map(demandView),nodes,kinds};')+TRACKER
    out=Path(args.output);out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('x') as f:f.write(transformed)
    manifest={'source':{'file':str(p.resolve()),'sha256':hashlib.sha256(s.encode()).hexdigest()},
              'candidate':{'file':str(out.resolve()),'sha256':hashlib.sha256(transformed.encode()).hexdigest()},
              'exports':['setDemandPhase','getDemandReport'],'transformation':'Return proxy views of decoded roots and append read-count instrumentation; original node graph/schema validation unchanged.'}
    with Path(str(out)+'.json').open('x') as f:json.dump(manifest,f,indent=2);f.write('\n')
    print(json.dumps(manifest))
