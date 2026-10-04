#!/usr/bin/env python3
"""Independent full-total-U32-fusion host domain saved-output ablation."""
import argparse,difflib,hashlib,json,pathlib,re,subprocess,sys
p=argparse.ArgumentParser();p.add_argument('--out',required=True);a=p.parse_args();out=pathlib.Path(a.out)
subprocess.run([sys.executable,str(pathlib.Path(__file__).with_name('derive-v2.py')),'--out',str(out)],check=True,stdout=subprocess.DEVNULL)
root=pathlib.Path(__file__).resolve().parents[5];runtime=(root/'selfhost/src/runtime/js/core.mjs').read_text();control=(out/'control.mjs').read_text()
start=runtime.index('function regionHostGuard(){');end=runtime.index('\nconst native=',start);host=runtime[start:end]
assert host.count('regionGetPrototype(floatView)!==regionDataViewPrototype')==1
# A const dependency set is not a cache of mutable host observations.
subset="""// Full total-U32 fusion needs integer hooks; all current descriptors are still
// checked afresh at each entry. This private set contains immutable dependencies.
const regionU32FusionHooks=[];
for(let i=0;i<regionNumericHooks.length;i++){
  const p=regionNumericHooks[i];
  if(p[0]===regionDataViewPrototype||(p[0]===Math&&p[1]!=='imul')||
      (p[0]===Number&&(p[1]==='isNaN'||p[1]==='isFinite')))continue;
  regionU32FusionHooks[regionU32FusionHooks.length]=p;
}
"""
changed=host.replace('function regionHostGuard(){','function regionHostGuard(u32Fusion=false){')
old="""  if(regionGetPrototype(floatView)!==regionDataViewPrototype)return false;
  for(let i=0;i<regionDataViewKeys.length;i++)if(regionGetDescriptor(floatView,regionDataViewKeys[i]))return false;
  for(let i=0;i<regionNumericHooks.length;i++){
    const p=regionNumericHooks[i],d=regionGetDescriptor(p[0],p[1]);"""
new="""  if(!u32Fusion){
    if(regionGetPrototype(floatView)!==regionDataViewPrototype)return false;
    for(let i=0;i<regionDataViewKeys.length;i++)if(regionGetDescriptor(floatView,regionDataViewKeys[i]))return false;
  }
  const hooks=u32Fusion?regionU32FusionHooks:regionNumericHooks;
  for(let i=0;i<hooks.length;i++){
    const p=hooks[i],d=regionGetDescriptor(p[0],p[1]);"""
assert changed.count(old)==1;changed=changed.replace(old,new)
newruntime=runtime[:start]+subset+changed+runtime[end:];candidate=control.replace(runtime,newruntime)
needle='if($entered&&regionHostGuard()&&(typeof $s0==="number"&&Number.isInteger($s0)&&$s0>=0&&$s0<=4294967295)&&(typeof $s1==="number"&&Number.isInteger($s1)&&$s1>=0&&$s1<=4294967295)&&true&&localGuard($guards))'
assert candidate.count(needle)==1;candidate=candidate.replace(needle,needle.replace('regionHostGuard()','regionHostGuard(true)'))
# Freeze the reviewed full chain identity and ensure no generic operation in loop.
assert 'const $guards=["bench","p37.list","keep_gt1","keep_gt1.at","dbl","suma"]' in control
body=control.split('/* private total scalar fusion */',1)[1].split('}finally{regionProofClose',1)[0]
assert 'call(' not in body and 'callOwned(' not in body and 'get(G' not in body
assert set(re.findall(r'Math\.([A-Za-z0-9_]+)',body))<={'imul'}
assert not re.search(r'DataView|floatView|Number\.(isFinite|isNaN)',body)
(out/'candidate.mjs').write_text(candidate);(out/'runtime.mjs').write_text(newruntime)
(out/'runtime.patch').write_text(''.join(difflib.unified_diff(runtime.splitlines(True),newruntime.splitlines(True),fromfile='a/selfhost/src/runtime/js/core.mjs',tofile='b/selfhost/src/runtime/js/core.mjs')))
extraoracle=(out/'control.oracle.mjs').read_text().split('\nconst __p43stats=',1)[1]
marker='/* private total scalar fusion */'
(out/'candidate.oracle.mjs').write_text(candidate.replace(marker,marker+'__p43stats.fusion++;')+'\nconst __p43stats='+extraoracle)
manifest={'kind':'phase43-total-u32-fusion-host-domain-v2','source':'Phase42 checked16 saved list512 module','scope':'independent numeric host-domain ablation, ordinary scalar/local guards unchanged','files':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in out.iterdir() if f.is_file() and f.name!='derivation.json'}}
(out/'derivation.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest))
