"""Freeze current object-backed straight-line proposals without running a target."""
from pathlib import Path
import sys
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SCREEN = ROOT/'research/phase196/screen'
sys.path.insert(0, str(SCREEN))
from regions import BUILD, digest, pretty, regions, read


def save(path, data):
    path.write_text(json.dumps(data, indent=2)+'\n')


def tag(seq):
    start = seq.index('movq %rsi, %rdi')
    literal = seq[start+3].split()[1].strip('$,')
    assert seq[start:] == ['movq %rsi, %rdi', 'shrq $40, %rdi', 'andq $65535, %rdi',
                          f'movabsq ${literal}, %r11', 'cmpq %r11, %rdi']
    return seq[:start+2]+[f'cmpw ${literal}, %di']


def stores(seq):
    start = seq.index('leaq -2392(%rbp), %r10')
    out = seq[:start]
    i = start
    while seq[i] == 'leaq -2392(%rbp), %r10':
        op, value = seq[i+1].split()[:2]
        value = value.rstrip(',')
        assert op in ['movabsq','movq'] and seq[i+1].endswith(', %r11')
        offset = int(seq[i+2].split()[2].split('(')[0])
        assert seq[i+2] == f'movq %r11, {offset}(%r10)'
        out.append(f'movq {value}, {offset-2392}(%rbp)')
        i += 3
    assert seq[i:][-2:] == ['leaq -2392(%rbp), %rdx', 'xorl %eax, %eax']
    assert all('%r10' not in v and '%r11' not in v for v in seq[i:])
    return out+seq[i:]


def header(seq):
    assert seq[:4] == ['movabsq $164, %rdi','shlq $40, %rdi',
                      'movabsq $72057594037927936, %r11','orq %r11, %rdi']
    return [f'movabsq ${(164 << 40) | (1 << 56)}, %rdi',seq[4]]


def predicate(seq):
    assert seq[-4:] == ['orl %r9d, %edi','xorl $1, %edi','movq %rdi, %r10','testl %r10d, %r10d']
    return ['movl $1, %edi', 'movq %rdi, %r10', 'testl %r10d, %r10d']


BST='coverage-bst-64'
TREE='tree-bitonic'
RULES=[
    ('tag-width',BST,[4012,4024],tag,'The only branch consumer is JNE. Equality on low 16 bits after shifting agrees for any packed word. The unmasked upper register bits and r11 die on both successors before first use; neither register is a live argument to the take call.'),
    ('complement-edge',BST,[4262],predicate,'The immediately dominating JZ arrived with the same OR predicate zero; both inputs are unchanged and this label has only that predecessor. Recomputed r9 and r8 equal incoming values. Restore rdi and r10 to one and recreate the terminal TEST flags.'),
    ('direct-ctor-stores',BST,[4056,4071,4088,4103],stores,'Each field write uses the same width, address and order in the allocated local array. All literals fit sign-extended imm32. R10 and r11 are unused until overwritten or the SysV call; they are neither helper arguments nor preserved registers.'),
    ('packed-header',TREE,[3759,3781,3817,3839],header,'Constant tag and arity bits combine exactly modulo 2^64. Preserve the last payload OR and its flags. r11 is overwritten before any use along every outgoing path.'),
]


def freeze():
    native={r['id']:r for r in read(BUILD/'phase195/native45-01/report.json')['rows']}
    result=dict(profiles={},candidates=[],policy='Run all four alternatives. Rank by sum of disjoint block sample share times fractional 100-iteration cycle decrease. Each case uses two layouts, two separately seeded balanced role orders, eight paired observations per layout. Diagnostic advancement requires median <=0.98 and >=3/4 favorable pairs in each of four layout/session cells.')
    for name,case,starts,transform,legality in RULES:
        src,elf,captures,blocks=regions(case)
        emitted=next(r for r in read(src.parents[1]/'report.json')['rows'] if r['id']==case)
        assert emitted['product']['sha256']==native[case]['object']['sha256']==digest(elf.with_suffix('.o'))
        assert digest(elf)==native[case]['artifact']['sha256']
        result['profiles'][case]=dict(source=str(src.relative_to(ROOT)),sha=digest(src),elf=native[case]['artifact'],object=native[case]['object'],captures=[dict(path=str(p.relative_to(ROOT)),sha=digest(p)) for p in captures])
        lookup={b[0][0]+1:(s,b) for s,b in blocks}
        sites=[]
        lines=src.read_text().splitlines()
        if transform is predicate:
            predecessor=[v[1] for v in lookup[4220][1]][7:]
            body=[v[1] for v in lookup[4262][1]]
            assert predecessor==body[:13]+body[14:]
            label=lines[4260].strip().rstrip(':')
            assert lines[4241].strip()=='jz '+label and sum(s.strip().endswith(' '+label) for s in lines)==1
            assert lines[4259].strip().startswith('jmp ')
        for start in starts:
            sym,block=lookup[start]
            before=[v[1] for v in block]
            after=transform(before)
            sites.append(dict(line=start,symbol=pretty(sym),address=hex(block[0][2]),weight=sum(v[3] for v in block),before=before,after=after))
        result['candidates'].append(dict(name=name,case=case,legality=legality,sites=sites))
    result['freezeMethod']=digest(__file__)
    save(HERE/'frozen.json',result)


if __name__=='__main__':
    freeze()
