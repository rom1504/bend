"""Offline structural recurrence and ordinary-value oracle; no target execution."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
def pin(path):
    b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
def save(path, value):
    text = value if isinstance(value, str) else json.dumps(value, indent=2)+'\n'
    if path.exists():
        assert path.read_text() == text, 'refuse changed frozen output: '+str(path)
    else:
        path.write_text(text)
    return pin(path)

# These recurrences count source operations, not compiler-generated executions.
wz, fz, sz = [0], [0], [0]
wc, fc, sc = [1], [1], [0]
for d in range(1, 10):
    wz.append(2*wz[d-1]+1)
    fz.append(2*wz[d-1]+2*fz[d-1])
    sz.append(2*sz[d-1]+wz[d-1]+fz[d-1])
    wc.append(2*wc[d-1]+3)
    fc.append(2*wc[d-1]+2*fc[d-1]+1)
    sc.append(2*sc[d-1]+wc[d-1]+fc[d-1])
for d in range(2,10):
    assert sz[d] == 2**(d-2)*(d*d-3*d+4)-1
    assert sc[d] == 2**d*(d*d-d+2)-2
catalog = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
cases = [c for c in json.loads(catalog.read_text())['cases'] if c['family']=='tree-bitonic']
ceiling = save(HERE/'ceiling.json', dict(kind='source-structural-ceiling-not-measured',
    input=pin(catalog), rows=[dict(name=c['name'], source=c['source'], runtimeArgs=c['runtimeArgs'],
        zipSuccesses=sz[c['runtimeArgs'][0]], nodeConstructors=sc[c['runtimeArgs'][0]],
        maximumRemovedAllocations=2*sz[c['runtimeArgs'][0]],
        fraction=2*sz[c['runtimeArgs'][0]]/sc[c['runtimeArgs'][0]]) for c in cases]))

def show(x):
    return '['+x+']' if isinstance(x,str) else '('+show(x[0])+'|'+show(x[1])+')'
def cross(l,r):
    return 'none' if isinstance(l,str) or isinstance(r,str) else ((l[0],r[0]),(l[1],r[1]))
lines = [show(cross(('a','b'),('c','d')))]
l,r=('left:17','b'),('c','right:31')
lines.extend([show(cross(l,r)),show(l),show(r)])
v=('same:42','other')
lines.extend([show(cross(v,v)),show(v)])
lines.extend([show(cross(('alias:99','b'),('c','alias:99'))),'alias:99','[none]','[none]'])
stdout='\n'.join(lines)+'\n'
out=save(HERE/'ordinary.expected.stdout',stdout)
expected=save(HERE/'ordinary.expected.json',dict(status=0,stdout=stdout,stderr=''))
fixtures=save(HERE/'cases.json',dict(cases=[dict(name='p126-local-reshape-transfer',source=pin(HERE/'ordinary.bend'),expected=expected,expectedStdoutEvidence=expected,stdoutEvidence=out)]))
save(HERE/'manifest01.json',dict(kind='phase126-local-reshape-unintegrated-prototype',complete=False,
    checked=False,targetsRun=False, compilerHooks=[],
    modules=[pin(HERE/'recognizer.bend')],exports=['p126lr_inspect'],runtime=pin(HERE/'runtime-prototype.c'),
    frozenRuntime=pin(ROOT/'selfhost/build/phase125/runtime-verified01/runtime.c'),
    evidenceQbe=pin(ROOT/'selfhost/build/phase118/p125-verified-families06/tree-bitonic.ssa'),
    sourceCeiling=ceiling,controls=fixtures,oracle=pin(Path(__file__).resolve()),
    missing=['checked source admission query','finite semantic/refusal controls','original candidate wrapper and independently verified helper import','native/output/count/timing checks']))
print(json.dumps(dict(manifest=str(HERE/'manifest01.json'), outputs=len(lines), rows=json.loads((HERE/'ceiling.json').read_text())['rows'])))
