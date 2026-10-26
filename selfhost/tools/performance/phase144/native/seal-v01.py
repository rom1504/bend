"""Stricter immutable final sealer; uses the consumed v03 plan without new targets."""
import argparse
import importlib.util
from pathlib import Path
import json
import sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('workflow',HERE/'workflow-v03.py');W=importlib.util.module_from_spec(spec);spec.loader.exec_module(W)
for name in ['ROOT','V','Q','R','read','bound','retain','pin','require','source_contract','runtime_contract','pipe']:
    globals()[name]=getattr(W,name)
require(pin(W.__file__)['sha256']=='74a6e953c4a9951b7a1d34479cbd2872f337d5cb62bf65fca68c6a26e145a373','Frozen v03 changed')

def runtime_prerequisites(plan):
    summary=read(ROOT/'implementation/phase144/serial-rfc-relink-results.json')
    require(summary['complete'] and summary['semanticCases']==61 and summary['ordinaryExecutions']==122
            and summary['runtimeCliRefusals']==3,'Prior runtime semantic counts differ')
    prior=bound(summary['semanticPlan'])
    require(prior['complete'] and pin(prior['runtimes']['serial']['file'])==plan['runtime']
            and pin(prior['runtimeBuild']['file'])==plan['runtimeBuild'],'Prior semantic runtime differs')
    for name in ['safety','full']:
        report=bound(summary['reports'][name]);require(report['complete'] and report['passed'],'Prior runtime gate failed')
    word=read(ROOT/'selfhost/build/phase144/serial-word-controls01/report.json')
    source=pin(ROOT/'selfhost/build/phase144/serial-rfc01/runtime.c')
    require(word['complete'] and len(word['jobs'])==9 and all(j['expectedExact'] for j in word['jobs'])
            and source in word['inputs'],'Word controls/source failed')


