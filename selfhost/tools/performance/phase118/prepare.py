"""Exact declaration overlay transport; no compiler lowering in this script."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
pat=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)
def blocks(t):
 hits=list(pat.finditer(t));return {m[1]:t[m.start():hits[i+1].start() if i+1<len(hits) else len(t)] for i,m in enumerate(hits)}
def norm(t):return '\n'.join(x.rstrip() for x in t.splitlines() if x.strip() and not x.lstrip().startswith('#'))
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--module',type=Path,action='append',required=True);p.add_argument('--overrides',nargs='+',required=True);p.add_argument('--module-overrides',nargs='*',default=[]);a=p.parse_args()
s=json.loads((ROOT/'implementation/phase117/selection.json').read_text())
for k in ['source','api','runtime']:assert pin(s[k]['file'])==s[k]
text=Path(s['source']['file']).read_text();before=blocks(text);new={};replaced=set()
for module in a.module:
 m=blocks(module.read_text());overlap=set(new)&set(m);assert overlap<=set(a.module_overrides);replaced|=overlap;new.update(m)
assert replaced==set(a.module_overrides)
assert set(before)&set(new)==set(a.overrides)
assert all(n.startswith(('p118','P118')) for n in set(new)-set(before))
hits=list(pat.finditer(text));pieces=[text[:hits[0].start()]]
for i,m in enumerate(hits):
 original=text[m.start():hits[i+1].start() if i+1<len(hits) else len(text)]
 pieces.append(new[m[1]].rstrip()+'\n\n' if m[1] in new else original)
for n in new:
 if n not in before:pieces.append('\n'+new[n])
composed=''.join(pieces);after=blocks(composed)
assert set(after)==set(before)|set(new)
assert all(norm(after[k])==norm(new.get(k,v)) for k,v in before.items())
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir(parents=True)
(out/'compiler.bend').write_text(composed)
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
for i,module in enumerate(a.module):(out/f'module{i}.bend').write_bytes(module.read_bytes())
r=dict(complete=True,checked=False,source=pin(out/'compiler.bend'),parent=s['source'],overrides=a.overrides,moduleOverrides=a.module_overrides,added=sorted(set(new)-set(before)),inputs=[pin(__file__),*[pin(m) for m in a.module],s['source'],s['api'],s['runtime']],physicalLines=len(composed.splitlines()),parentLines=len(text.splitlines()))
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['source']))
