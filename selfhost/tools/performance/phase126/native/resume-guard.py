"""Exact post-N1 restart admission; unchanged process/RSS/CPU/file/deadline guard."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def load(path,name):
    spec=importlib.util.spec_from_file_location(name,path)
    value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value
P=load(HERE/'plan-v2.py','p126_plan')
R=load(HERE/'resume.py','p126_resume')
S=load(ROOT/'selfhost/tools/performance/programs/support.py','p126_original_guard_support')
PLAN_SHA='ad3b78bd4402effc7960521cefe72037c3d652b0294e34fa9bcf4b719c00f966'


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan',type=Path,required=True)
    args=parser.parse_args()
    assert P.pin(args.plan)['sha256']==PLAN_SHA, 'This admission is only for the exact selected32 post-N1 resume'
    plan=P.verify_plan(args.plan);R.frozen_prefix()
    assert plan['guard']==dict(cpu=3,rssMiB=6144,availableMiB=16384,fileMiB=128,seconds=2400)
    source=P.read(Path(plan['artifacts']['hosted'])/'report.json')['product']
    built=P.read(Path(plan['artifacts']['n1'])/'report.json')
    assembly=P.pin(Path(plan['artifacts']['n1'])/'program.s')
    for row in [source,built['object'],built['binary'],assembly]:P.verify(row)
    assert source['bytes']<=128*1024**2
    machine=assembly['bytes']+built['object']['bytes']+built['binary']['bytes']+8*1024**2
    required=max(128*1024**2,machine)+96*1024**2+32*1024**2
    free=shutil.disk_usage(ROOT).free
    assert free>required, 'Need the unchanged post-N1 staged reserve before restarting'
    out=Path(plan['artifacts']['guard']);assert not out.exists()
    command=plan['rootGuardCommand'];child=command[command.index('--')+1:]
    expected=[sys.executable,'-B',str(HERE/'resume.py'),'run','--plan',str(args.plan.resolve())]
    assert [str(Path(child[0]).resolve()),*child[1:]]==[str(Path(expected[0]).resolve()),*expected[1:]]
    bounded=['bash','-c','ulimit -f 131072; ulimit -c 0; exec "$@"','phase111','taskset','-c','3',*child]
    admission=dict(complete=True,targetsRun=False,plan=P.pin(args.plan),method=P.pin(__file__),
        originalGuard=P.pin(ROOT/'selfhost/tools/performance/phase111/guard.py'),support=P.pin(S.__file__),
        completedPrefix=plan['resumeAuthority']['proofs'],hostedQbe=source,n1Assembly=assembly,
        n1Object=built['object'],n1Binary=built['binary'],freeBytes=free,requiredFreeBytes=required,
        envelope=dict(nativeStdoutCapBytes=128*1024**2,sameInputN2MachineBytes=machine,
                      remainingSuitesReserveBytes=96*1024**2,unallocatedSlackBytes=32*1024**2),
        preserved=dict(fileLimitBytes=128*1024**2,rssMiB=6144,availableMiB=16384,cpu=3,seconds=2400),
        scope='Exact post-N1 context only: the full hosted emission/N1 build are already complete and pinned. Native stdout remains capped128MiB; exact raw-QBE equality/dedup precedes N2 build with identical pinned machine inputs. Both original storage checkpoints remain. Actual N1 machine sizes plus8MiB and measured suite reserve bound this staged plan, not arbitrary future programs; mismatched reproduction stops before N2. No memory, file, CPU, deadline or process-cleanup limit is relaxed.')
    with S.ExecutionGuard(rss_mib=6144,available_mib=16384) as guard:
        result=guard.run(bounded,out,time.monotonic()+2400)
    S.save(out/'restart-admission.json',admission)
    S.save(out/'inputs.json',[P.pin(args.plan),P.pin(__file__),P.pin(S.__file__)])
    S.save(out/'method.json',dict(method=P.pin(__file__),support=P.pin(S.__file__),cpu='3',fileLimitBytes=128*1024**2,
                                diskFreeBytes=shutil.disk_usage(ROOT).free,contextSpecificAdmission=admission))
    print(json.dumps(result));sys.exit(0 if result['complete'] else 1)


if __name__=='__main__':main()
