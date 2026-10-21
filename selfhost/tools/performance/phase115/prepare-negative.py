import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
s=json.loads((ROOT/'implementation/phase114/selection.json').read_text())['nativeQualified']
for key in ['source','api','admission','runtime']:assert pin(s[key]['file'])==s[key]
text=Path(s['source']['file']).read_text();module=HERE/'negative-decision.bend';overlay=module.read_text()
pat=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)
def blocks(t):
 hits=list(pat.finditer(t));return {m[1]:t[m.start():hits[i+1].start() if i+1<len(hits) else len(t)] for i,m in enumerate(hits)}
before=blocks(text);new=blocks(overlay);assert set(new)=={'p114hf_planned','p115n_public_r','p115n_public_g'}
assert set(before)&set(new)=={'p114hf_planned'}
# Retain all original bytes except the one explicit declaration; append helpers.
hits=list(pat.finditer(text));at=next(i for i,m in enumerate(hits) if m[1]=='p114hf_planned');a=hits[at].start();b=hits[at+1].start()
composed=text[:a]+new['p114hf_planned'].rstrip()+'\n\n'+text[b:]+'\n'+new['p115n_public_r']+'\n'+new['p115n_public_g']
after=blocks(composed)
def norm(t):return '\n'.join(x.rstrip() for x in t.splitlines() if x.strip() and not x.lstrip().startswith('#'))
assert all(norm(after[k])==norm(v) for k,v in before.items() if k!='p114hf_planned')
out=ROOT/'selfhost/build/phase115/negative-source01';assert not out.exists();out.mkdir();(out/'compiler.bend').write_text(composed);(out/'module.bend').write_bytes(module.read_bytes())
r=dict(complete=True,checked=False,source=pin(out/'compiler.bend'),parent=s['source'],overrides=['p114hf_planned'],added=['p115n_public_r','p115n_public_g'],inputs=[pin(__file__),pin(module),s['source'],s['api'],s['admission'],s['runtime']],physicalLines=len(composed.splitlines()),parentLines=len(text.splitlines()))
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['source']))
