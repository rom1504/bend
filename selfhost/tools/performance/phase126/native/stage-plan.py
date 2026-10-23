"""Split an authenticated native plan at emission/build for exact early SSA dedup."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p126_plan', HERE/'plan-v2.py')
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    plan = P.verify_plan(args.plan)
    expected = ['authenticate-plan','full-hosted-integrated-emission','n1-build','n1-focused19',
                'native-self-emission-n2-build','exact-hosted-native-qbe','n2-focused19','n2-original-full45']
    assert [j['name'] for j in plan['jobs']] == expected, 'Exact original eight jobs required'
    assert not any(Path(plan['artifacts'][k]).exists() for k in ['hosted','n1','self','jobs','guard'])
    py = [str(Path(sys.executable).resolve()), '-B']
    before = out.with_name(out.stem+'-after-n1.json')
    prebuild = out.with_name(out.stem+'-before-n2.json')
    assert not before.exists() and not prebuild.exists()
    def checkpoint(stage, receipt):
        return dict(name='storage-'+stage, seconds=60,
            command=py+[str(HERE/'storage-checkpoint.py'),'--plan',str(out),'--stage',stage,'--out',str(receipt)])
    jobs = plan['jobs']; jobs[0]['command'][-1] = str(out)
    emit = dict(jobs[4]); command = list(emit['command'])
    assert command[2] == str(P.ADAPTERS/'native-emit.py')
    assert command[command.index('--runtime')+1] == plan['runtime']['file']
    build_seconds = int(command[command.index('--build-seconds')+1])
    native_seconds = int(command[command.index('--seconds')+1])
    for flag in ['--runtime','--build-seconds']:
        index = command.index(flag); del command[index:index+2]
    emit.update(name='native-self-emission-only', command=command, seconds=native_seconds+30)
    build = dict(name='n2-build', seconds=3*build_seconds+30,
        command=py+[str(P.BUILDER),'--source',str(Path(plan['artifacts']['self'])/'program.ssa'),
                    '--runtime',plan['runtime']['file'],'--out',str(Path(plan['artifacts']['self'])/'build'),
                    '--seconds',str(build_seconds)])
    comparison = dict(jobs[5]); command = list(comparison['command'])
    assert command[2] == str(P.ADAPTERS/'comparison.py')
    command[2] = str(HERE/'comparison-staged.py'); command[command.index('--plan')+1] = str(out)
    comparison['command'] = command
    plan['jobs'] = jobs[:4]+[checkpoint('after-n1',before),emit,checkpoint('before-n2',prebuild),build,comparison]+jobs[6:]
    methods = [Path(__file__),HERE/'storage-checkpoint.py',HERE/'comparison-staged.py',
               HERE/'plan-v2.py',P.ADAPTERS/'comparison.py',P.ADAPTERS/'native-emit.py']
    plan['inputs'] = P.unique(plan['inputs']+[P.pin(args.plan)]+[P.pin(p) for p in methods])
    plan['storageCheckpoints'] = dict(afterN1=str(before),beforeN2=str(prebuild))
    plan['stagedStorageAdapter'] = dict(parent=P.pin(args.plan),methods=[P.pin(p) for p in methods],
        unchangedEmitter=P.pin(P.ADAPTERS/'native-emit.py'),unchangedBuilder=P.pin(P.BUILDER),
        contract='Only transport staging changes: original emission-only mode, exact hosted/native QBE before dedup, unchanged separate N2 build, versioned final comparison binds that build. All original gates and ordinary suites remain.')
    seconds = sum(j['seconds'] for j in plan['jobs'])+60
    plan['guard']['seconds'] = seconds
    command = list(plan['rootGuardCommand'])
    command[command.index('--seconds')+1] = str(seconds)
    command[command.index('--plan')+1] = str(out)
    plan['rootGuardCommand'] = command
    plan['scope'] += ' Storage-staged version: exact early QBE comparison/dedup and disk checkpoints, no machine-build or qualification gate removed.'
    with out.open('x') as stream: json.dump(plan,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=P.pin(out),rootGuardCommand=command)))


if __name__ == '__main__': main()
