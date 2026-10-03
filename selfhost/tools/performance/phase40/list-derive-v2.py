#!/usr/bin/env python3
"""Saved-JS list prototype, immutable Phase39 byte-bound input; no compiler changes."""
from pathlib import Path
import argparse,hashlib,json

def ident(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
p=argparse.ArgumentParser();p.add_argument('module',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
root=Path(__file__).resolve().parents[4];manifest=root/'selfhost/tools/performance/phase39/current/manifest.json'
m=json.loads(manifest.read_text());row=next(x for x in m['cases'] if x['id']=='coverage-list-pipeline-128')
parent=ident(a.module);assert parent['sha256']==row['modules']['candidate']['sha256'];assert m['roles']['candidate']['compiler']['api']['sha256']=='04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f'
s=a.module.read_text();start=s.index('G["bench"]=scalarCapture("bench",fn(2,function(a){');end=s.index('\n',start)
original=s[start:end];assert 'const x3490=a[0];const x3491=a[1];' in original
names=['bench','p37.list','keep_gt1','keep_gt1.at','dbl','suma']
helper='''
const $p40Names=NAMES;
for(const name of $p40Names)if(name!=='bench')scalarCapture(name,G[name]);
COUNTERS
function $p40List(n,s){COUNT_PRODUCER
 const frames=[];let top=0;
 while(n!==0n){frames[top++]=s%16;--n;s=(Math.imul(s,1664525)+1013904223)>>>0;}
 let v={$:'Nil',a:[]};while(top)v={$:'Con',a:[frames[--top],v]};return v;
}
function $p40Filter(xs){COUNT_FILTER
 const frames=[];let top=0;
 while(xs.$==='Con'){frames[top++]=xs.a[0];xs=xs.a[1];}
 let v={$:'Nil',a:[]};while(top){const h=frames[--top];if(h>1)v={$:'Con',a:[h,v]};}return v;
}
function $p40Map(xs){COUNT_MAP
 const frames=[];let top=0;
 while(xs.$==='Con'){frames[top++]=Math.imul(xs.a[0],2)>>>0;xs=xs.a[1];}
 let v={$:'Nil',a:[]};while(top)v={$:'Con',a:[frames[--top],v]};return v;
}
function $p40Fold(xs,acc){COUNT_FOLD
 while(xs.$==='Con'){acc=(acc+xs.a[0])>>>0;xs=xs.a[1];}return acc;
}
'''.replace('NAMES',json.dumps(names))
def additions(counters,variant):
 h=helper.replace('COUNTERS','const $p40Counts={root:0,producer:0,filter:0,map:0,fold:0};' if counters else '')
 for field in ['producer','filter','map','fold']:h=h.replace('COUNT_'+field.upper(),'++$p40Counts.'+field+';' if counters else '')
 if counters:
  h+='''
export function privateListCounts(){return {...$p40Counts};}
export function privateProofActive(){return regionProof!==null;}
export function privateListStages(n,s){
 if(!Number.isInteger(n)||n<0||n>30000||!Number.isInteger(s)||s<0||s>4294967295)throw Error('diagnostic domain');
 const direct=VARIANT&&regionProof===null&&regionHostGuard()&&localGuard($p40Names);
 const produced=direct?$p40List(BigInt(n),s):call(G['p37.list'],[BigInt(n),s]);
 const filtered=direct&&COMPONENT?$p40Filter(produced):call(G.keep_gt1,[produced]);
 const mapped=direct&&COMPONENT?$p40Map(filtered):call(G.dbl,[filtered]);
 return {produced,filtered,mapped,sum:direct&&COMPONENT?$p40Fold(mapped,0):call(G.suma,[mapped,0])};
}
export function privateListProducer(n,s){
 if(!Number.isInteger(n)||n<0||n>30000||!Number.isInteger(s)||s<0||s>4294967295)throw Error('diagnostic domain');
 if(VARIANT&&regionProof===null&&regionHostGuard()&&localGuard($p40Names))return $p40List(BigInt(n),s);
 return call(G['p37.list'],[BigInt(n),s]);
}
export function privateListAlias(){
 const tail={$:'Nil',a:[]},source={$:'Con',a:[0,{$:'Con',a:[7,tail]}]};
 const direct=COMPONENT&&regionProof===null&&regionHostGuard()&&localGuard($p40Names);
 const filtered=direct?$p40Filter(source):call(G.keep_gt1,[source]);
 return {value:filtered,sourceUnchanged:source.a[1].a[1]===tail,emptyFresh:filtered.a[1]!==tail};
}
'''.replace('VARIANT','true' if variant!='original' else 'false').replace('COMPONENT','true' if variant=='component' else 'false')
 return h
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
report=dict(kind='phase40-list-saved-js',complete=False,checked=False,certified=False,parent=parent,manifest=ident(manifest),producer=ident(__file__),dependencies=names,modules=[],scope='Private scalar root only; first-order complete materialized stages; BigInt countdown unchanged.')
for counters in [False,True]:
 for variant in ['original','producer','component']:
  text=s
  if variant!='original':
   callbody='const produced=$p40List(BigInt(x3490),x3491);'
   callbody+=('return $p40Fold($p40Map($p40Filter(produced)),0);' if variant=='component' else 'return jump(callOwned(get(G,"suma"),[callOwned(get(G,"dbl"),[callOwned(get(G,"keep_gt1"),[produced])])]),[0]);')
   generic=original.split('const x3491=a[1];',1)[1].removesuffix('}));')
   replacement='G["bench"]=scalarCapture("bench",fn(2,exactCode(function(a,$entered){const x3490=a[0];const x3491=a[1];if($entered&&regionProof===null&&regionHostGuard()&&Number.isInteger(x3490)&&x3490>=0&&x3490<=4294967295&&Number.isInteger(x3491)&&x3491>=0&&x3491<=4294967295&&localGuard($p40Names)){'+('++$p40Counts.root;' if counters else '')+callbody+'}'+generic+'})));'
   text=text[:start]+replacement+text[end:]
  if counters or variant!='original':text+=additions(counters,variant)
  f=out/(variant+('.mjs' if counters else '.clean.mjs'));f.write_text(text)
  if variant=='original' and not counters:assert ident(f)['sha256']==parent['sha256']
  report['modules'].append(dict(variant=variant,counters=counters,**ident(f)))
report['complete']=True;(out/'derive.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,out=str(out),modules=6)))
