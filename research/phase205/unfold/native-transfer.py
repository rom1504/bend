"""Real-image transfer on the untouched packet input under the shared CPU3 guard."""
import argparse,json,math,os,statistics,subprocess,time
from pathlib import Path
from measure import B,HERE,ROOT,M,image_binding
from make_fixtures import oracle
from summarize import census

PLAN=HERE/'native-transfer-plan.json'
BUILD=ROOT/'selfhost/build/phase201'
PACKET='fc1c775bab1fe3def7beaf75622a0f3fdff417d9fa83cac8ef11df1e3677050d'

def freeze():
    old=B.read(HERE/'plan.json');source=B.pin(HERE/'packet.bend');assert source==old['cases']['packet']['original'] and source['sha256']==PACKET
    runtime=old['runtime'];B.verify(runtime);producer=BUILD/'p204image03';parent_receipt=B.read(producer/'results.json');producer_elf=parent_receipt['runs'][0]['elfSha256'];compiler_runtime=B.pin(BUILD/'runtime01/runtime.o');meta={}
    for role,tag,folder in [('baseline','p205parent01','merge01'),('candidate','p205image06','selected06')]:
        src=B.pin(ROOT/'selfhost/build/phase205'/folder/'compiler.bend');meta[role]=dict(name=tag,source=src,image=str(BUILD/tag/'program.gz'),receipt=str(BUILD/tag/'results.json'),process=str(BUILD/(tag+'-guard')/'process.json'),retention=str(BUILD/(tag+'-guard')/'retention.json'))
    points=[[512,17],[512,123],[512,4294967295]];extra=[[0,0],[1,7],[3,123],[17,4294967295]];inputs=B.unique_inputs([source,runtime,compiler_runtime,B.pin(producer/'results.json'),B.pin(__file__),B.pin(HERE/'measure.py'),B.pin(HERE/'make_fixtures.py'),B.pin(HERE/'summarize.py'),B.pin(M.__file__),B.pin(ROOT/'research/phase205/measure/support.py'),B.pin(HERE/'plan.json'),B.pin(old['compilerCommand'][10]),B.pin(old['compilerCommand'][12]),B.pin(old['linkCommand'][0]),*(v['source']for v in meta.values())]);plan=dict(kind='phase205-unmodified-packet-native-transfer',packet=source,roles=meta,knownParentReceipt=B.pin(BUILD/'p205parent01/results.json'),producerELF=producer_elf,compilerRuntime=compiler_runtime,runtime=runtime,compilerCommand=old['compilerCommand'],linkCommand=old['linkCommand'],points=[dict(args=p,expected=oracle(*p))for p in points],extra=[dict(args=p,expected=oracle(*p)) for p in extra],inputs=inputs,minimumSampleMs=100,pilotMinimumMs=145,targetMs=180,rounds=4);B.save(PLAN,plan)

def probe(exe,args,expected,reps,warmups,default):
    cmd=[str(exe),*B.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),str(reps),str(warmups),*map(str,args)];start=time.monotonic();q=subprocess.run(cmd,capture_output=True,timeout=9);wall=time.monotonic()-start
    # The original harness compares every loop result to the default oracle.
    # Alternate-seed first-line values are independently checked on every run;
    # their exact expected counts are zero by the unchanged harness contract.
    match=expected==default;ms=B.observation(q.stdout,q.stderr,q.returncode,dict(expectedStdout=expected,warmups=warmups if match else 0,repetitions=reps if match else 0),wall)
    return dict(elapsedMs=ms,wall=wall,stdout=q.stdout.decode(),repetitions=reps,warmups=warmups)

