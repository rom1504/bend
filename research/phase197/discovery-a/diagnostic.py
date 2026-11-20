#!/usr/bin/env python3
"""Whole-program finite checks and balanced timing of the frozen ray variants."""
import argparse
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time
from prepare import ROOT, HERE, CASE, read, pin, verify

sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, EXTRA, execute, checked_tool


def save(out,result):
    (out/'diagnostic.json').write_text(__import__('json').dumps(result,indent=2)+'\n')


def main(out, rounds, reverse):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True,exist_ok=False)
    started=time.monotonic()
    frozen=read(HERE/'frozen.json')
    model_path=ROOT/'selfhost/build/phase197/discovery-a-model01/model.json'
    model=read(model_path);assert model['complete'] and model['freeze']==pin(HERE/'frozen.json')
    original=verify(frozen['source']);direct=verify(frozen['binary']);verify(frozen['object'])
    for row in frozen['inputs']:verify(row)
    assets=read(ASSETS);policy=assets['toolchains']['x86']
    assembler,linker,runtime=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    reference=next(r for r in read(REFERENCES)['cases'] if r['id']==CASE)
    c=reference['products']['c'];point=reference['point']
    result=dict(complete=False,freeze=pin(HERE/'frozen.json'),model=pin(model_path),method=pin(__file__),
                helperMethods=[pin(ROOT/'research/phase196/screen/measure.py'),pin(ROOT/'research/phase196/screen/regions.py')],
                assets=pin(ASSETS),references=pin(REFERENCES),case=CASE,point=point,products={},oracles=[],pilots=[],samples=[],
                scope='Generated whole-program diagnostics only. Scalar FP associations preserved. AVX requires current host/OS, YMM upper lanes dead; schedule requires masked FP exceptions. Both assembler layouts retained.',
                rounds=rounds,reverse=reverse)
    # Fail closed before executing AVX variants, and record ordinary MXCSR masks.
    gate=out/'host-gate.c'
    gate.write_text('#include <cpuid.h>\n#include <stdio.h>\nint main(void){unsigned a,b,c,d,l,h,m; if(!__get_cpuid(1,&a,&b,&c,&d)||!(c&(1u<<28))||!(c&(1u<<27)))return 2; __asm__ volatile("xgetbv":"=a"(l),"=d"(h):"c"(0)); __asm__ volatile("stmxcsr %0":"=m"(m)); printf("xcr0=%x:%x mxcsr=%x\\n",h,l,m); return ((l&6)==6 && (m&0x1f80)==0x1f80)?0:3;}\n')
    gate_exe=out/'host-gate'
    subprocess.run([linker,str(gate),'-o',str(gate_exe)],check=True,capture_output=True,timeout=10)
    gate_result=subprocess.run([str(gate_exe)],capture_output=True,text=True,timeout=2)
    result['hostGate']=dict(source=pin(gate),binary=pin(gate_exe),exitCode=gate_result.returncode,stdout=gate_result.stdout,stderr=gate_result.stderr)
    save(out,result);assert gate_result.returncode==0 and not gate_result.stderr
    before=original.read_text().splitlines()
    result['products']['direct']=dict(binary=pin(direct),checks=[])
    for layout,flags in [('qualified',policy['assemblerFlags']),('default',[])]:
        for candidate in [None,*frozen['candidates']]:
            name=layout+'-'+(candidate['name'] if candidate else 'baseline')
            directory=out/name;directory.mkdir()
            lines=before.copy()
            if candidate:
                for patch in sorted(candidate['patches'],key=lambda p:-p['line']):
                    begin=patch['line']-1
                    assert [s.strip() for s in lines[begin:begin+len(patch['before'])]]==patch['before']
                    lines[begin:begin+len(patch['before'])]=['  '+s for s in patch['after']]
            source=directory/'program.s';source.write_text('\n'.join(lines)+'\n')
            assert candidate or source.read_bytes()==original.read_bytes()
            obj,exe=directory/'program.o',directory/'program'
            for argv in ([assembler,*flags,'-o',str(obj),str(source)],
                         [linker,*policy['linkerFlags'],str(obj),runtime,*policy['libraries'],'-o',str(exe)]):
                p=subprocess.run(argv,capture_output=True,text=True,timeout=10)
                assert p.returncode==0 and not p.stderr,(argv,p.stderr)
            result['products'][name]=dict(binary=pin(exe),object=pin(obj),source=pin(source),checks=[])
    for index,args in enumerate([point['runtimeArgs'],*EXTRA[CASE]]):
        repetitions=int(index==0)
        observation,expected=execute(checked_tool(c['artifact']),args,repetitions,0,point['expectedStdout'] if index==0 else None,c['runtimeArgumentConvention'])
        result['oracles'].append(dict(args=args,repetitions=repetitions,expected=expected,cBinary=c['artifact'],cObservation=observation))
        for product in result['products'].values():
            got,_=execute(product['binary']['file'],args,repetitions,0,expected)
            product['checks'].append(got)
    result['buildAndCheckSeconds']=time.monotonic()-started
    save(out,result)
    n=point['repetitions']
    for _ in range(8):
        obs,_=execute(direct,point['runtimeArgs'],n,4,point['expectedStdout'])
        result['pilots'].append(dict(repetitions=n,**obs))
        if 150<=obs['elapsedMs']<=250:break
        n=max(1,math.ceil(n*180/max(1,obs['elapsedMs'])))
    else:raise ValueError('Calibration failed')
    names=list(result['products'])
    if reverse:names.reverse()
    for round_ in range(rounds):
        order=names if round_<rounds//2 else list(reversed(names))
        offset=round_%len(order)
        for name in order[offset:]+order[:offset]:
            obs,_=execute(result['products'][name]['binary']['file'],point['runtimeArgs'],n,4,point['expectedStdout'])
            assert obs['elapsedMs']>=100
            result['samples'].append(dict(name=name,round=round_,repetitions=n,**obs))
        save(out,result)
    result['ratios']={}
    for layout in ('qualified','default'):
        baseline=[r['elapsedMs'] for r in result['samples'] if r['name']==layout+'-baseline']
        direct_times=[r['elapsedMs'] for r in result['samples'] if r['name']=='direct']
        ratios={}
        for candidate in frozen['candidates']:
            times=[r['elapsedMs'] for r in result['samples'] if r['name']==layout+'-'+candidate['name']]
            paired=[b/a for a,b in zip(baseline,times)]
            ratios[candidate['name']]=dict(medianPairedRatio=statistics.median(paired),fasterPairs=sum(v<1 for v in paired),pairs=paired)
        result['ratios'][layout]=dict(baselineOverDirect=statistics.median(a/b for a,b in zip(baseline,direct_times)),candidates=ratios)
    for product in result['products'].values():verify(product['binary'])
    result.update(complete=True,wallSeconds=time.monotonic()-started)
    save(out,result)
    print(__import__('json').dumps(result['ratios']))


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--rounds',type=int,default=8);parser.add_argument('--reverse',action='store_true')
    args=parser.parse_args();assert 8<=args.rounds<=10
    main(args.out,args.rounds,args.reverse)
