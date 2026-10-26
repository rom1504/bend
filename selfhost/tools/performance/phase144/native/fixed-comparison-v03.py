"""Join two actual frozen142 cold requests and their machine builds; data only."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('workflow', HERE/'workflow-v04.py')
W = importlib.util.module_from_spec(spec); spec.loader.exec_module(W)
ROOT, Q, V = W.ROOT, W.Q, W.V
pin, read, require = W.pin, W.read, W.require


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase144'), 'Fresh output required')
    plan_path = ROOT/'selfhost/build/phase144/final04-plan/plan.json'
    plan = read(plan_path)
    require(plan['complete'] and plan['kind']=='phase144-native-qualification-plan', 'Final03 plan required')
    W.retain(pin(__file__)); W.retain(pin(W.__file__))
    parent_path = ROOT/'implementation/phase143/qualification.json'
    require(pin(parent_path)['sha256']=='ac3bcab3c016679df1c2ffdcb7da1a48f9afa996c119cd2b8957db5c788b7c89', 'Frozen timing baseline authority differs')
    parent = read(parent_path)
    require(parent['complete'] and parent['nativeQualified'] and parent['n2']==pin(ROOT/'selfhost/build/phase111/p143-integrated-n2/program'), 'Qualified parent differs')
    parent_build_path = Path(parent['n2']['file']).with_name('report.json')
    parent_build = read(parent_build_path)
    old_runtime = pin(ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o')
    require(old_runtime['sha256']=='9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749', 'Original runtime differs')
    parent_ir = pin(parent_build['jobs'][0]['command'][-1])
    require(V.exact(parent_ir,parent['qbe']), 'Qualified parent reproduction differs')
    require(Q.build(parent_build, parent_ir, old_runtime, plan['machineTools'])==parent['n2'], 'Parent actual link differs')
    n1_path = Path(plan['paths']['n1'])/'report.json'
    n2_path = Path(plan['paths']['n2'])/'report.json'
    n1 = W.pipe(n1_path,plan['producer'],plan['sourceAdmission']['source'],plan['runtime'],plan)
    n2 = W.pipe(n2_path,n1['binary'],plan['sourceAdmission']['source'],plan['runtime'],plan)
    source = pin(ROOT/'selfhost/build/phase142/indexed-source02/compiler.bend')
    require(source['sha256']=='15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1', 'Frozen workload differs')
    method = pin(ROOT/'selfhost/tools/performance/phase130/native-request.py')
    require(method['sha256']=='e32e5e99502a9b6485e54ce6669200ee48eaba0c289d7bfb2809a1dc6ef0bf2f', 'Request method differs')
    rows = {}
    for role, stem, image, runtime, authority in [
        ('parent','parent',parent['n2'],old_runtime,parent_build_path),
        ('final','final04',n2['binary'],plan['runtime'],n2_path)]:
        rp = ROOT/f'selfhost/build/phase130/p144-{stem}-fixed-cold01/report.json'
        bp = ROOT/f'selfhost/build/phase111/p144-{stem}-fixed-build01/report.json'
        request, build = read(rp), read(bp)
        require(request['kind']=='phase130-native-source-qbe-request' and request['complete'] and request['exitCode']==0
            and not request['changedInputs'] and request['stderr']['bytes']==0, 'Cold request failed')
        require(request['image']==image and request['source']==source and request['mode']=='cache'
            and request['base']==plan['base'] and request['carrier']==plan['carrier'] and request['stamp']==plan['stamp'], 'Request inputs differ')
        require(request['command']==V.command(image,source,plan['base'],plan['carrier'],plan['stamp'])
            and request['inheritedAffinity']==[3] and method in request['inputs'], 'Request protocol differs')
        require(Q.build(build,request['product'],runtime,plan['machineTools'])==build['binary'], 'Machine build differs')
        require(len(build['jobs'])==3 and build['buildSeconds']==sum(j['seconds'] for j in build['jobs']), 'Machine clock differs')
        guards = {}; supervised = {}; peak_rss = {}
        for stage, report_path, tool in [('cold',rp,method),('build',bp,pin(Q.BUILDER))]:
            gp = ROOT/f'selfhost/build/phase144/{stem}-fixed-{stage}01-guard/process.json'
            guard = read(gp); command = guard['command']
            require(guard['complete'] and guard['returncode']==0 and not guard.get('stoppedFor'), 'Guard failed')
            require(command[4:7]==['taskset','-c','3'] and command[8]=='-B'
                and pin(ROOT/command[9])==tool, 'Guard target/affinity differs')
            require(len(command)>=10 and (len(command)-10)%2==0, 'Guard flag pairs differ')
            flags = dict(zip(command[10::2],command[11::2]))
            require((ROOT/flags['--out']).resolve()==report_path.parent, 'Guard output differs')
            guards[stage] = pin(gp)
            supervised[stage] = guard['wallSeconds']; peak_rss[stage] = guard['peakTreeRssBytes']
        rows[role] = dict(request=pin(rp),machineBuild=pin(bp),image=image,actualLinkedRuntime=runtime,
            actualRuntimeAuthority=pin(authority),product=request['product'],object=build['object'],binary=build['binary'],
            guards=guards,supervisedSeconds=supervised,supervisedStageSumSeconds=sum(supervised.values()),
            guardPeakTreeRssBytes=peak_rss,requestWrapperSeconds=request['totalSeconds'],
            requestSeconds=request['nativeSeconds'],machineSeconds=build['buildSeconds'],
            requestPlusMachineSeconds=request['nativeSeconds']+build['buildSeconds'],
            stages={j['label']:j['seconds'] for j in build['jobs']})
    metrics = {}
    for key in ['requestSeconds','machineSeconds','requestPlusMachineSeconds','supervisedStageSumSeconds']:
        ratio = rows['final'][key]/rows['parent'][key]
        metrics[key] = dict(parent=rows['parent'][key],final=rows['final'][key],finalOverParent=ratio,percentLower=100*(1-ratio))
    result = dict(kind='phase144-frozen142-native-comparison',complete=True,targetsRun=False,
        source=source,plan=pin(plan_path),rows=rows,metrics=metrics,
        exactQbe=V.exact(rows['parent']['product'],rows['final']['product']),
        exactObject=V.exact(rows['parent']['object'],rows['final']['object']),
        inputs=list(V.INPUTS.values()),
        scope='One cold compiler request per role on exactly the same frozen142 input, acquired in different time windows; no rotated repetitions or statistical speedup claim. Machine construction is a separate fresh aligned build per role. Request-plus-machine and supervised stage totals are sums of separate observations, not a single timed pipeline. Different ordinary optimization policies may change QBE/objects. Runtime authority is each compiler link receipt, not the request future-build context. No generated-program runtime, universal conformance or installed/default claim.')
    for row in V.INPUTS.values():
        require(pin(row['file'])==row, 'Input changed during comparison')
    a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,metrics=metrics,out=pin(a.out))))


if __name__=='__main__':
    main()