def run(out):
    assert os.sched_getaffinity(0)=={3};out=out.resolve();out.mkdir(parents=True,exist_ok=False);plan=B.read(PLAN);r=dict(complete=False,plan=B.pin(PLAN),images={},products={},preflight=[],timing=[]);start=time.monotonic();deadline=start+43
    def save():B.save(out/'report.json',r)
    try:
        for pin in plan['inputs']+[plan['knownParentReceipt']]:B.verify(pin)
        exes={};save()
        for role,meta in plan['roles'].items():
            binding=image_binding(meta['image'],meta['receipt'],meta['source']['file']);assert binding['source']==meta['source'];p=B.read(meta['process']);t=B.read(meta['retention']);assert p['complete'] and p['returncode']==0 and t['closed'] and t['outcome']=='succeeded';receipt=B.read(meta['receipt']);assert receipt['source']==meta['source']['file'] and receipt['sourceSha256']==meta['source']['sha256'];assert receipt['productRuntimeSha256']==plan['compilerRuntime']['sha256'] and receipt['runs'][0]['producerSha256']==plan['producerELF'];assert p['command'][p['command'].index('--source')+1]==str(Path(meta['source']['file']).relative_to(ROOT));fd,identity=M.load_image(binding)
            try:_,built=M.build(plan,binding,fd,plan['packet'],out/role,deadline)
            finally:os.close(fd)
            r['images'][role]=dict(binding=binding,rehashedELF=identity,process=B.pin(meta['process']),retention=B.pin(meta['retention']));r['products'][role]=dict(build=built,machine=census(built['object']['file']));verify_product=built['binary'];B.verify(verify_product);B.verify(built['object']);exes[role]=verify_product['file'];save()
        r['identicalObjects']=r['products']['baseline']['build']['object']['sha256']==r['products']['candidate']['build']['object']['sha256'];r['identicalExecutables']=r['products']['baseline']['build']['binary']['sha256']==r['products']['candidate']['build']['binary']['sha256'];default=plan['points'][0]['expected']
        for p in plan['points']+plan['extra']:
            assert oracle(*p['args'])==p['expected'];r['preflight'].append(dict(point=p,observed={role:probe(exe,p['args'],p['expected'],0,0,default)for role,exe in exes.items()}));save()
        for i,p in enumerate(plan['points']):
            counts={};row=dict(point=p,pilots={},observations=[],pairs=[]);r['timing'].append(row)
            for role,exe in exes.items():
                reps=32;rec=row['pilots'][role]=[]
                for _ in range(8):
                    v=probe(exe,p['args'],p['expected'],reps,3,default);ms=v['elapsedMs'];rec.append(v)
                    if plan['pilotMinimumMs']<=ms<=450:break
                    reps=min(1048576,max(1,math.ceil(reps*plan['targetMs']/max(1,ms))))
                else:raise RuntimeError('calibration failed '+role)
                counts[role]=reps
            values={role:[]for role in exes}
            for turn in range(plan['rounds']):
                roles=['baseline','candidate'] if (turn+i)%2==0 else ['candidate','baseline']
                for role in roles:
                    v=probe(exes[role],p['args'],p['expected'],counts[role],3,default);assert v['elapsedMs']>=plan['minimumSampleMs'];values[role].append(v['elapsedMs']/counts[role]);row['observations'].append(dict(role=role,round=turn,**v));save()
                row['pairs'].append(values['candidate'][-1]/values['baseline'][-1]);save()
            row['medianMsPerInvocation']={role:statistics.median(a)for role,a in values.items()};row['candidateOverBaseline']=row['medianMsPerInvocation']['candidate']/row['medianMsPerInvocation']['baseline'];row['medianPaired']=statistics.median(row['pairs']);save()
        for product in r['products'].values():B.verify(product['build']['binary']);B.verify(product['build']['object']);assert product['build']['source']==plan['packet'] and product['build']['runtime']==plan['runtime']
        r['complete']=True
    except BaseException as e:r['error']=repr(e);raise
    finally:r['wallSeconds']=time.monotonic()-start;save()
    print(json.dumps({str(t['point']['args']):t['candidateOverBaseline']for t in r['timing']}))

if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--freeze',action='store_true');a.add_argument('--out',type=Path);p=a.parse_args();freeze() if p.freeze else run(p.out)
