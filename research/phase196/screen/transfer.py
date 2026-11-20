"""Check the two discoveries on qualified Phase195 inputs and two assembler layouts."""
import argparse
import math
from pathlib import Path
import statistics
import subprocess
import time

from regions import BUILD, ROOT, digest, read
from measure import ASSETS, EXTRA, FROZEN, REFERENCES, checked_tool, execute, save


def minimum_variant(lines,symbol):
    start=lines.index(symbol+':')
    end=lines.index('.size '+symbol+', .-'+symbol)
    prefix='.L'+symbol
    begin=lines.index(prefix+'_b2:',start,end)+1
    stop=lines.index('  jmp '+prefix+'_loop',begin,end)
    block=[x.strip() for x in lines[begin:stop]]
    assert len(block)==64
    template=['movq %r8, %r10','movq %rsi, %r11','cmpq %r11, %r10',
              'movq %r8, %rax','movq %rsi, %r11','cmovbq %rax, %r11']
    assert block[31:36]==['movq %r8, %rsi','addl $1, %esi','movq %rsi, %r8','movq %r14, %rsi','addl $1, %esi']
    assert block[36:43]==template+['movq %r11, %r8'] and block[46:52]==template
    # The removed r10/rax results are dead through the tail edge. Preserve
    # all frame stores and reads, live flags at the comparisons and U32 wrap.
    assert block[43:46]==['movq -2680(%rbp), %r11','movq -2712(%rbp), %rsi','addl %r11d, %esi']
    assert block[52:]==['movq %r11, -2840(%rbp)','movl %edi, %edi','movq %rdi, %rsi',
                        'addl $1, %esi','movq %rsi, %rdi','andq %r13, %rdi','movq -2840(%rbp), %rax',
                        'movl %eax, 0(%rdx,%rdi,4)','movq -2600(%rbp), %r10','movq %r10, %rsi',
                        'movq -2616(%rbp), %r10','movq %r10, %rdi']
    block[46:52]=['cmpq %rsi, %r8','movq %rsi, %r11','cmovbq %r8, %r11']
    block[31:43]=['leal 1(%r8), %r8d','leal 1(%r14), %esi','cmpq %rsi, %r8','cmovaeq %rsi, %r8']
    return lines[:begin]+['  '+v for v in block]+lines[stop:]


def main(out):
    out.mkdir(parents=True,exist_ok=False)
    assets=read(ASSETS)
    as_,cc,rt=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    policy=assets['toolchains']['x86']
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    native={r['id']:r for r in read(BUILD/'phase195/native45-01/report.json')['rows']}
    first={r['name']:r for r in read(FROZEN)['candidates']}
    result=dict(complete=False,method=digest(__file__),cases={})
    for case in ('editdist','local-pair','coverage-bst-64'):
        basket='prepared-combined01/combined' if case!='coverage-bst-64' else 'ctor-gate-emit01/off'
        folder=BUILD/'phase195'/basket
        emitted=next(r for r in read(folder/'report.json')['rows'] if r['id']==case)
        assert emitted['product']['sha256']==native[case]['object']['sha256']
        src=Path(checked_tool(emitted['assembly']))
        old=src.read_text().splitlines()
        if case=='coverage-bst-64':
            r=first['bst-decrement']; i=r['line']-1
            assert [x.strip() for x in old[i:i+len(r['before'])]]==r['before']
            new=old[:i]+['  '+x for x in r['after']]+old[i+len(r['before']):]
        else:
            new=minimum_variant(old,first['edit-minima']['rawSymbol'])
        products={'direct':checked_tool(native[case]['artifact'])}
        row=dict(source=emitted['assembly'],object=native[case]['object'],oracles=[],pilots=[],samples=[],products={})
        result['cases'][case]=row
        for layout,flags in [('qualified',policy['assemblerFlags']),('default',[])]:
            for role,lines in [('baseline',old),('candidate',new)]:
                key=layout+'-'+role
                d=out/case/key; d.mkdir(parents=True)
                asm=d/'program.s'; asm.write_text('\n'.join(lines)+'\n')
                assert role!='baseline' or digest(asm)==digest(src)
                for cmd in ([as_,*flags,'-o',d/'program.o',asm],[cc,*policy['linkerFlags'],d/'program.o',rt,*policy['libraries'],'-o',d/'program']):
                    proc=subprocess.run(cmd,capture_output=True,timeout=15)
                    assert proc.returncode==0 and not proc.stderr,proc.stderr
                products[key]=str(d/'program')
        row['products']={k:dict(file=v,sha256=digest(v)) for k,v in products.items()}
        ref=refs[case];point=ref['point']; c=ref['products']['c']
        for i,inputs in enumerate([point['runtimeArgs'],*EXTRA.get(case,[(0,17),(1,3),(3,123)])]):
            reps=int(i==0)
            obs,expected=execute(checked_tool(c['artifact']),inputs,reps,0,point['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            row['oracles'].append(dict(args=inputs,cOutput=obs,observations={k:execute(v,inputs,reps,0,expected)[0] for k,v in products.items()}))
        count=point['repetitions']
        for _ in range(10):
            v,_=execute(products['direct'],point['runtimeArgs'],count,4,point['expectedStdout'])
            row['pilots'].append(v)
            if 250<=v['elapsedMs']<=550: break
            count=max(1,math.ceil(count*330/max(1,v['elapsedMs'])))
        else:raise ValueError('Transfer calibration failed')
        names=list(products)
        for ri in range(10):
            order=names if ri<5 else list(reversed(names))
            offset=ri%5
            for role in order[offset:]+order[:offset]:
                obs,_=execute(products[role],point['runtimeArgs'],count,4,point['expectedStdout'])
                assert obs['elapsedMs']>=100
                row['samples'].append(dict(role=role,round=ri,count=count,**obs))
            save(out/'transfer.json',result)
        row['ratios']={}
        for layout in ('qualified','default'):
            def samples(role):
                return [r['elapsedMs'] for r in row['samples'] if r['role']==role]
            a=samples(layout+'-baseline'); b=samples(layout+'-candidate'); direct=samples('direct')
            ratios=[y/x for x,y in zip(a,b)]
            row['ratios'][layout]=dict(candidateOverBaseline=statistics.median(ratios),fasterPairs=sum(v<1 for v in ratios),
                baselineOverDirect=statistics.median(x/y for x,y in zip(a,direct)),pairs=ratios)
    result['complete']=True
    save(out/'transfer.json',result)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out)
