"""Resume only the frozen native32 storage refusal; preserve completed evidence."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p126_native_plan',HERE/'plan-v2.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
ORIGINAL=ROOT/'selfhost/build/phase126/native32-staged-plan01.json'
ORIGINAL_SHA='a84f90bdc2504e38bee4aad3575a99c859e66ccd67ad657a08e2d6543bbaff61'


def frozen_prefix():
    assert P.pin(ORIGINAL)['sha256']==ORIGINAL_SHA
    original=P.verify_plan(ORIGINAL)
    report_path=Path(original['artifacts']['jobs'])/'report.json'
    report=P.read(report_path)
    assert not report['complete'] and len(report['jobs'])==5
    assert P.pin(ORIGINAL) in report['inputs']
    for actual,expected in zip(report['jobs'],original['jobs']):
        assert actual['name']==expected['name'] and actual['command']==expected['command']
        P.verify(actual['stdout']);P.verify(actual['stderr'])
    assert all(x['status']==0 for x in report['jobs'][:4])
    assert report['jobs'][4]['name']=='storage-after-n1' and report['jobs'][4]['status']==1
    failure=Path(original['storageCheckpoints']['afterN1']);refusal=P.read(failure)
    assert not refusal['complete'] and refusal['stage']=='after-n1'
    assert refusal['requiredFreeBytes']==268435456 and refusal['freeAfter']==262365184
    assert refusal['error'].startswith('Insufficient reserve: stop before next target')
    assert not Path(original['artifacts']['self']).exists(), 'Self-emission already started'
    proofs=[P.pin(ORIGINAL),P.pin(report_path),P.pin(failure),*report['inputs'],*refusal['inputs']]
    for row in report['jobs']:proofs.extend([row['stdout'],row['stderr']])
    for key in ['hosted','n1','n1Focused']:
        receipt_path=Path(original['artifacts'][key])/'report.json';receipt=P.read(receipt_path)
        assert receipt['complete'];proofs.extend([P.pin(receipt_path),*receipt['inputs']])
        if key=='n1Focused':assert receipt['passed'] and receipt['summary']['semanticPasses']==16 and receipt['summary']['expectedRefusals']==3
    guard=Path(original['artifacts']['guard'])
    for name in ['process.json','method.json','inputs.json','stdout.log','stderr.log']:
        proofs.append(P.pin(guard/name))
    return original,report,P.unique(proofs)


def prepare(args):
    out=args.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    original,finished,proofs=frozen_prefix();plan=copy.deepcopy(original)
    # Existing successful output paths stay fixed. Only pending checkpoint and
    # orchestration paths change; no successful stage will execute again.
    tag='p126-native32-resume01'
    plan['artifacts']['jobs']=str(ROOT/'selfhost/build/phase113'/(tag+'-qualification'))
    plan['artifacts']['guard']=str(ROOT/'selfhost/build/phase126'/(tag+'-guard'))
    execution=out.with_name(out.stem+'-execution.json')
    execution_out=ROOT/'selfhost/build/phase113'/(tag+'-execution')
    for path in [execution,execution_out,Path(plan['artifacts']['jobs']),Path(plan['artifacts']['guard'])]:assert not path.exists()
    old_checks=plan['storageCheckpoints']
    plan['storageCheckpoints']=dict(afterN1=str(out.with_name(out.stem+'-after-n1.json')),
        beforeN2=str(out.with_name(out.stem+'-before-n2.json')),
        completedBuildDedup=str(out.with_name(out.stem+'-build-dedup.json')))
    for job in plan['jobs'][4:]:
        command=job['command']
        for i,value in enumerate(command):
            if value==str(ORIGINAL):command[i]=str(out)
            for key,old in old_checks.items():
                if value==old:command[i]=plan['storageCheckpoints'][key]
    plan['resumeAuthority']=dict(originalPlan=P.pin(ORIGINAL),completedPrefix=finished['jobs'][:4],
        refusedAttempt=finished['jobs'][4],proofs=proofs,executionPlan=str(execution),executionOut=str(execution_out),
        scope='Reuse only actual completed hosted/N1/focused19 stages. Preserve failed storage attempt separately; rerun unchanged storage gate with fresh receipt before any remaining target.')
    plan['inputs']=P.unique([*plan['inputs'],*proofs,P.pin(__file__)])
    for row in plan['inputs']:P.verify(row)
    remaining=dict(kind='phase126-native-resume-execution',complete=True,targetsRun=False,
                   jobs=plan['jobs'][4:],inputs=[P.pin(__file__),*proofs])
    with execution.open('x') as stream:json.dump(remaining,stream,indent=2);stream.write('\n')
    plan['inputs'].append(P.pin(execution))
    seconds=sum(j['seconds'] for j in remaining['jobs'])+60
    command=list(original['rootGuardCommand']);command[command.index('--out')+1]=plan['artifacts']['guard']
    command[command.index('--seconds')+1]=str(seconds)
    separator=command.index('--')
    command=command[:separator+1]+[sys.executable,'-B',str(Path(__file__).resolve()),'run','--plan',str(out)]
    plan['rootGuardCommand']=command;plan['guard']['seconds']=seconds
    plan['scope']+=' Exact resume of preserved storage refusal; complete prefix reused with explicit receipt provenance.'
    with out.open('x') as stream:json.dump(plan,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=P.pin(out),rootGuardCommand=command)))


def run(args):
    plan=P.verify_plan(args.plan);authority=plan['resumeAuthority']
    for row in authority['proofs']:P.verify(row)
    old=P.read(authority['originalPlan']['file']);old_report=P.read(Path(old['artifacts']['jobs'])/'report.json')
    assert old_report['jobs'][:4]==authority['completedPrefix'] and old_report['jobs'][4]==authority['refusedAttempt']
    assert plan['jobs'][:4]==old['jobs'][:4]
    remaining=P.read(authority['executionPlan']);assert remaining['jobs']==plan['jobs'][4:]
    output=Path(plan['artifacts']['jobs']);assert not output.exists()
    runner=ROOT/'selfhost/tools/performance/phase113/run-jobs.py'
    command=[sys.executable,'-B',str(runner),'--plan',authority['executionPlan'],'--out',authority['executionOut']]
    child=subprocess.run(command,cwd=ROOT)
    execution_path=Path(authority['executionOut'])/'report.json';execution=P.read(execution_path)
    assert len(execution['jobs'])<=8
    for actual,expected in zip(execution['jobs'],plan['jobs'][4:]):
        assert actual['name']==expected['name'] and actual['command']==expected['command']
        P.verify(actual['stdout']);P.verify(actual['stderr'])
    complete=child.returncode==0 and execution['complete'] and len(execution['jobs'])==8 and all(x['status']==0 for x in execution['jobs'])
    result=dict(kind='phase113-serial-jobs',complete=complete,
        inputs=P.unique([P.pin(args.plan),P.pin(__file__),P.pin(runner),P.pin(execution_path),*authority['proofs']]),
        jobs=[*authority['completedPrefix'],*execution['jobs']],
        resume=dict(original=authority['originalPlan'],failedCheckpointPreserved=authority['refusedAttempt'],
                    freshExecution=P.pin(execution_path),completedPrefixReused=4),
        scope='Authenticated aggregate of four actual completed original jobs and eight fresh remaining jobs; no fabricated re-execution or discarded failure.')
    output.mkdir(parents=True)
    (output/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    if not complete:raise RuntimeError('Resumed qualification failed; original and fresh receipts preserved')
    assert [x['name'] for x in result['jobs']]==[x['name'] for x in plan['jobs']]
    print(json.dumps(dict(complete=True,report=P.pin(output/'report.json'))))


def main():
    parser=argparse.ArgumentParser(description=__doc__);modes=parser.add_subparsers(dest='mode',required=True)
    p=modes.add_parser('prepare');p.add_argument('--out',type=Path,required=True)
    p=modes.add_parser('run');p.add_argument('--plan',type=Path,required=True)
    args=parser.parse_args();prepare(args) if args.mode=='prepare' else run(args)


if __name__=='__main__':main()
