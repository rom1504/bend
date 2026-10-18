#!/usr/bin/env python3
"""Plan, then explicitly run, fresh-heldout relinking and frozen-winner timing.

plan hashes inputs and writes command arrays only. run is for the parent CPU
owner: it compiles only the harness, relinks cached workers with their own
origin runtime.o, and executes the frozen evaluation without reranking.
"""
import argparse
import importlib.util
import json
import shutil
import statistics
import subprocess
import sys
import time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('final_selection',HERE/'final-selection.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
ROOT=S.ROOT

def plan(args):
    out=S.fresh(args.out);run_dir=S.fresh(args.run_dir);prepared=args.prepared.resolve()
    selection=S.read(args.selection)
    if selection.get('kind')!='phase110-frozen-final-followup-selection' or not selection['complete'] or not selection['selectionFrozen']:
        raise ValueError('final frozen selection required')
    for row in selection['inputs']:S.verify(row)
    protocol=S.read(S.verify(selection['protocol']))
    corpus_file=HERE.parent/'final-heldout/manifest.json';corpus=S.read(corpus_file);corpus_pin=S.pin(corpus_file)
    if corpus_pin not in protocol['inputs']:raise ValueError('protocol does not bind fresh corpus')
    harness_record=S.read(prepared/'manifest.json')
    if not harness_record['complete'] or corpus_pin not in harness_record['inputs']:raise ValueError('prepared harness not bound to corpus')
    for row in harness_record['inputs']+harness_record['outputs']:S.verify(row)
    cases=corpus['timingWorkloads'];expected=S.pin(prepared/'expected.jsonl')
    oracle=[json.loads(line) for line in Path(expected['file']).read_text().splitlines()]
    if [row['name'] for row in oracle]!=cases:raise ValueError('complete ordered eleven-case oracle required')
    if selection['heldoutRepetitions']!=corpus['defaultRepetitions'] or len(cases)!=11:raise ValueError('frozen repetition/case count mismatch')
    workers=selection['workers'];names=[w['name'] for w in workers]
    if set(names)!={selection['reference'],selection['qbeWinner'],selection['globalWinner']} or len(names)!=len(set(names)):
        raise ValueError('only frozen reference and winners may be evaluated')
    cc=Path(shutil.which('gcc')).resolve()
    inputs=[S.pin(Path(__file__)),S.pin(HERE/'final-selection.py'),S.pin(args.selection),selection['protocol'],corpus_pin,
        S.pin(prepared/'manifest.json'),*harness_record['inputs'],*harness_record['outputs'],S.pin(cc),
        *[row for w in workers for row in [w['origin'],w['object'],w['runtimeObject'],w['binary']]]]
    for row in inputs:S.verify(row)
    compile_job=dict(label='harness',command=[str(cc),'-O2','-std=gnu11','-c',str(prepared/'harness.c'),'-o',str(run_dir/'harness.o')])
    links=[dict(label=w['name']+'-link',name=w['name'],command=[str(cc),'-no-pie',w['object']['file'],w['runtimeObject']['file'],str(run_dir/'harness.o'),'-pthread','-lm','-o',str(run_dir/w['name'])]) for w in workers]
    timings=[]
    for round_index in range(selection['heldoutRounds']):
        order=names if round_index%2==0 else list(reversed(names))
        for case in cases:
            for name in order:
                timings.append(dict(label=f'{round_index}-{case}-{name}',name=name,case=case,round=round_index,
                    command=[str(run_dir/name),case,str(selection['heldoutRepetitions'])]))
    result=dict(kind='phase110-final-fresh-heldout-command-plan',complete=True,targetsRun=False,preparedUtc=S.stamp(),
        selection=S.pin(args.selection),inputs=inputs,runDirectory=str(run_dir),prepared=str(prepared),expected=expected,
        workers=workers,cases=cases,rounds=selection['heldoutRounds'],repetitions=selection['heldoutRepetitions'],
        compile=compile_job,links=links,controls=[dict(label=name+'-controls',name=name,command=[str(run_dir/name)]) for name in names],timings=timings,
        commandToExecute=[sys.executable,str(Path(__file__).resolve()),'run','--plan',str(out)],
        evaluation='Equal eleven-case geometric mean of median worker clocks versus frozen fused-QBE reference; semantic success and ratio <=1.03. Report every per-case regression; do not rerank or replace winners.')
    out.parent.mkdir(parents=True,exist_ok=True);S.save(out,result)
    print(json.dumps(dict(complete=True,targetsRun=False,plan=str(out),runCommand=result['commandToExecute'])))

def run(args):
    frozen=S.read(args.plan)
    if frozen['kind']!='phase110-final-fresh-heldout-command-plan' or not frozen['complete'] or frozen['targetsRun']:raise ValueError('prepared plan required')
    for row in frozen['inputs']:S.verify(row)
    selection=S.read(S.verify(frozen['selection']));out=S.fresh(frozen['runDirectory']);out.mkdir(parents=True)
    oracle={row['name']:row for row in map(json.loads,Path(frozen['expected']['file']).read_text().splitlines())}
    report=dict(kind='phase110-final-fresh-heldout-evaluation',complete=False,evaluationOnly=True,selectionFrozen=False,
        selection=frozen['selection'],plan=S.pin(args.plan),inputs=[S.pin(args.plan),*frozen['inputs']],started=S.stamp(),
        reference=selection['reference'],qbeWinner=selection['qbeWinner'],globalWinner=selection['globalWinner'],
        cases=frozen['cases'],rounds=frozen['rounds'],repetitions=frozen['repetitions'],workers=[],jobs=[],rows=[],semantics={})
    save=lambda:S.save(out/'report.json',report);save()
    def invoke(job):
        row=dict(job);report['jobs'].append(row);save();start=time.monotonic()
        stdout=out/(job['label']+'.stdout');stderr=out/(job['label']+'.stderr')
        with stdout.open('xb') as so,stderr.open('xb') as se:
            result=subprocess.run(job['command'],cwd=ROOT,stdout=so,stderr=se,timeout=60)
        row.update(status=result.returncode,processSeconds=time.monotonic()-start,stdout=S.pin(stdout),stderr=S.pin(stderr));save()
        if result.returncode:raise ValueError(job['label']+' failed')
        return row,stdout,stderr
    try:
        invoke(frozen['compile'])
        for job in frozen['links']:
            invoke(job);worker=next(w for w in frozen['workers'] if w['name']==job['name'])
            report['workers'].append({**worker,'trainingBinary':worker['binary'],'binary':S.pin(out/worker['name'])});save()
        for job in frozen['controls']:
            row,stdout,stderr=invoke(job)
            if stdout.read_bytes()!=Path(frozen['expected']['file']).read_bytes():raise ValueError(job['name']+' whole semantic oracle differs')
            report['semantics'][job['name']]=dict(exact=True,cases=len(oracle));save()
        for job in frozen['timings']:
            row,stdout,stderr=invoke(job)
            if json.loads(stdout.read_text())!=oracle[job['case']]:raise ValueError(job['label']+' repeated semantics differ')
            timing=json.loads(stderr.read_text())
            if timing['name']!=job['case'] or timing['repetitions']!=frozen['repetitions'] or not S.math.isfinite(timing['workerSeconds']) or timing['workerSeconds']<=0:
                raise ValueError('timing identity/clock mismatch')
            report['rows'].append(dict(name=job['name'],case=job['case'],round=job['round'],workerSeconds=timing['workerSeconds'],measurement=timing,processSeconds=row['processSeconds'],stdout=row['stdout'],stderr=row['stderr']));save()
        cases=frozen['cases'];names=[w['name'] for w in frozen['workers']]
        medians={name:{case:statistics.median(row['workerSeconds'] for row in report['rows'] if row['name']==name and row['case']==case) for case in cases} for name in names}
        ratios={name:{case:medians[name][case]/medians[selection['reference']][case] for case in cases} for name in names}
        summaries={name:dict(ratio=S.gm(ratios[name].values()),caseRatios=ratios[name],
            regressions=[dict(case=case,ratio=ratios[name][case]) for case in cases if ratios[name][case]>1]) for name in names}
        report.update(medians=medians,comparisons=summaries,accepted={name:summaries[name]['ratio']<=1.03 for name in dict.fromkeys([selection['qbeWinner'],selection['globalWinner']])},
            harnessObject=S.pin(out/'harness.o'),finished=S.stamp(),complete=True,
            scope='Frozen winners only; acceptance never changes selection. Original worker clock/harness/fixture semantics retained. Runtime object selected per recorded origin, not the compare-build directory.')
        for row in report['inputs']:S.verify(row)
        save();print(json.dumps(dict(complete=True,accepted=report['accepted'],ratios={name:summaries[name]['ratio'] for name in names})))
    except BaseException as error:report.update(error=repr(error),complete=False);save();raise

def main():
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='action',required=True)
    pp=sub.add_parser('plan');pp.add_argument('--selection',type=Path,required=True);pp.add_argument('--prepared',type=Path,required=True)
    pp.add_argument('--out',type=Path,required=True);pp.add_argument('--run-dir',type=Path,required=True)
    rr=sub.add_parser('run');rr.add_argument('--plan',type=Path,required=True)
    args=p.parse_args();(plan if args.action=='plan' else run)(args)

if __name__=='__main__':main()
