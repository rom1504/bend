#!/usr/bin/env python3
"""Prepare the existing counter runner's six-object contract for this screen."""
import argparse
from datetime import datetime, timezone
import importlib.util
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('phase113_adapter',HERE/'run.py')
adapter=importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
m=adapter.method


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binding',type=Path,default=HERE/'baseline-binding01.json')
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    if a.out.exists():
        raise ValueError('Fresh counter-plan path required')
    manifest=m.read(HERE/'manifest01.json')
    binding=m.read(a.binding)
    if not binding.get('complete') or not binding.get('fullFrozenQualified') or binding['manifest']!=m.pin(HERE/'manifest01.json'):
        raise ValueError('Complete exact current six binding required')
    cases=[]
    inputs=[m.pin(__file__),m.pin(a.binding),m.pin(HERE/'manifest01.json'),manifest['directToolchain']['linker']]
    for case in manifest['cases']:
        product=binding['products'][case['name']]
        built=m.read(m.verify(product['build']))
        if not built.get('complete') or built['object']['file']!=product['buildCommands'][1][2]:
            raise ValueError('Complete bound object required')
        row=dict(name=case['name'],object=built['object'],qbe=product['qbe'],build=product['build'],
            emission=product['emission'],source=case['source'],oracle=case['expectedStdoutEvidence'],
            runtimeArgs=case['runtimeArgs'],repetitions=1,warmups=0,
            expected=dict(kind='phase112-diagnostic-batch-output',status=0,
                stdoutPrefix=case['expectedStdout']+'0\n1\n',stderr='',suffixRule='unsigned-decimal-milliseconds-newline'))
        cases.append(row)
        inputs += [row[k] for k in ['object','qbe','build','emission','source','oracle']]
    for item in inputs:
        m.verify(item)
    m.save(a.out,dict(kind='phase112-frozen-diagnostic-batch',version=1,targetsRun=False,
        createdUTC=datetime.now(timezone.utc).isoformat(),role=binding['label'],binding=m.pin(a.binding),
        benchmarkManifest=m.pin(HERE/'manifest01.json'),compiler=manifest['directToolchain']['linker'],
        cases=cases,inputs=inputs,
        scope='Phase113 current-six counter-only plan for unchanged Phase112 profile runner. Whole-process counts include initial output plus one repeated workload, setup and readback. Instrumented clocks are not performance samples.'))
    print(str(a.out))


if __name__=='__main__':
    main()
