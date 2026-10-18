#!/usr/bin/env python3
"""Finite QBE differential controls; run once inside the Phase86 resource guard.

Python is an independent evaluation oracle/driver, not a compiler dependency.
No timing from this batch is a backend performance result.
"""
import argparse
import itertools
import json
import subprocess
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
sys.setrecursionlimit(10000)
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P106 = HERE.parents[1] / 'phase106'
sys.path.insert(0, str(P106))
from campaign import expected, pin, save, read, MASK
from reference import Interpreter


def oracle(name, n, seed):
    if name == 'classify':
        def ident(c): return int(65 <= c <= 90 or 97 <= c <= 122 or 48 <= c <= 57 or c in (95,46))
        def space(c): return int(c == 32 or 9 <= c <= 13)
        return ident(n) + 2*space(n) + 4*ident(seed) + 8*space(seed)
    if name == 'shift': return ((seed << (n&31)) ^ (seed >> (n&31))) & MASK
    if name == 'qbe_u64':
        mask = (1 << 64)-1
        v = ((seed << (n&63)) ^ (seed >> (n&63))) & mask
        return int(v == 0) + 2*int(v < (1 << 63)) + 4*int(seed >> 32 == MASK) + 8*int((seed+1)&mask == 0)
    if name == 'qbe_ptr_offset': return 1 if n == MASK else 3
    if name == 'qbe_zero_alloc': return 14
    if name == 'qbe_cap512': return (seed+127)&MASK
    if name == 'qbe_cap516': return (seed+128)&MASK
    if name == 'qbe_entry_pointer': return (n+seed)&MASK
    if name == 'qbe_flow':
        if n == 0: return 11 if seed == 0 else 13
        total = 0
        for i in range(n&31):
            if i == seed: return total ^ 0x80000000
            total += i
        return total + 17
    return expected(name, n, seed)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--qbe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--adapter', type=Path)
    p.add_argument('--fused-entry', action='store_true')
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase107') and not out.exists()
    out.mkdir(parents=True)
    report = dict(complete=False, passed=False, started=time.time(), jobs=[], models=[],
                  methods=[pin(__file__),pin(HERE/'emit-controls.mjs'),pin(HERE/'controls.bend'),
                           pin(HERE/'qbe.bend'),pin(HERE/'edge-cases.json'),pin(P106/'reference.py'),
                           pin(P106/'campaign.py'),pin(P106/'cranelift/runner.c')],
                  source=pin(a.source), qbe=pin(a.qbe),
                  scope='Finite controls on prototype IR. No performance or whole-compiler proof.')
    if a.adapter:
        report['adapter'] = pin(a.adapter)
    report['fusedEntry'] = a.fused_entry
    if a.fused_entry:
        report['methods'].append(pin(HERE/'qbe-entry.bend'))
    def checkpoint(): save(out/'report.json', report)
    def run(label, command, code=0, output=None):
        argv = list(map(str, command)); start = time.monotonic()
        r = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, timeout=35)
        row = dict(label=label, command=argv, returncode=r.returncode, stdout=r.stdout,
                   stderr=r.stderr, seconds=time.monotonic()-start)
        report['jobs'].append(row)
        if r.returncode != code or (output is not None and r.stdout != output):
            checkpoint(); raise AssertionError(row)
        return r
    checkpoint()
    try:
        proposal = read(HERE/'edge-cases.json')
        cases = {}
        for name, item in {**proposal['existingWorkloads'],
                           **{k:v for k,v in proposal['additionalFixtureExpectations'].items() if k != 'all'}}.items():
            pairs = item.get('args') or itertools.product(item['n'],item['seed'])
            cases[name] = [dict(args=list(pair),expected=oracle(name,*pair)) for pair in pairs]
        # Constant-fold proof bridge expectations are independent, frozen inputs.
        laws = read(P106/'laws/cases.json')['cases']
        cases['law_bridge'] = [dict(args=[i+offset,0],expected=row['expected'])
                               for offset in [0,30] for i,row in enumerate(laws)]
        save(out/'cases.json',cases); report['cases']=pin(out/'cases.json')
        source = out/'source.bend'
        source.write_text(a.source.read_text()+'\n'+
                          ((HERE/'qbe-entry.bend').read_text()+'\n' if a.fused_entry else '')+
                          (HERE/'controls.bend').read_text())
        report['combinedSource']=pin(source)
        bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
        api = out/'api.mjs'
        run('checked-bend-api',[bun,ROOT/'selfhost/tools/stage0-library.mjs',source,api,
                               'nxq_program','nxq_control','nx_workload','nx_optimize','nx_verify',
                               'nx_json_program','nx_c_program','nx_law_bridge',
                               *(['nxq_program_fused','nxq_body_fuel'] if a.fused_entry else [])])
        report['api']=pin(api)
        run('bend-emission',[bun,HERE/'emit-controls.mjs',api,out,out/'cases.json',
                             'fused' if a.fused_entry else 'baseline'])
        report['emission']=read(out/'emission.json')
        runner=out/'runner.o'
        run('common-runner-gcc',['gcc','-std=c11','-O2','-c',P106/'cranelift/runner.c','-o',runner])
        for name, inputs in cases.items():
            for policy in ['raw','fold']:
                stem = out/(name+'-'+policy)
                program = read(str(stem)+'.json')
                for item in inputs:
                    actual=Interpreter(program).run(item['args'])
                    assert actual['value']==item['expected'],(name,policy,item,actual)
                    report['models'].append(dict(name=name,policy=policy,**item,**actual))
                targets=['qbe','gcc']+(['cl'] if a.adapter else [])
                for backend in targets:
                    label=name+'-'+policy+'-'+backend
                    obj=out/(label+'.o'); binary=out/label
                    if backend=='qbe':
                        assembly=out/(label+'.s')
                        run(label+'-compile',[a.qbe.resolve(),'-t','amd64_sysv','-o',assembly,str(stem)+'.ssa'])
                        run(label+'-assemble',['as','-o',obj,assembly])
                    elif backend=='gcc':
                        run(label+'-compile',['gcc','-std=c11','-O2','-c',str(stem)+'.c','-o',obj])
                    else:
                        run(label+'-compile',[a.adapter.resolve(),str(stem)+'.json',obj,'speed'])
                    run(label+'-link',['gcc','-no-pie',runner,obj,'-o',binary])
                    for index,item in enumerate(inputs):
                        answer=item['expected']
                        run(label+'-'+str(index),[binary,'--expect',answer,*item['args']],output=str(answer)+'\n')
                    item=inputs[-1]
                    run(label+'-wrong-expect',[binary,'--repeat',2,'--expect',item['expected']^0x80000000,*item['args']],code=1)
                checkpoint()
        for item in report['methods']+[report['source'],report['qbe'],report['api'],report['combinedSource']]:
            assert pin(item['file'])==item
        if a.adapter:
            assert pin(a.adapter)==report['adapter']
        report.update(complete=True,passed=True,inputsUnchanged=True,
                      modelCases=len(report['models']),checkedTargetCases=sum(len(x) for x in cases.values())*2*(3 if a.adapter else 2))
    finally:
        report['finished']=time.time(); checkpoint()
    print(json.dumps({k:report[k] for k in ['complete','passed','modelCases','checkedTargetCases']}))


if __name__=='__main__': main()
