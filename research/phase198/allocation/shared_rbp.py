"""Offline ceiling for multiple private scalar slots sharing one preserved GPR."""
from collections import Counter
from pathlib import Path
import json
import re
from project import BUILD, HERE, ROOT, CASES, F, RBP, WRITE, loop_weighted_lines, source_root, sha

def unit(body):
    lines=body.splitlines()
    labels={l.rstrip(':'):i for i,l in enumerate(lines) if l.endswith(':')}
    accesses={}
    reads=Counter()
    writes=Counter()
    weights=Counter()
    excluded=set()
    repeated=loop_weighted_lines(lines)
    for i,l in enumerate(lines):
        m=RBP.search(l)
        if not m: continue
        n=int(m[1])
        if n<=40: continue
        op=l.split()[0]
        if op not in ('movq','movl','movd'):
            excluded.add(n)
            continue
        write=bool(WRITE.fullmatch(l))
        (writes if write else reads)[n]+=1
        accesses[i]=(n,write)
        weights[n]+=8 if i in repeated else 1
    choices=sorted((n for n in reads.keys() & writes.keys() if n not in excluded and weights[n]>=3),
                key=lambda n:(-weights[n],-writes[n]-reads[n],n))
    if not choices:return {}
    ids={n:1<<i for i,n in enumerate(choices)}
    succ=[]
    use=[]
    kill=[]
    for i,line in enumerate(lines):
        text=line.strip().split()
        op=text[0] if text else ''
        dest=[]
        if op.startswith('j'):
            if len(text)!=2 or text[1] not in labels:return {}
            dest.append(labels[text[1]])
        if op not in ('jmp','ret') and i+1<len(lines):dest.append(i+1)
        succ.append(dest)
        n,iswrite=accesses.get(i,(0,False))
        bit=ids.get(n,0)
        use.append(0 if iswrite else bit)
        kill.append(bit if iswrite else 0)
    after=[0]*len(lines)
    before=after.copy()
    for rounds in range(len(lines)+1):
        changed=False
        for i in reversed(range(len(lines))):
            out=0
            for edge in succ[i]:out|=before[edge]
            new=use[i]|(out&~kill[i])
            if before[i]!=new:changed=True
            after[i]=out
            before[i]=new
        if not changed:break
    else:raise ValueError('fixed point')
    admitted=0
    picked=[]
    # Co-live values and all writes (including dead ones) conflict. Each
    # candidate slot is used solely by complete word stores / known reads.
    for n in choices:
        candidate=admitted|ids[n]
        def multiple(mask):
            group=mask&candidate
            return group&(group-1)
        if not any(multiple(a) or multiple(b|d) for a,b,d in zip(before,after,kill)):
            admitted=candidate
            picked.append(n)
    assert picked[0]==choices[0]
    first=choices[0]
    return dict(candidates=len(choices),selected=len(picked),
        one=reads[first]+writes[first],multi=sum(reads[n]+writes[n] for n in picked),
        peak=max(bin(n).count('1') for n in before),rounds=rounds+1,offsets=picked)

def main():
    report=dict(scope='Static occurrence count; one extra call-preserved RBP home, no dynamic timings or compiler implementation.', cases={})
    for c in CASES:
        p=source_root(c)/c/'program.s'
        rows={}
        for m in F.finditer(p.read_text()):
            counts=unit(m[1])
            if counts:rows[m[2]]=counts
        report['cases'][c]=dict(sourceSha=sha(p),owners=rows,
            one=sum(r['one'] for r in rows.values()),multi=sum(r['multi'] for r in rows.values()))
    report['method']=sha(Path(__file__))
    (HERE/'shared-rbp.json').write_text(json.dumps(report,indent=2)+'\n')
    for c,r in report['cases'].items():print(c,r['one'],r['multi'])

if __name__=='__main__':main()