def smoke_contract(path, plan, image, build_path):
    smoke=read(path);method=HERE/'host-smokes-v02.py'
    require(smoke['kind']=='phase144-native-host-smokes' and smoke['complete'] and smoke['passed'] and
            smoke['runtime']==plan['runtime'] and smoke['image']==image and smoke['imageBuild']==pin(build_path)
            and smoke['plan']==pin(ARGS.plan) and pin(method) in smoke['inputs'],'Actual selected N2 smoke/method differs')
    names=['effects-build','path-existing','path-executable-directory','publish-create',
           'publish-existing-refusal','published-read','batch','session']
    require([j['name'] for j in smoke['jobs']]==names,'Exact eight smoke jobs required')
    require(set(smoke['gates'])=={'path','publish','batch','session'} and all(smoke['gates'].values()),'Four smoke gates required')
    out=Path(path).resolve().parent
    emit=ROOT/'selfhost/build/phase111'/(out.name+'-effects')
    e=read(emit/'report.json');b=read(emit/'build/report.json')
    require(e['complete'] and e['image']==image and e['imageReceipt']==pin(build_path) and
            pin(HERE/'host-effects-v01.bend') in e['inputs'],'Actual provider fixture/compiler differs')
    binary=Q.build(b,e['product'],plan['runtime'],plan['machineTools'])
    prefix=[binary['file'],'--threads','1','--gpu','off','--'];payload='owned café λ 🦋\n'
    expected=[('path-existing',['path',str(out)],(str(out)+'\n').encode(),0),
      ('path-executable-directory',['path',''],(str(Path(binary['file']).parent)+'\n').encode(),0),
      ('publish-create',['publish',str(out/'published.txt'),payload],b'published\n',0),
      ('publish-existing-refusal',['publish',str(out/'published.txt'),'wrong'],b'17\n',1),
      ('published-read',['read',str(out/'published.txt')],(payload+'\n').encode(),0)]
    for name,args,stdout,exitcode in expected:
        j=next(j for j in smoke['jobs'] if j['name']==name)
        require(j['command']==prefix+args and j['exitCode']==exitcode and j['stderr']['bytes']==0
                and Q.verify(j['stdout']).read_bytes()==stdout and j['outputExact'], 'Provider complete observation differs: '+name)
    require(Q.verify(smoke['published']).read_bytes()==payload.encode() and not list(out.glob('.bend-native-*')),
            'Published UTF8/current cleanup differs')
    for j in smoke['jobs']:
        require(j['stderr']['bytes']==0 and j['exitCode']==(1 if j['name']=='publish-existing-refusal' else 0), 'Smoke subprocess failed')
    oracle=smoke['oracleBinding'];ad=plan['sourceAdmission']
    require(oracle['compilerSource']==ad['source'] and oracle['checkedApi']==ad['checkedApi'] and oracle['api']==ad['api'],
            'Hosted oracle source/API differs')
    ar=bound(oracle['aEmission']);br=bound(oracle['bEmission'])
    require(ar['complete'] and ad['checkedApi'] in ar['inputs'] and ad['api'] in ar['inputs'] and ad['source'] in ar['inputs'],
            'Independent hosted A binding failed')
    aa=[c for c in ar['cases'] if c['name']=='lexer'];require(len(aa)==1 and aa[0]['verified'] and aa[0]['qbe']==oracle['a'], 'A oracle differs')
    require(br['kind']=='phase144-hosted-revision-oracle' and br['complete'] and br['verified'] and br['qbe']==oracle['b'] and
            br['checkedApi']==ad['checkedApi'] and br['api']==ad['api'] and br['compilerSource']==ad['source'] and
            br['request']['logicalPath']==oracle['logicalPath']==aa[0]['source']['file'] and
            br['request']['logicalSource']==aa[0]['source'] and br['priorEmission']==oracle['aEmission'] and
            pin(HERE/'hosted-smoke-oracle-v01.mjs') in br['inputs'],'Independent hosted B binding failed')
    bp=bound(smoke['batchPlan']);old=read(ROOT/'selfhost/build/phase140/batch-smoke-plan01.json')
    require(bp['logical']==old['logical']==oracle['logicalPath'] and len(bp['jobs'])==4,'Batch fixture identity differs')
    for i,(new,prior) in enumerate(zip(bp['jobs'],old['jobs'])):
        changed=dict(prior,expected=oracle['a' if i%2==0 else 'b']['file'])
        require(new==changed,'Changed batch request beyond current-policy oracle')
        require(pin(new['source'])==(aa[0]['source'] if i%2==0 else br['request']['source']), 'Physical revision differs')
    batch=bound(smoke['batch']);session=bound(smoke['session'])
    require(batch['complete'] and batch['exitCode']==0 and batch['independentProductsExact'] and
            batch['changedInputs']==[] and len(batch['jobs'])==4 and pin(HERE/'batch-v01.py') in batch['inputs'], 'Batch failed/method differs')
    require(session['complete'] and session['exitCode']==0 and session['independentProductsExact'] and
            session['changedInputs']==[] and len(session['transport'])==2 and pin(HERE/'session-v01.py') in session['inputs'], 'Session failed/method differs')
    for report in [batch,session]:
        require(image in report['inputs'] and plan['runtime'] in report['inputs'] and pin(build_path) in report['inputs'],
                'Session/batch actual link identity differs')
    for i,j in enumerate(batch['jobs']):
        require(j['exactOracle'] and j['product']['sha256']==oracle['a' if i%2==0 else 'b']['sha256'],'Batch raw QBE differs')
    for j,key in zip(session['transport'],['a','b']):
        require(j['exactOracle'] and j['payload']['sha256']==oracle[key]['sha256'],'Session raw QBE differs')
    return smoke


