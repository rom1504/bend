"""Project two late allocator policies onto exact Phase197 selected assembly."""
from collections import Counter
from pathlib import Path
import json
import hashlib
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT/'selfhost/build'
EMIT = BUILD/'phase197/shared-emission01/combined'
F = re.compile(r'(^\.type ([^\n,]+), @function\n.*?^\.size \2[^\n]*$)', re.M | re.S)
RBP = re.compile(r'-(\d+)\(%rbp\)')
RSP = re.compile(r'(?<![\d-])(\d+)\(%rsp\)')
FRAME = re.compile(r'^  subq \$(\d+), %rsp$', re.M)
WRITE = re.compile(r'^  movq %\w+, -(\d+)\(%rbp\)$')
RAY = 'variation-ray-active-64-2440'
CASES = ['coverage-bst-64','editdist',RAY,'mandelbrot']
def source_root(case):
    return BUILD/'phase195/prepared-combined01/combined' if case==RAY else EMIT
ROLES = ['baseline','discard','pack','rbp']
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def loop_weighted_lines(lines):
    labels={l.rstrip(':'):i for i,l in enumerate(lines) if l.endswith(':')}
    pred=[[] for _ in lines]
    lat=[]
    for i,l in enumerate(lines):
        words=l.strip().split()
        op=words[0] if words else ''
        if op.startswith('j') and len(words)==2 and words[1] in labels:
            target=labels[words[1]]
            if target<i and words[1].endswith('_loop'):
                lat.append(i)
                continue
            pred[target].append(i)
        if op not in ('jmp','ret') and i+1<len(lines): pred[i+1].append(i)
    hot=set()
    while lat:
        i=lat.pop()
        if i not in hot:
            hot.add(i)
            if not lines[i].endswith('_loop:'):lat.extend(pred[i])
    return hot

def layout(body, role):
    sites = Counter()
    bufs = set()
    read = set()
    stores = Counter()
    stack_args = 0
    match = FRAME.search(body)
    if not match:
        return body, {}
    old = int(match[1])
    assert body.count('subq $') >= 1 and len(FRAME.findall(body)) == 1
    for l in body.splitlines():
        if '%rsp' in l:
            if rsp := RSP.search(l):
                assert l.startswith('  movq ') and rsp[0] in l
                stack_args = max(stack_args, int(rsp[1])+8)
            else:
                assert l in ('  movq %rsp, %rbp','  movq %rbp, %rsp',match[0]), l
        if m := RBP.search(l):
            x = int(m[1])
            if x > 40:
                if l.startswith('  leaq '): bufs.add(x)
                else:
                    sites[x] += 1
                    if WRITE.fullmatch(l): stores[x] += 1
                    else: read.add(x)
    assert not bufs.intersection(sites), (bufs,sites)
    assert all(x % 8 == 0 for x in sites)
    dead = set(sites)-read
    # Emitter's only stores directly to a negative RBP+disp are callee saves
    # or stores to individual X181Stack homes. Buffer bases are obtained by LEA.
    if role == 'discard':
        body = '\n'.join(l for l in body.split('\n')
            if not ((m := WRITE.fullmatch(l)) and int(m[1]) in dead))
    # Reserve every named scalar word, in weighted order. Preserve each
    # observed buffer address relative to every other observed buffer by a
    # single uniform translation; bound the highest buffer's extent using the
    # shallowest scalar/save preceding it under the original monotone layout.
    if role == 'pack':
        mapping = {x:48+8*i for i,x in enumerate(sorted(sites,key=lambda x:(-sites[x],x)))}
        used = 40 + 8*len(mapping)
        if bufs:
            high = min(bufs)
            prior = max([40,*[x for x in sites if x < high]])
            shift = prior - used
            shift -= shift % 16
            for x in bufs: mapping[x] = x - shift
            used = max(bufs) - shift
        new = (used + stack_args + 15)//16*16
        # Avoid increasing frame depth. The estimate retains the complete
        # intervening span between multiple buffers, even unused gaps.
        applied = new <= old
        if applied:
            body = RBP.sub(lambda m: f'-{mapping.get(int(m[1]),int(m[1]))}(%rbp)',body)
            body = FRAME.sub(f'  subq ${new}, %rsp', body)
        else: new = old
    else: new = old
    promoted = 0
    selected = 0
    if role == 'rbp':
        # A fixed RSP leaves one occupied, callee-preserved GPR recoverable.
        # Only scalar Stack offsets can enter. Keep loads/stores for all other
        # offsets and the original aligned reservation. The push/pop still
        # save and restore the caller's RBP, including on all return arms.
        uses = Counter()
        frequency = Counter()
        lines = body.splitlines()
        loop = loop_weighted_lines(lines)
        eligible = {v for v in read if stores[v]}
        for i,l in enumerate(lines):
            if m := RBP.search(l):
                v=int(m[1])
                if l.split()[0] not in ('movq','movl','movd'): eligible.discard(v)
                else:
                    uses[v] += 1
                    frequency[v] += 8 if i in loop else 1
        eligible={v for v in eligible if frequency[v]>=3}
        if eligible:
            selected=max(eligible,key=lambda v:(frequency[v],uses[v],-v))
        if selected:
            promoted=uses[selected]
            def rewrite(l):
                if l=='  movq %rsp, %rbp': return None
                if l=='  movq %rbp, %rsp': return f'  leaq {old}(%rsp), %rsp'
                if l in ('  pushq %rbp','  popq %rbp'): return l
                if '%rbp' not in l: return l
                assert re.fullmatch(r'.*-?\d+\(%rbp\).*',l),l
                def operand(m):
                    displacement=int(m[1])
                    if displacement == -selected:
                        return '%rbp' if l.split()[0]=='movq' else '%ebp'
                    return f'{old+displacement}(%rsp)'
                return re.sub(r'(-?\d+)\(%rbp\)',operand,l)
            body='\n'.join(line for x in body.split('\n') if (line:=rewrite(x)) is not None)
    return body, dict(bytes=old,new=new,promoted=promoted,scalars=len(sites),buffers=len(bufs),
        shortBefore=sum(n for x,n in sites.items() if x<=128),
        dead=sum(stores[x] for x in dead),shortAfter=sum(n for x,n in sites.items() if (mapping.get(x,x) if role=='pack' and applied else x)<=128))

def project(src, role):
    stats={}
    def transform(m):
        body,counts=layout(m[1],role)
        if counts: stats[m[2]]=counts
        return body
    output=F.sub(transform,src)
    assert len(stats)>100
    return output,stats

if __name__=='__main__':
    frozen={}
    for case in CASES:
        origin=source_root(case)/case
        source=origin/'program.s'
        text=source.read_text()
        frozen[case]=dict(source=str(source.relative_to(ROOT)),sourceSha=sha(source),objectSha=sha(origin/'program.o'),roles={})
        for role in ROLES:
            emitted,rows=project(text,role)
            if role=='baseline': assert emitted==text
            frozen[case]['roles'][role]=dict(sha=hashlib.sha256(emitted.encode()).hexdigest(),functions=len(rows),
                totals=dict(sum((Counter(v) for v in rows.values()),Counter())))
    (HERE/'frozen.json').write_text(json.dumps(dict(policy='Separate discard, pack and fixed-RSP RBP promotion arms; require median <=0.98 and >=3/4 favorable pairs in both layouts to justify acquiring a source candidate. This first screen is one session.', implementation=sha(Path(__file__)), cases=frozen),indent=2)+'\n')
