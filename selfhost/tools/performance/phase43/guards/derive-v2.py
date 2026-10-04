#!/usr/bin/env python3
"""Saved-output guard ablation. No compiler build or timing."""
import argparse,difflib,hashlib,json,pathlib,re,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser();p.add_argument('--out',required=True);p.add_argument('--module');a=p.parse_args()
out=pathlib.Path(a.out);out.mkdir(parents=True,exist_ok=False)
runtime=(ROOT/'selfhost/src/runtime/js/core.mjs').read_text()
def transform(s):
    start=s.index("function scalarGuard(names){");end=s.index("// Local arrays",start)
    original_scalar=s[start:end]
    old="function scalarGuard(names){";assert s.count(old)==1
    s=s.replace(old,"function scalarGuard(names,hostChecked=false){")
    old="for(const p of [scalarObjectPrototype,...scalarPrimitivePrototypes]){\n    if(p!==scalarObjectPrototype&&Object.getPrototypeOf(p)!==scalarObjectPrototype)return false;\n    for(const k of ['request','bounce','build','code'])if(Object.getOwnPropertyDescriptor(p,k))return false;\n  }\n  for(const k of ['io','typeName'])if(Object.getOwnPropertyDescriptor(scalarObjectPrototype,k))return false;"
    new="""// A successful host guard already checked the exact Object.prototype key set.
  // The module-init contract makes its original set free of marker keys.
  if(!hostChecked){
    if(Object.getOwnPropertyDescriptor(scalarObjectPrototype,'request')||
       Object.getOwnPropertyDescriptor(scalarObjectPrototype,'bounce')||
       Object.getOwnPropertyDescriptor(scalarObjectPrototype,'build')||
       Object.getOwnPropertyDescriptor(scalarObjectPrototype,'code')||
       Object.getOwnPropertyDescriptor(scalarObjectPrototype,'io')||
       Object.getOwnPropertyDescriptor(scalarObjectPrototype,'typeName'))return false;
  }
  for(let i=0;i<scalarPrimitivePrototypes.length;i++){
    const p=scalarPrimitivePrototypes[i];
    if(Object.getPrototypeOf(p)!==scalarObjectPrototype||
       Object.getOwnPropertyDescriptor(p,'request')||Object.getOwnPropertyDescriptor(p,'bounce')||
       Object.getOwnPropertyDescriptor(p,'build')||Object.getOwnPropertyDescriptor(p,'code'))return false;
  }"""
    assert s.count(old)==1;s=s.replace(old,new)
    old="![a,c,e,b].every(d=>Object.hasOwn(d,'value'))"
    assert s.count(old)==1
    s=s.replace(old,"!Object.hasOwn(a,'value')||!Object.hasOwn(c,'value')||!Object.hasOwn(e,'value')||!Object.hasOwn(b,'value')")
    # Avoid the per-dependency temporary key array as well.
    old="for(const k of ['io','typeName'])if(Object.getOwnPropertyDescriptor(f,k))return false;"
    assert s.count(old)==1;s=s.replace(old,"if(Object.getOwnPropertyDescriptor(f,'io')||Object.getOwnPropertyDescriptor(f,'typeName'))return false;")
    marker="// New floating regions may skip generic dispatch between native operations."
    assert s.count(marker)==1
    s=s.replace(marker,"""// Only an emitted guard clause after regionHostGuard and inert canonical-input
// tests may call this helper. No mutable state carries success across invocations.
function localGuardAfterHost(names){
  return regionProofCovers(names)||scalarGuard(names,true);
}
"""+marker)
    start=s.index("function scalarGuard(names,hostChecked=false){");end=s.index("// Local arrays",start)
    optimized=s[start:end].replace("function scalarGuard(names,hostChecked=false){","function scalarGuardAfterHost(names){\n  const hostChecked=true;")
    optimized=optimized.replace("  const hostChecked=true;\n", "")
    optimized=re.sub(r"  // A successful host guard.*?\n  for\(let i=0;", "  // The dominating host guard proved Object.prototype marker absence.\n  for(let i=0;", optimized, count=1, flags=re.S)
    s=s[:start]+original_scalar+optimized+s[end:]
    s=s.replace("scalarGuard(names,true)","scalarGuardAfterHost(names)")
    return s
candidate=transform(runtime)
patch=''.join(difflib.unified_diff(runtime.splitlines(True),candidate.splitlines(True),fromfile='a/selfhost/src/runtime/js/core.mjs',tofile='b/selfhost/src/runtime/js/core.mjs'))
(out/'runtime.patch').write_text(patch);(out/'runtime.mjs').write_text(candidate)
if a.module:s=pathlib.Path(a.module).read_text();source=str(pathlib.Path(a.module).resolve())
else:
    m=json.loads((ROOT/'selfhost/tools/performance/phase42/current/manifest.json').read_text());case=next(c for c in m['cases'] if c['id']=='coverage-list-pipeline-512');item=case['modules']['candidate'];source=item['path']
    with tarfile.open(ROOT/'selfhost/tools/performance/phase42/current/programs.tar.gz') as t:s=t.extractfile(source).read().decode()
    assert hashlib.sha256(s.encode()).hexdigest()==item['sha256']
assert runtime in s,'saved module runtime differs from current runtime; refuse fuzzy derivation'
c=transform(s);rewrites=0
# Existing entry clauses put only scalar canonical tests between these guards.
# Refuse any clause containing a call/getter possibility; no arbitrary regex proof.
lines=[]
for line in c.splitlines(True):
    if 'regionHostGuard()&&' in line and '&&localGuard($guards)' in line:
        clauses=re.findall(r'regionHostGuard\(\)&&(.+?)&&localGuard\(\$guards\)',line)
        for clause in clauses:
            expected='&&'.join(f'(typeof $s{i}==="number"&&Number.isInteger($s{i})&&$s{i}>=0&&$s{i}<=4294967295)' for i in range(2))+'&&true'
            assert clause==expected,('unreviewed canonical-input clause',clause)
        rewrites+=len(clauses);line=line.replace('&&localGuard($guards)','&&localGuardAfterHost($guards)')
    lines.append(line)
c=''.join(lines)
assert rewrites>0
(out/'control.mjs').write_text(s);(out/'candidate.mjs').write_text(c)
# Diagnostic copies carry an identical extra export; measured copies above do not.
extra='\nconst __p43stats={fusion:0};\nexport const __p43={stats:__p43stats,scalarGuard,localGuard,regionHostGuard,regionProofOpen,regionProofClose,regionProofCovers,scalarSnapshots,floatView,regionNumericHooks,regionProtocolPairs,regionPrimitivePrototypes:scalarPrimitivePrototypes};\n'
marker='/* private total scalar fusion */';assert marker in s
(out/'control.oracle.mjs').write_text(s.replace(marker,marker+'__p43stats.fusion++;')+extra);(out/'candidate.oracle.mjs').write_text(c.replace(marker,marker+'__p43stats.fusion++;')+extra)
manifest={'kind':'phase43-saved-guard-ablation','source':source,'rewrittenHostGuardClauses':rewrites,'files':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in out.iterdir() if f.is_file()}}
(out/'derivation.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest))