def seal(a):
    retain(pin(__file__))
    plan=read(a.plan); require(plan['kind']=='phase144-native-qualification-plan' and plan['complete'], 'Frozen plan required')
    require(pin(W.__file__) in plan['inputs'],'Planner/sealer changed after plan preparation')
    runtime_prerequisites(plan)
    s=plan['sourceAdmission']; now=source_contract(s['sourceManifest']['file'],s['checkedApi']['file'],s['finiteControls']['file'])
    require(now==s and runtime_contract()==plan['runtime'],'Source/runtime admission differs')
    parent=bound(plan['producerQualification']); require(parent['nativeQualified'] and
        plan['producer'] in [parent['n1'],parent['n2']],'Qualified producer differs')
    expected=['n1','n2','q3','n1-focused19','n2-focused19','n2-full45']
    require([j['name'] for j in plan['jobs']]==expected,'Expected exact six native jobs')
    for job in plan['jobs']:
        g=read(job['guardReport']); require(g['complete'] and g['returncode']==0 and not g.get('stoppedFor')
            and g['command'][-len(job['command']):]==job['command'], 'Guard failed or child command differs')
    paths={k:Path(v)/'report.json' for k,v in plan['paths'].items()}
    b1=pipe(paths['n1'],plan['producer'],s['source'],plan['runtime'],plan)
    b2=pipe(paths['n2'],b1['binary'],s['source'],plan['runtime'],plan)
    q3=read(paths['q3']);require(q3['kind']=='phase130-native-source-qbe-request' and q3['complete'] and
        q3['exitCode']==0 and q3['changedInputs']==[] and q3['stderr']['bytes']==0 and q3['byteExact'], 'Q3 request failed')
    require(q3['image']==b2['binary'] and q3['source']==s['source'] and
        q3['command']==V.command(b2['binary'],s['source'],plan['base'],plan['carrier'],plan['stamp']) and
        q3['expectedQbe']==b2['retainedIR'] and V.exact(q3['product'],b2['retainedIR']), 'Q2/Q3 complete fixed point differs')
    require(pin(R.__file__) in q3['inputs'] and plan['carrierReceipt'] in q3['inputs'], 'Q3 request authority missing')
    suites=[V.coverage(paths['n1-focused19'],b1['binary'],paths['n1'],plan['runtime'],plan['machineTools']),
            V.coverage(paths['n2-focused19'],b2['binary'],paths['n2'],plan['runtime'],plan['machineTools']),
            V.coverage(paths['n2-full45'],b2['binary'],paths['n2'],plan['runtime'],plan['machineTools'],broad=True)]
    # Separate path/publish/batch/session smoke has its own oracle and runtime authority.
    smoke=smoke_contract(a.host_smokes,plan,b2['binary'],paths['n2'])
    result=dict(kind='phase144-native-qualification',complete=True,nativeQualified=True,targetsRun=False,
        plan=pin(a.plan),source=s['source'],api=s['api'],sourceAdmission=s,runtime=plan['runtime'],
        actualRuntimeAuthority=[plan['runtimeBuild'],pin(paths['n1']),pin(paths['n2'])],
        producer=plan['producer'],producerQualification=plan['producerQualification'],n1=b1['binary'],n2=b2['binary'],
        qbe=dict(q1=b1['retainedIR'],q2=b2['retainedIR'],q3=q3['product']),q2EqualsQ3=True,
        q1EqualsQ2=V.exact(b1['retainedIR'],b2['retainedIR']),suites=suites,hostSmokes=pin(a.host_smokes),
        inputs=list(V.INPUTS.values()),installed=False,defaultChanged=False,
        scope='Checked source; qualified native parent -> N1 -> N2; N2 reproduces complete Q2 as Q3. Two focused19 and N2 ordinary45 independent stdout/refusal gates, plus NativeHost smoke. Pinned single-mutator runtime only. No N3 machine/ELF identity, universal conformance, compiler theorem, performance or installed/default claim.')
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 receipt required')
    for row in V.INPUTS.values():
        require(Q.pin(row['file'])==row,'Input changed during final seal: '+row['file'])
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,nativeQualified=True,report=pin(a.out))))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for k in ['plan','host-smokes','out']:p.add_argument('--'+k,type=Path,required=True)
    ARGS=p.parse_args();seal(ARGS)
