"""Count spill references in a small set of historically characterized owners."""
from collections import Counter
import json
import re
import subprocess
from project import BUILD, EMIT, HERE, ROOT, F, layout, sha

requests={
    'coverage-closures-256':['p113d_FID_$p121.callback.bench'],
    'coverage-expression-32':['p114r_FID_$direct.eval'],
    'variation-ray-active-64-2440':['p113d_FID_$product.nearest','p113d_FID_$product.trace'],
    'coverage-map-churn-32':['p113d_FID_$p118borrow.read.Map.bit.go','p111_FID_$direct.Map.ins.go'],
    'coverage-bst-64':['p113d_FID_$product.bst.down'],
    'phase195-compiler':['p113d_FID_$p118borrow.read.'+name for name in ['p88_string_eq_go','String.order.go','index_hash']],
}

def decode(s):
    return re.sub(r'(?:\d+_){2,}',lambda m:''.join(chr(int(i)) for i in m[0].strip('_').split('_')),s)

report={'scope':'New Phase198 N1 products; compiler rows use Phase195 qualified x86 N2. Explicit scalar-slot machine references exclude save/restore area, LEA, and implicit/indirect accesses; owner totals include alternate paths.', 'tools':{},'cases':{}}
for case,owners in requests.items():
    d=BUILD/'phase195/native-self01' if case=='phase195-compiler' else BUILD/'phase198/native45-01'/case/'machine'
    meta=json.loads((d/'report.json').read_text())
    e=d/'program'
    assert sha(e)==meta['binary']['sha256'] and sha(d/'program.o')==meta['object']['sha256']
    sym={}
    for l in subprocess.check_output(['nm','-S','--defined-only',str(e)],text=True).splitlines():
        cols=l.split()
        if len(cols)==4 and '_FID_' in cols[-1]:
            name=decode(cols[-1])
            if name in owners: sym[name]=(int(cols[0],16),int(cols[1],16))
    assert set(owners)==set(sym),set(owners)-set(sym)
    row=dict(binary=str(e.relative_to(ROOT)),sha=sha(e),owners={})
    for name,(start,size) in sym.items():
        lines=subprocess.check_output(['objdump','-dw','--no-show-raw-insn',f'--start-address={start}',f'--stop-address={start+size}',str(e)],text=True)
        full=Counter()
        slots=Counter()
        frame=None
        for l in lines.splitlines():
            m=re.match(r'^\s*[0-9a-f]+:\s+(\S+)\s*(.*)',l)
            if not m: continue
            op,args=m.groups()
            full[op]+=1
            if op=='sub' and args.endswith(',%rsp') and frame is None: frame=int(args.split(',')[0].lstrip('$'),0)
            for off in re.findall(r'-(0x[0-9a-f]+|\d+)\(%rbp\)',args):
                disp=int(off,0)
                if op!='lea' and disp>40:slots[disp]+=1
        row['owners'][name]=dict(start=hex(start),bytes=size,instructions=sum(full.values()),frame=frame,
                calls=full['call']+full['callq'],stackReferences=sum(slots.values()),distinctScalarSlots=len(slots))
    report['cases'][case]=row

counts=Counter()
total=0
files=sorted((BUILD/'phase195/profile-tree-bst01').glob('*sample*coverage-bst*candidate-candidate/analysis.json'))
assert len(files)==2
for f in files:
    j=json.loads(f.read_text())
    for pc in j['pcs']:
        weight=j['header']['period_us']*pc['samples']
        counts[pc.get('symbol')]+=weight
        total+=weight
src=(EMIT/'coverage-bst-64/program.s').read_text()
out={}
for m in F.finditer(src):
    _,v=layout(m[1],'rbp')
    if v.get('promoted'):
        out[decode(m[2])]=dict(promotedStaticReferences=v['promoted'],historicalOwnerWeight=counts[m[2]]/total)
report.update(method=sha(__import__('pathlib').Path(__file__)),historicalPhase195BST=dict(
    captures=[dict(path=str(f.relative_to(ROOT)),sha=sha(f)) for f in files],weightedSamples=total,owners=out))
(HERE/'owners.json').write_text(json.dumps(report,indent=2)+'\n')
