"""Offline physical placement census for block-local nonrecurrence spill intervals."""
from collections import Counter
import json, re
from pathlib import Path
from project import BUILD, EMIT, F, HERE, RBP, WRITE, loop_weighted_lines, sha

REGISTER = {
 'rcx':r'%(?:rcx|ecx|cx|cl|ch)\b','r10':r'%r10(?:d|w|b)?\b',
 'r11':r'%r11(?:d|w|b)?\b','rax':r'%(?:rax|eax|ax|al|ah)\b',
}
CANON = {'rcx':('rcx','ecx'),'rax':('rax','eax'),'r10':('r10','r10d'),'r11':('r11','r11d')}
EXPLICIT=re.compile(r'(?:mov(?:abs)?[lq]|movz[a-z]+|movd|lea[lq]|add[lq]|sub[lq]|and[lq]|or[lq]|xor[lq]|test[lq]|cmp[lq]|cmov[a-z]+|set[a-z]+|sh[lr][lq]|sa[lr][lq]|pushq|popq|j[a-z]+|ret)')
def opaque(line):
    if not line.startswith('  '):return False
    op=line.split()[0]
    if op in ('imulq','imull'):return ',' not in line
    return not EXPLICIT.fullmatch(op)

def occurrence(line, reg):
    return re.search(REGISTER[reg],line)

def touch(line, reg):
    if opaque(line):return 'use'
    if line=='  ret':return 'use' if reg=='rax' else ''
    if not occurrence(line,reg):return ''
    op=line.strip().split()[0]
    dst=line.rsplit(', ',1)[-1].removeprefix('%')
    if dst in CANON[reg] and ',' in line:
        src=line.rsplit(', ',1)[0]
        if re.fullmatch(r'(mov(?:abs)?[lq]|movz\w+|lea[lq])',op) and not occurrence(src,reg):return 'kill'
        if op in ('xorl','xorq') and line.rsplit(', ',1)[0].endswith('%'+dst):return 'kill'
    return 'use'

def unit(body,apply=None):
    lines=body.splitlines();hot=loop_weighted_lines(lines)
    labels={l.rstrip(':'):i for i,l in enumerate(lines) if l.endswith(':')}
    edges=[]
    segments=[]
    seg=0
    for i,l in enumerate(lines):
        w=l.strip().split();op=w[0] if w else ''
        if l.endswith(':'):seg+=1
        segments.append(seg)
        dest=[]
        if op.startswith('j'):
            if len(w)!=2 or w[1] not in labels:return body if apply else []
            dest.append(labels[w[1]])
        if op not in ('jmp','ret') and i+1<len(lines):dest.append(i+1)
        edges.append(dest)
        if op.startswith('j') or op.startswith('call') or op=='ret':seg+=1
    available={}
    for reg in REGISTER:
        use=[touch(l,reg) for l in lines]
        live=[False]*len(lines)
        for rounds in range(len(lines)+1):
            changed=False
            for i in reversed(range(len(lines))):
                new=use[i]=='use' or use[i]!='kill' and any(live[j] for j in edges[i])
                if live[i]!=new:changed=True
                live[i]=new
            if not changed:break
        available[reg]=live
    slots={}
    for i,l in enumerate(lines):
        if not (m:=RBP.search(l)):continue
        k=int(m[1])
        if k<=48: continue
        slots.setdefault(k,[]).append(i)
    candidates=[]
    for off,idx in slots.items():
        start,last=idx[0],idx[-1]
        store=WRITE.fullmatch(lines[start])
        if (not store or start not in hot or last not in hot or last==start or
            segments[start]!=segments[last] or any(not re.fullmatch(r'  mov(?:q|l) -\d+\(%rbp\), %\w+',lines[i]) for i in idx[1:])):continue
        src=lines[start].split('%')[1].split(',')[0]
        # A snapshot can stay in its pre-existing source home. Conservative whole
        # register coloring rejects even explicit reads and writes of that home.
        work=lines[start+1:last]
        original=src if src in REGISTER and not any(occurrence(l,src) or opaque(l) for l in work) else None
        possible=[reg for reg in REGISTER if not available[reg][start] and not any(occurrence(l,reg) or opaque(l) for l in lines[start:last+1])]
        options=([original] if original else [])+([] if apply=='producer' else possible)
        if options:candidates.append((start,last,idx,off,options))
    assigned={reg:[] for reg in REGISTER};out=[]
    for start,last,idx,off,options in sorted(candidates,key=lambda x:(-len(x[2]),x[1]-x[0])):
        for reg in options:
            if all(last<low or high<start for low,high in assigned[reg]):
                assigned[reg].append((start,last))
                out.append(dict(offset=off,accesses=len(idx),reg=reg,span=last-start,first=lines[start].strip(),last=lines[last].strip()))
                break
    if apply:
        for entry in out:
            off,reg=entry['offset'],entry['reg']
            idx=slots[off]
            src=lines[idx[0]].split('%')[1].split(',')[0]
            lines[idx[0]]='' if src==reg else f'  movq %{src}, %{reg}'
            for i in idx[1:]:
                op,dst=lines[i].split()[0],lines[i].split(', ')[-1]
                home=CANON[reg][int(op=='movl')]
                lines[i]='' if op=='movq' and dst=='%'+home else f'  {op} %{home}, {dst}'
        return '\n'.join(l for l in lines if l)
    return out

def project(text,role):
    if role=='baseline':return text
    assert role in ('producer','physical')
    def transform(m):
        if m[2].startswith('p113d_FID_') and '_loop:' in m[1] and '(%rbp)' in m[1]:
            return unit(m[1],role)
        return m[1]
    return F.sub(transform,text)

def decode(s):
    if '_FID_' not in s:return s
    try:p,n=s.split('_FID_');return p+'_'+''.join(chr(int(v)) for v in n.rstrip('_').split('_'))
    except ValueError:return s
if __name__=='__main__':
    prev=BUILD/'phase195/prepared-combined01/combined'
    paths={p.parent.name:p for p in prev.glob('*/program.s')}
    paths.update({p.parent.name:p for p in EMIT.glob('*/program.s')})
    result={}
    for case,p in paths.items():
        rows={}
        for m in F.finditer(p.read_text()):
            if not m[2].startswith('p113d_FID_'):continue
            if not ('_loop:' in m[1] and '(%rbp)' in m[1]):continue
            slots=unit(m[1])
            if slots:rows[decode(m[2])]=slots
        result[case]=dict(source=str(p),sha=sha(p),owners=rows)
    (HERE/'hot-placement.json').write_text(json.dumps(result,indent=2)+'\n')
    for case,r in result.items():
        ranked=sorted([(sum(x['accesses'] for x in v),k,len(v)) for k,v in r['owners'].items()],reverse=True)
        print(case,ranked[:4])
