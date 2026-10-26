"""Root-only bounded NativeHost provider and session/batch smoke; no timing claim."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]; HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('contract',HERE/'workflow-v03.py');W=importlib.util.module_from_spec(spec);spec.loader.exec_module(W)
pin,read,retain,require=W.pin,W.read,W.retain,W.require

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for k in ['plan','revision-oracle','out']:p.add_argument('--'+k,type=Path,required=True)
    a=p.parse_args();plan=read(a.plan);out=a.out.resolve()
    require(os.sched_getaffinity(0)=={3},'Root CPU3 outer guard required')
    require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 output')
    require(plan['kind']=='phase144-native-qualification-plan' and plan['complete'],'Frozen native plan required')
    build_path=Path(plan['paths']['n2'])/'report.json';build=read(build_path)
    require(build['complete'] and build['source']==plan['sourceAdmission']['source'] and
            build['runtime']==plan['runtime'] and build['kind']=='phase134-supervised-qbe-stdin-build','Actual final N2 serial link required')
    image,runtime=build['binary'],build['runtime'];require(runtime['sha256']==W.SERIAL_SHA,'Exact serial runtime')
    for f in [__file__,HERE/'host-effects-v01.bend',ROOT/'selfhost/src/host/native-cli.bend',
              ROOT/'selfhost/src/host/native-os.c',HERE/'session-v01.py',HERE/'batch-v01.py',HERE/'smoke-derivation-v01.json']:
        retain(pin(f))
    derivation=read(HERE/'smoke-derivation-v01.json')
    for row in derivation['rows']:
        text=Path(row['parent']['file']).read_text()
        for e in row['edits']:
            require(text.count(e['before'])==e['count'],'Smoke derivative edit differs')
            text=text.replace(e['before'],e['after'])
        require(text.encode()==Path(row['derived']['file']).read_bytes(),'Smoke derivative bytes differ')
    historical=ROOT/'selfhost/build/phase140/batch-smoke-plan01.json'
    old=read(historical);require(len(old['jobs'])==4 and [x['name'] for x in old['jobs']]==['seed','edit','revert','edit-again'],'Frozen four-job fixture')
    for j in old['jobs']: retain(pin(j['source']))
    ap=ROOT/'selfhost/build/phase144/predicate-byte-candidate01/report.json'
    ar=read(ap);br=read(a.revision_oracle);ad=plan['sourceAdmission']
    require(ar['complete'] and ad['checkedApi'] in ar['inputs'] and ad['api'] in ar['inputs'] and
            ad['source'] in ar['inputs'],'A oracle does not bind selected source/API')
    aa=[x for x in ar['cases'] if x['name']=='lexer'];require(len(aa)==1 and aa[0]['verified'],'Exact A row missing')
    aa=aa[0];require(aa['source']==pin(old['logical']) and aa['qbe']['bytes']>0,'A source/product differs')
    bm=HERE/'hosted-smoke-oracle-v01.mjs';retain(pin(bm))
    require(pin(bm)['sha256']=='50055fa2a7668756b8cc0398baecf9908b7458a623827d3441b79645a1494c3b', 'Frozen B oracle method differs')
    require(br['kind']=='phase144-hosted-revision-oracle' and br['complete'] and br['verified'] and
            br['compilerSource']==ad['source'] and br['checkedApi']==ad['checkedApi'] and br['api']==ad['api'] and
            br['request']==dict(logicalPath=old['logical'],logicalSource=aa['source'],source=pin(old['jobs'][1]['source'])) and
            br['priorEmission']==pin(ap) and pin(bm) in br['inputs'] and br['qbe']['bytes']>0,
            'Fresh B bytes/logical path/API/oracle binding differs')
    oracle_binding=dict(aEmission=pin(ap),bEmission=pin(a.revision_oracle),compilerSource=ad['source'],
        checkedApi=ad['checkedApi'],api=ad['api'],logicalPath=old['logical'],a=aa['qbe'],b=br['qbe'])
    for i,j in enumerate(old['jobs']):
        require(j['source']==old['jobs'][i%2]['source'],'Frozen alternating A/B fixture changed')
        j['expected']=oracle_binding['a' if i%2==0 else 'b']['file']
    env={'PATH':'/usr/bin:/bin','LANG':'C','LC_ALL':'C','TZ':'UTC'}
    out.mkdir(parents=True)
    batch_plan=out/'batch-plan.json';batch_plan.write_text(json.dumps(old,indent=2)+'\n');retain(pin(batch_plan))
    report=dict(kind='phase144-native-host-smokes',complete=False,passed=False,image=image,runtime=runtime,
                imageBuild=pin(build_path),plan=pin(a.plan),oracleBinding=oracle_binding,batchPlan=pin(batch_plan),jobs=[],gates=dict(path=False,publish=False,batch=False,session=False),
                inputPolicy='Pinned N2+serial runtime; detached host workers; one Bend heap mutator; exact complete outputs.',
                scope='Small provider behavior and framed session/batch smoke only; no all-provider, race-freedom, timing or installed-selection claim.')
    def save():
        report['inputs']=list(W.V.INPUTS.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(name,argv,expected=None,code=0,seconds=90):
        argv=list(map(str,argv)); row=dict(name=name,command=argv,expectedExit=code,timeoutSeconds=seconds);report['jobs'].append(row);save()
        start=time.monotonic()
        with (out/(name+'.stdout')).open('xb') as so,(out/(name+'.stderr')).open('xb') as se:
            child=subprocess.Popen(argv,cwd=ROOT,env=env,stdout=so,stderr=se,start_new_session=True)
            try:status=child.wait(timeout=seconds)
            except BaseException:
                os.killpg(child.pid,signal.SIGKILL);child.wait();raise
        row.update(exitCode=status,seconds=time.monotonic()-start,stdout=pin(out/(name+'.stdout')),stderr=pin(out/(name+'.stderr')))
        require(status==code and row['stderr']['bytes']==0,'Child exit/diagnostic differs: '+name)
        if expected is not None:
            require(Path(row['stdout']['file']).read_bytes()==expected,'Complete output differs: '+name)
            row['expectedStdoutHex']=expected.hex();row['outputExact']=True
        save();return row
    try:
        emit=ROOT/'selfhost/build/phase111'/(out.name+'-effects')
        require(not emit.exists(),'Fresh effect fixture emission/build required')
        run('effects-build',[sys.executable,'-B',W.Q.NATIVE/'native-emit.py','--image',image['file'],
            '--source',HERE/'host-effects-v01.bend','--runtime',runtime['file'],'--out',emit,'--seconds','30','--build-seconds','30'])
        e=read(emit/'report.json');b=read(emit/'build/report.json')
        require(e['complete'] and e['image']==image and e['imageReceipt']==pin(build_path) and
                pin(HERE/'host-effects-v01.bend') in e['inputs'],'Effect source/image identity differs')
        binary=W.Q.build(b,e['product'],runtime,plan['machineTools']);retain(binary)
        base=[binary['file'],'--threads','1','--gpu','off','--']
        run('path-existing',base+['path',str(out)],(str(out)+'\n').encode())
        run('path-executable-directory',base+['path',''],(str(Path(binary['file']).parent)+'\n').encode())
        report['gates']['path']=True
        payload='owned café λ 🦋\n';published=out/'published.txt'
        run('publish-create',base+['publish',str(published),payload],b'published\n')
        require(published.read_bytes()==payload.encode(),'Published UTF8 bytes differ')
        first=pin(published);run('publish-existing-refusal',base+['publish',str(published),'wrong'],b'17\n',code=0)
        require(pin(published)==first and not list(out.glob('.bend-native-*')),'Existing output changed or temporary file leaked')
        run('published-read',base+['read',str(published)],(payload+'\n').encode())
        report['published']=first;report['gates']['publish']=True
        batch=out.with_name(out.name+'-batch');session=out.with_name(out.name+'-session')
        run('batch',[sys.executable,'-B',HERE/'batch-v01.py','--image',image['file'],'--runtime',runtime['file'],
            '--plan',batch_plan,'--out',batch,'--seconds','90'],seconds=100)
        br=read(batch/'report.json');require(br['complete'] and br['exitCode']==0 and
            br['independentProductsExact'] and br['changedInputs']==[] and len(br['jobs'])==4,'Batch oracle failed')
        require(all(j['exactOracle'] and j['product']['sha256']==pin(j['expected'])['sha256'] for j in br['jobs']),
                'Batch complete payload differs')
        report['batch']=pin(batch/'report.json');report['gates']['batch']=True
        ja,jb=old['jobs'][:2]
        run('session',[sys.executable,'-B',HERE/'session-v01.py','--image',image['file'],'--runtime',runtime['file'],
            '--a',ja['source'],'--b',jb['source'],'--hint',str(jb['hint']),'--owner',jb['owner'],'--mode','warm',
            '--expected-a',ja['expected'],'--expected-b',jb['expected'],'--out',session,'--seconds','90'],seconds=100)
        sr=read(session/'report.json');require(sr['complete'] and sr['exitCode']==0 and
            sr['independentProductsExact'] and sr['changedInputs']==[] and len(sr['transport'])==2,'Session oracle failed')
        require(all(j['exactOracle'] for j in sr['transport']),'Session complete output oracle missing')
        report['session']=pin(session/'report.json');report['gates']['session']=True
        for row in list(W.V.INPUTS.values()):W.Q.verify(row)
        report['complete']=report['passed']=True
    except BaseException as error:report['error']=repr(error)
    finally:save()
    print(json.dumps({k:report.get(k) for k in ['complete','passed','gates','error']}));return 0 if report['passed'] else 1
if __name__=='__main__':sys.exit(main())
