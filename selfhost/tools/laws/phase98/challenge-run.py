#!/usr/bin/env python3
"""Run prepared finite challenges or frozen proof jobs; root-only targets."""
import argparse
from pathlib import Path
import re
import subprocess
import sys
sys.dont_write_bytecode=True
from common import ROOT,BUILD,pin,read,save,verify,run,passed

HERE=Path(__file__).resolve().parent
CHECKER=HERE/'check.py'


def validate_pins(value):
    if isinstance(value,dict):
        if {'file','bytes','sha256'}<=value.keys():
            verify({k:value[k] for k in ['file','bytes','sha256']})
        else:
            for child in value.values():validate_pins(child)
    elif isinstance(value,list):
        for child in value:validate_pins(child)


def finite(plan,out,report,write,only):
    assert plan['complete'] and plan['inputsUnchanged'] and not plan['targetsRun']
    report.update(suite=plan['suite'],excluded=plan['excluded'],scope=plan['scope'])
    for role in plan['roles']:
        if only and role['id']!='baseline' and role['id'] not in only:continue
        manifest=Path(role['manifest']['file']);data=read(manifest)
        validate_pins(data['frozenInputs']);validate_pins(data['b2'])
        folder=out/role['id']
        execution=run(out/(role['id']+'-guard'),['node','--stack-size=4096','--max-old-space-size=1024',
                      manifest.parent/'methods/run.mjs',manifest,folder,'js'],90)
        row=dict(id=role['id'],kind=role['kind'],manifest=role['manifest'],guard=execution,mapping=role.get('mapping'))
        report['rows'].append(row);write()
        result_file=folder/'report.json'
        if not result_file.exists():
            row['classification']='resource-stop-inconclusive' if execution['process'].get('stoppedFor') else 'missing-execution-report'
            write();raise AssertionError(row['classification'])
        result=read(result_file);row['report']=pin(result_file)
        failures=[r for r in result['rows'] if not r['passed']]
        mismatches=[r['id'] for r in failures if 'actual'in r and 'expected'in r and r['actual']!=r['expected']]
        if execution['process'].get('stoppedFor'):classification='resource-stop-inconclusive'
        elif result.get('compile',{}).get('status')!='ok':classification='compilation-refusal'
        elif not result.get('complete') or not result.get('inputsUnchanged'):classification='execution-incomplete'
        elif mismatches:classification='semantic-detection' if role['kind']=='bad' else 'valid-change-mismatch'
        elif failures:classification='observer-error'
        else:classification='escaped' if role['kind']=='bad' else 'valid-change-accepted'
        row.update(classification=classification,semanticMismatches=mismatches,caseFailures=[r['id'] for r in failures],cases=len(result['rows']))
        if role['id']=='baseline':
            assert passed(execution) and result['passed'] and result['complete'] and result['inputsUnchanged']
            row['classification']='baseline-accepted'
        else:
            assert execution['process'].get('returncode') in [0,1] and not execution['process'].get('stoppedFor')
        write();print(role['id'],row['classification'],flush=True)


def formal(plan,out,report,write,only):
    assert plan['schema']=='phase98-independent-formal-challenge-plan-v1'
    assert pin(CHECKER)==plan['checker']
    report.update(scope='Source-only negative law checks; explicitly requested maintained proof uses full independent kernel verification.',cases=plan['cases'])
    accepted=set()
    for job in plan['jobs']:
        if only and not any(job['name'].startswith(name+'-') for name in only):continue
        assert set(job['requires'])<=accepted
        source=job['source'];verify(source)
        command=list(job['command']);destination=Path(command[command.index('--out')+1])
        assert destination.resolve().is_relative_to(BUILD) and not destination.exists()
        expected_command=[sys.executable,'-B',str(CHECKER),'--source',source['file'],'--out',str(destination)]
        if not job['independentKernel']:expected_command.append('--source-only')
        assert command==expected_command
        process=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        (out/(job['name']+'.stdout')).write_text(process.stdout)
        (out/(job['name']+'.stderr')).write_text(process.stderr)
        result_file=destination/'report.json';result=read(result_file)
        row=dict(name=job['name'],purpose=job['purpose'],expectedExit=job['expectedExit'],
                 observedExit=process.returncode,independentKernel=job['independentKernel'],report=pin(result_file),passed=False)
        report['rows'].append(row);write()
        check=result['rows']['check'];execution=check['process']
        assert not execution.get('stoppedFor') and not execution.get('interrupted')
        expected=job['expectedExit']
        assert process.returncode in [0,1]
        if expected is not None:assert process.returncode==expected
        if process.returncode==0:
            assert result['complete'] and check['stdout']=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not check['stderr']
            assert result['inputsUnchanged']
            if job['independentKernel']:assert result['independentlyChecked'] and not result['opaqueDefinitions']
            row['classification']='independent-proof-accepted' if job['independentKernel'] else 'source-check-accepted'
        else:
            assert execution['returncode']==1 and not job['independentKernel']
            diagnostic=check['stderr']
            assert diagnostic.startswith('SOME PROOFS FAIL\nError:\n- expected :') and '- observed :' in diagnostic
            assert not any(x in diagnostic for x in ['consumed more than once','unfilled law','expected an expression','SyntaxError'])
            location=re.search(r'^Location: (.+)$',diagnostic,re.M);assert location
            assert location[1] in result['lawNames'],('Not a frozen law body',location[1])
            row.update(rejectedLaw=location[1],diagnostic=diagnostic,
                       classification='equivalent-change-proof-maintenance-required' if expected is None else 'semantic-law-rejection')
        validate_pins(result['inputs'])
        row['passed']=True;accepted.add(job['name']);write();print(job['name'],row['classification'],flush=True)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    group=parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--finite',type=Path);group.add_argument('--proof-plan',type=Path)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--only',help='Comma-separated frozen recipe IDs; finite baseline always runs.')
    args=parser.parse_args();out=args.out.resolve();assert out.is_relative_to(BUILD) and not out.exists()
    plan_path=args.finite or args.proof_plan;plan=read(plan_path);validate_pins(plan)
    only=set(args.only.split(',')) if args.only else set()
    if only:
        available={r['id'] for r in plan.get('roles',plan.get('cases',[]))}
        assert only<=available,(only,available)
    out.mkdir(parents=True)
    inputs=[pin(__file__),pin(HERE/'common.py'),pin(HERE/'challenge-derivation.json'),pin(plan_path)]
    report=dict(complete=False,inputs=inputs,rows=[],targetExecution='root only; serial guarded children',selection=sorted(only))
    def write():save(out/'report.json',report)
    write()
    try:
        (finite if args.finite else formal)(plan,out,report,write,only)
        validate_pins(plan)
        for item in inputs:verify(item)
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:report['error']=repr(error);raise
    finally:write()


if __name__=='__main__':main()
