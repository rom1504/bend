#!/usr/bin/env python3
"""Byte-bound scalar fusion diagnostic. No production changes."""
from pathlib import Path
import argparse,json,hashlib

def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
a=argparse.ArgumentParser();a.add_argument('module',type=Path);a.add_argument('out',type=Path);a=a.parse_args()
root=Path(__file__).resolve().parents[5]
manifest=root/'selfhost/tools/performance/phase41/current/manifest.json'
m=json.loads(manifest.read_text());row=next(x for x in m['cases'] if x['id']=='coverage-list-pipeline-128')
parent=identity(a.module);assert parent['sha256']==row['modules']['candidate']['sha256']
assert m['roles']['candidate']['compiler']['api']['sha256']=='9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b'
s=a.module.read_text();lines=s.splitlines(keepends=True);line=next(x for x in lines if x.startswith('G["bench"]=scalarCapture'))
start=line.index('try{')+4;end=line.index('}finally{regionProofClose($previousProof);}')
old=line[start:end];assert old.startswith('const x3490=$s0;const x3491=$s1;return ')
names=['bench','p37.list','keep_gt1','keep_gt1.at','dbl','suma']
helpers="""
const $p42Counts={root:0,producer:0,filter:0,map:0,fold:0};
export function privateListCounts(){return {...$p42Counts};}
export function privateProofActive(){return regionProof!==null;}
const $p42Names=['bench','p37.list','keep_gt1','keep_gt1.at','dbl','suma'];
function $p42DiagnosticScope(n,s,body){
 if(!Number.isInteger(n)||n<0||n>30000||!Number.isInteger(s)||s<0||s>4294967295)throw Error('diagnostic domain');
 if(regionProof!==null||!regionHostGuard()||!localGuard($p42Names))return body();
 const previous=regionProofOpen($p42Names);try{return body();}finally{regionProofClose(previous);}
}
export function privateListStages(n,s){return $p42DiagnosticScope(n,s,()=>{
 const produced=call(G['p37.list'],[BigInt(n),s]);
 const filtered=call(G.keep_gt1,[produced]);
 const mapped=call(G.dbl,[filtered]);
 return {produced,filtered,mapped,sum:call(G.suma,[mapped,0])};
});}
export function privateListProducer(n,s){return $p42DiagnosticScope(n,s,()=>call(G['p37.list'],[BigInt(n),s]));}
export function privateListScalar(values,initial){
 let source={$:'Nil',a:[]};for(let i=values.length-1;i>=0;--i)source={$:'Con',a:[values[i],source]};
 const filtered=call(G.keep_gt1,[source]),mapped=call(G.dbl,[filtered]);
 const scalar=call(G.suma,[mapped,initial]);
 let fused=initial;for(let i=0;i<values.length;++i){const h=values[i];if(h>1){const y=Math.imul(h,2)>>>0;fused=(fused+y)>>>0;}}
 return {source,filtered,mapped,scalar,fused};
}

export function privateListAlias(){
 const tail={$:'Nil',a:[]},source={$:'Con',a:[0,{$:'Con',a:[7,tail]}]};
 const value=call(G.keep_gt1,[source]);
 return {value,sourceUnchanged:source.a[1].a[1]===tail,emptyFresh:value.a[1]!==tail};
}
"""
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
frozen=out/'consumed-derive.py';frozen.write_bytes(Path(__file__).read_bytes())
report=dict(kind='phase42-fusion-saved-js',complete=False,checked=False,parent=parent,manifest=identity(manifest),producer=identity(frozen),dependencies=names,modules=[],scope='Only existing private scalar root body; original public workers and fallback retained. Closed total U32 pipeline; no modulo-cycle shortcut.')
for counted in [False,True]:
 for variant in ['original','fused-bigint','fused-number']:
  text=s
  if variant!='original':
   begin='let n=BigInt($s0);' if variant=='fused-bigint' else 'let n=$s0;'
   zero='0n' if variant=='fused-bigint' else '0'
   body=('++$p42Counts.root;' if counted else '')+begin+'let seed=$s1,acc=0;while(n!=='+zero+'){const h=seed%16;--n;seed=(Math.imul(seed,1664525)+1013904223)>>>0;if(h>1){const y=Math.imul(h,2)>>>0;acc=(acc+y)>>>0;}}return acc;'
   replacement=line[:start]+body+line[end:]
   assert s.count(line)==1;text=s.replace(line,replacement)
  if counted:text+=helpers
  file=out/(variant+('.mjs' if counted else '.clean.mjs'));file.write_text(text)
  if variant=='original' and not counted:assert identity(file)['sha256']==parent['sha256']
  report['modules'].append(dict(variant=variant,counters=counted,**identity(file)))
report['complete']=True;(out/'derive.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,out=str(out),modules=6)))
