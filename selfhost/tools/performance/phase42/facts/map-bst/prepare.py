#!/usr/bin/env python3
"""Prepare one saved-JS Map String.cmp ablation; execute no target/compiler."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('manifest', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
manifest = a.manifest.resolve()
bundle = json.loads(manifest.read_text())
case = next(c for c in bundle['cases'] if c['id'] == 'coverage-map-churn-128')
entry = case['modules']['candidate']
archive = manifest.parent / 'programs.tar.gz'
with tarfile.open(archive) as tar:
    candidates = [m for m in tar.getmembers() if m.name.endswith(entry['path'])]
    assert len(candidates) == 1
    raw = tar.extractfile(candidates[0]).read()
assert hashlib.sha256(raw).hexdigest() == entry['sha256']
assert len(raw) == entry['bytes']
source = raw.decode()
definitions = {m.group(1): m.group(0) for m in re.finditer(r'^G\["([^"\n]+)"\]=.*$', source, re.M)}
todo, seen = ['String.cmp'], set()
while todo:
    name = todo.pop()
    if name in seen:
        continue
    seen.add(name)
    todo.extend(n for n in re.findall(r'get\(G,"([^"\n]+)"\)', definitions.get(name, '')) if n not in seen)
assert seen == {'String.cmp', 'String.cmp.fin', 'String.cmp.rec', 'Char.cmp', 'U32.cmp'}
pattern = re.compile(r'callOwned\(callOwned\(get\(G,"String\.cmp"\),\[(x\d+)\]\),\[(x\d+)\]\)')
lines, sites = [], []
for line in source.splitlines(True):
    if line.startswith('G["Map.'):
        count = len(pattern.findall(line))
        if count:
            sites.append(dict(definition=line.split('"')[1], sites=count))
            line = pattern.sub(r'$p42MapCmp(\1,\2)', line)
    lines.append(line)
assert sum(s['sites'] for s in sites) == 8
candidate = ''.join(lines)
assert candidate.count('G["String.cmp"]=') == 1
candidate = candidate.replace('G["String.cmp"]=', 'const $p42NativeCmp=G["String.cmp"];\nG["String.cmp"]=', 1)
common = r'''
export const phase42MapDebug={
 cmp:(a,b)=>force(callOwned(callOwned(get(G,"String.cmp"),[a]),[b])),
 complete:x=>force(x),guards:()=>regionHostGuard()&&scalarGuard([])
};
'''
worker = r'''
const $p42StringCtor=String,$p42StringPrototype=String.prototype;
const $p42StringHooks=[[globalThis,'String'],[$p42StringCtor,'prototype'],[$p42StringCtor,'fromCodePoint'],
 [$p42StringPrototype,'codePointAt'],[$p42StringPrototype,'slice'],[$p42StringPrototype,'constructor']];
const $p42StringDescriptors=$p42StringHooks.map(p=>regionGetDescriptor(p[0],p[1]));
const $p42CmpNames=['String.cmp','String.cmp.fin','String.cmp.rec','Char.cmp','U32.cmp'];
for(const name of $p42CmpNames)scalarCapture(name,G[name]);
let $p42Entries=0,$p42Fallbacks=0;
function $p42StringGuard(){
 if(regionProof!==null||!regionHostGuard()||!localGuard($p42CmpNames))return false;
 for(let i=0;i<$p42StringHooks.length;i++){
  const p=$p42StringHooks[i],old=$p42StringDescriptors[i],d=regionGetDescriptor(p[0],p[1]);
  if(!old||!d||!regionOwn(old,'value')||!regionOwn(d,'value')||d.value!==old.value||
    d.writable!==old.writable||d.enumerable!==old.enumerable||d.configurable!==old.configurable)return false;
 }
 return true;
}
function $p42MapCmp(a,b){
 if(typeof a==='string'&&typeof b==='string'&&$p42StringGuard()){
  ++$p42Entries;return callOwned($p42NativeCmp,[a,b]);
 }
 ++$p42Fallbacks;return callOwned(callOwned(get(G,'String.cmp'),[a]),[b]);
}
export const phase42MapDebug={cmp:(a,b)=>force($p42MapCmp(a,b)),complete:x=>force(x),
 entries:()=>({entries:$p42Entries,fallbacks:$p42Fallbacks}),guard:$p42StringGuard,
 guards:()=>regionHostGuard()&&scalarGuard([])};
'''
out = a.out.resolve()
assert not out.exists()
out.mkdir(parents=True)
(out / 'baseline.mjs').write_text(source + common)
(out / 'candidate.mjs').write_text(candidate + worker)
report = dict(kind='phase42-saved-map-string-comparison-ablation', complete=True, executed=False,
              compilerAdmission=False, originalSha256=entry['sha256'], originalBytes=len(raw),
              manifest=dict(file=str(manifest), sha256=hashlib.sha256(manifest.read_bytes()).hexdigest()),
              toolSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), sites=sites, dependencies=sorted(seen),
              scope='Eight Map call sites bypass generic String.cmp recursion only for plain strings under postinitialization descriptor/dependency guards. Public descriptors unchanged. Original native String.cmp captured before source override. No proof opened; existing proof means fallback. Preimport host mutation remains a production blocker.',
              modules={role:dict(file=str(out / (role + '.mjs')), sha256=hashlib.sha256((out / (role + '.mjs')).read_bytes()).hexdigest()) for role in ['baseline', 'candidate']})
(out / 'preparation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report))
