#!/usr/bin/env python3
"""Authenticate actual object disassembly and the BST copy/decrement activation; no target runs."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import common as C
SYMBOL = 'p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_'
PAIR = ['mov %rdi,%r10','sub $0x1,%r10']
LEA = 'lea -0x1(%rdi),%r10'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,required=True)
    p.add_argument('--emission-root',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    C.require(not a.out.exists(),'Fresh offline witness output required')
    a.out.mkdir(parents=True)
    C.write_json(a.out/'report.json',dict(kind='phase197-actual-object-decrement-activation',complete=False,targetsRun=False))
    inputs={}
    def verify(pin):
        old=inputs.get(pin['file']);C.require(old is None or old==pin,'Conflicting pin')
        C.verify(pin);inputs[pin['file']]=pin;return Path(pin['file'])
    def read(pin):return json.loads(verify(pin).read_text())
    method=C.pin(__file__);verify(method);verify(C.pin(C.__file__))
    plan_pin=C.pin(a.plan);plan=read(plan_pin)
    C.require(plan.get('complete') is True,'Complete frozen measurement plan required')
    baseline_manifest=read(plan['baselineProducts'])
    baseline={r['id']:r for r in baseline_manifest['cases']}
    tool=C.pin('/usr/bin/objdump');verify(tool)
    reports={role:read(C.pin(a.emission_root/role/'report.json')) for role in ('decrement','combined')}
    emitted={}
    for role,report in reports.items():
        C.require(report.get('complete') is True and not report.get('error'),'Complete emission required: '+role)
        emitted[role]={r['id']:r for r in report['rows']}
        C.require(set(emitted[role])==set(plan['cases']) and len(report['rows'])==len(plan['cases']),
                  'Exact six-case emission required')
    jobs=[]
    def disassemble(item,name,symbol=None):
        obj=verify(item);cmd=[tool['file'],'-d','--no-show-raw-insn','--wide']
        if symbol:cmd.append('--disassemble='+symbol)
        cmd.append(str(obj))
        child=subprocess.run(cmd,capture_output=True,check=False,timeout=20)
        C.require(child.returncode==0 and child.stderr==b'','Static objdump failed')
        path=a.out/(name+'.disassembly');path.write_bytes(child.stdout)
        jobs.append(dict(command=cmd,exitCode=child.returncode,stdout=C.pin(path)))
        lines=[]
        for line in child.stdout.decode().splitlines():
            found=re.match(r'^\s*([0-9a-f]+):\s+(.+?)\s*$',line)
            if found:lines.append(dict(offset='0x'+found[1],instruction=' '.join(found[2].split())))
        C.require(lines,'Nonempty actual machine instructions required')
        return lines
    def counts(lines):
        ops=[r['instruction'] for r in lines]
        return dict(instructions=len(ops),mov=sum(x.startswith('mov ') for x in ops),
                    add=sum(x.startswith('add ') for x in ops),sub=sum(x.startswith('sub ') for x in ops),
                    lea=sum(x.startswith('lea ') for x in ops),
                    decrementLea=sum(bool(re.match(r'lea -0x1\(%r\w+\),%r\w+$',x)) for x in ops))
    rows=[]
    for case in plan['cases']:
        base=baseline[case];products={'baseline':base['products']['candidate']['generatedSource']}
        for role in reports:
            row=emitted[role][case]
            C.require(row.get('complete') is True and row.get('verified') is True
                      and row.get('sameTypedSequence') is True
                      and row['source']==base['source'] and row['expectedFile']==base['expectedFile'],
                      'Candidate object source/oracle/emission binding differs')
            products[role]=row['product'];verify(row['assembly'])
        record=dict(id=case,source=base['source'],expectedFile=base['expectedFile'],
                    objects=products,counts={},bstWitnesses={})
        verify(base['source']);verify(base['expectedFile'])
        for role,item in products.items():
            record['counts'][role]=counts(disassemble(item,case+'-'+role))
        if case in ('coverage-bst-32','coverage-bst-64'):
            old=disassemble(products['baseline'],case+'-baseline-worker',SYMBOL)
            indices=[i for i in range(len(old)-1) if [x['instruction'] for x in old[i:i+2]]==PAIR]
            C.require(len(indices)==1,'Exactly one original BST copy/decrement witness required')
            i=indices[0];tail=[r['instruction'] for r in old[i+2:i+8]]
            for role in reports:
                new=disassemble(products[role],case+'-'+role+'-worker',SYMBOL)
                candidates=[j for j,r in enumerate(new) if r['instruction']==LEA
                            and [x['instruction'] for x in new[j+1:j+7]]==tail]
                C.require(len(candidates)==1 and not any([x['instruction'] for x in new[j:j+2]]==PAIR
                          for j in range(len(new)-1)),'Actual BST pair not uniquely replaced with tail retained')
                j=candidates[0]
                record['bstWitnesses'][role]=dict(symbol=SYMBOL,before=old[i:i+8],after=new[j:j+7],
                    copyRemoved=True,subRemoved=True,modularDecrementLea=True,followingSixInstructionsIdentical=True)
        rows.append(record)
    changed=C.changed_inputs(list(inputs.values()));C.require(not changed,'Witness inputs changed')
    result=dict(kind='phase197-actual-object-decrement-activation',complete=True,targetsRun=False,
                method=method,measurementPlan=plan_pin,disassembler=tool,rows=rows,jobs=jobs,
                inputs=list(inputs.values()),changedInputs=changed,
                scope='Static disassembly of pinned actual ELF objects, all six frozen cases. Both BST workloads '
                'must remove the original copy/sub and retain the next six instructions in decrement and combined roles. '
                'Typed assembly is corroborative provenance only. Counts are static whole-object counts, not dynamic '
                'hot-path counts or runtime measurements; no correctness/throughput claim follows from activation alone.')
    C.write_json(a.out/'report.json',result)
    print(json.dumps(dict(complete=True,cases=len(rows),bstWitnesses=sum(len(r['bstWitnesses']) for r in rows),report=str(a.out/'report.json'))))


if __name__=='__main__':main()
