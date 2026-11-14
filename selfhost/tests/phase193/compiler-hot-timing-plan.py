#!/usr/bin/env python3
"""Freeze clean-only paired kernel timing using the maintained profiler runner."""
import argparse
import json
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
sys.path[:0]=[str(ROOT/'selfhost/tools/build'),str(ROOT/'selfhost/tools/profiler')]
from common import pin,verify,require,fresh_output,write_json
import freeze


def read(path):
    return json.loads(Path(path).read_text())


def same(a,b):
    return all(a[k]==b[k] for k in ('bytes','sha256'))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    phase=ROOT/'selfhost/build/phase193'
    fixture_path=phase/'compiler-hot-source01/manifest.json'
    fixture=read(fixture_path)
    require(fixture['complete'] and fixture['rounds']==1000,'Expected complete 1000-round fixture')
    expected=fixture['expectedStdout']
    verify(expected)
    variants=[];roles={};common=None
    for role in ['baseline','candidate']:
        machine_path=phase/('compiler-hot-'+role+'-machine01')/'report.json'
        emission_path=phase/('compiler-hot-'+role+'01')/'report.json'
        machine,emission=read(machine_path),read(emission_path)
        require(machine['complete'] and machine['outputExact'] and not machine['changedInputs'],
                'Completed independently checked native product required')
        require(emission['complete'] and emission['source']==fixture['source'],'Identical input source required')
        require(same(machine['sourceObject'],emission['object']) and
                same(machine['expectedStdout'],expected),'Emission/object/oracle bindings differ')
        execution=next(j for j in machine['jobs'] if j['label']=='execute')
        require(execution['complete'] and execution['exitCode']==0 and not execution['timedOut'],
                'Native execution gate failed')
        require(same(execution['stdout'],expected) and execution['stderr']['bytes']==0,
                'Complete stdout/empty stderr gate failed')
        require(execution['command'][0]==machine['binary']['file'],'Execution binary binding differs')
        binding=[execution['command'][1:],machine['runtime'],machine['runtimeArgumentConvention']]
        require(common is None or binding==common,'Runtime/argument policy differs')
        common=binding
        inputs=[pin(machine_path),pin(emission_path),pin(fixture_path),pin(__file__),
                *machine['inputs'],*emission['inputs'],*fixture['inputs'],
                machine['binary'],machine['runtime'],machine['object'],
                emission['object'],execution['stdout'],execution['stderr']]
        for item in inputs:
            verify(item)
        variants.append(dict(name=role,command=execution['command'],
            runtimeArgumentConvention=machine['runtimeArgumentConvention'],
            stdout=expected['file'],stderr=str(ROOT/'selfhost/tools/bench/examples/expected-empty.stderr'),
            inputs=list(dict.fromkeys(p['file'] for p in inputs))))
        roles[role]=dict(binary=machine['binary'],machine=pin(machine_path),emission=pin(emission_path),
            compilerApi=emission['api'],compilerSource=emission['compilerSource'],
            source=fixture['source'],runtime=machine['runtime'],command=execution['command'])
    scope=('Fresh-process compiler-helper KERNEL RUNTIME, 1000 rounds per invocation, '
           '20 balanced clean rounds/40 processes, exact independent digest and empty stderr. '
           'No compiler-request timing, sampling or profile attribution. Approximately 45–50ms '
           'individual durations include startup; short-run clock/scheduler and OS-cache effects '
           'limit generalization. No cache flush or warmup. Same source and runtime across roles.')
    out=fresh_output(a.out,ROOT)
    recipe=dict(cwd=str(ROOT),scope=scope,
        workloads=[dict(name='compiler-hot-kernel1000',timeoutSeconds=2,variants=variants)])
    write_json(out/'recipe.json',recipe)
    write_json(out/'manifest.json',freeze.freeze(recipe,out/'recipe.json'))
    write_json(out/'roles.json',dict(complete=True,targetsRun=False,roles=roles,scope=scope))
    write_json(out/'plan.json',dict(complete=True,targetsRun=False,manifest=pin(out/'manifest.json'),
        roles=pin(out/'roles.json'),mode='clean',rounds=20,processes=40,
        estimatedChildSeconds=2,guardSeconds=20,diskMiB=16,scope=scope))
    print(out/'manifest.json')


if __name__=='__main__':
    main()
