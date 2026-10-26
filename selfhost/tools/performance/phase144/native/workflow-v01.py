"""Prepare/seal the Phase144 native chain. Data only: this never runs targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec); spec.loader.exec_module(obj)
    return obj

V = module('p144_native_receipts', ROOT/'selfhost/tools/performance/phase131/native/qualify.py')
Q, C, R = V.Q, V.C, V.R
pin, read, bound, require, retain = Q.pin, V.read, V.bound, V.require, V.retain
PARENT = ROOT/'implementation/phase143/qualification.json'
PIPE = ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py'
GUARD = ROOT/'selfhost/tools/performance/phase111/guard.py'
CARRIER = ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
RUNTIME_BUILD = ROOT/'selfhost/build/phase144/serial-rfc01/build.json'
SERIAL_SHA = '2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3'
GROUPS = {'p144o_controls':35,'p144e_controls':10,'p144pc_controls':27,
          'p144ap_controls':23,'p125pc_controls':12,'p127lb_controls':20}
# This finite source inventory is independently replayed, not trusted as a verdict.
PROTECTED_INVENTORY = ROOT/'selfhost/build/phase144/integrated-source02/manifest.json'
INVENTORY_SHA = '594edc898f550f12bb2b9b8982b538fe316f2328b05805ddcc821d039c0a8578'
CANONICALIZER_SHA = '92ace74e643275d4a22bbae885ae841b8610d662a5cfa4bf5556bffddac61b21'


def source_contract(manifest_path, checked_path, finite_path):
    sm, api, finite = read(manifest_path), read(checked_path), read(finite_path)
    parent = read(PARENT)
    require(parent['complete'] and parent['nativeQualified'], 'Qualified Phase143 parent required')
    require(sm['complete'] and api['kind']=='phase111-checked-api' and api['complete']
            and api['checked'] and api['status']==0, 'Complete independently checked source required')
    require(sm['source'] in api['inputs'] and api['command'][2:4]==[sm['source']['file'],api['api']['file']]
            and api['command'][4:]==api['exports'], 'Checked API/source/exports do not join')
    require({'p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next'} <= set(api['exports']),
            'Native compiler entry exports missing')
    prior_api=read(ROOT/'selfhost/build/phase111/p144-integrated-api02/report.json')
    require(api['command'][:2]==prior_api['command'][:2], 'Independent checker command changed')
    for item in prior_api['inputs']:
        if item['file']==str(PROTECTED_INVENTORY.parent/'compiler.bend'): continue
        require(any(x['bytes']==item['bytes'] and x['sha256']==item['sha256'] for x in api['inputs']),
                'Independent checker closure differs: '+item['file'])
    require(pin(PROTECTED_INVENTORY)['sha256']==INVENTORY_SHA, 'Protected authority changed')
    inventory = read(PROTECTED_INVENTORY)
    overlay = sm
    if sm['kind']=='phase144-lexical-predicate-canonicalization':
        overlay = bound(sm['parentManifest'])
        require(overlay['source']==sm['parent'], 'Canonical parent differs')
        require(sm['method']['sha256']==CANONICALIZER_SHA, 'Canonicalizer differs')
        T = module('p144_canonicalizer', sm['method']['file'])
        census_path = ROOT/'selfhost/tools/performance/phase141/census/read-onlyinventory.py'
        census = module('p144_source_census', census_path); retain(pin(census_path))
        rows = census.parse(sm['parent']['file']); T.assert_rules(rows,census)
        protected = set(overlay['protectedDeclarations'])|set(overlay['unchangedProofDeclarations'])
        text, accepted, rejected = T.transform(Path(sm['parent']['file']).read_text(), rows, protected, False)
        require(text.encode()==Path(sm['source']['file']).read_bytes() and accepted==sm['accepted']
                and rejected==sm['rejected'], 'Full lexical canonicalization replay differs')
    require(overlay['kind']=='phase144-explicit-overlay' and overlay['parent']==parent['source'],
            'Explicit overlay on qualified Phase143 source required')
    snapshots = sorted(Path(overlay['source']['file']).parent.glob('module*.bend'),
                       key=lambda p:int(p.stem[6:]))
    require(snapshots, 'No source module snapshots')
    for path in snapshots:
        row = pin(path); retain(row)
        require(any(x['bytes']==row['bytes'] and x['sha256']==row['sha256'] for x in overlay['inputs']),
                'Module snapshot missing original input binding')
    old_text = Path(parent['source']['file']).read_text()
    replay, added, _ = C.compose(old_text,[p.read_text() for p in snapshots],set(overlay['overrides']),set())
    require(replay.encode()==Path(overlay['source']['file']).read_bytes() and added==overlay['added'],
            'Whole overlay source replay differs')
    old,new = C.blocks(old_text),C.blocks(Path(sm['source']['file']).read_text())
    protected = inventory['protectedDeclarations']; proofs = inventory['unchangedProofDeclarations']
    require(sm['protectedDeclarations']==protected and sm['unchangedProofDeclarations']==proofs,
            'Protected/proof inventory changed')
    require(all(old[n]==new[n] for n in protected+proofs), 'Protected or proof declaration changed')
    require(finite['complete'] and pin(checked_path) in finite['inputs'] and api['api'] in finite['inputs']
            and sm['source'] in finite['inputs'], 'Controls do not bind chosen checked source/API')
    groups=finite['groups']
    require(len(groups)==len(GROUPS) and {g['root']:len(g['rows']) for g in groups}==GROUPS,
            'Exact six groups / 127 controls required')
    require(all(isinstance(x,str) and (x.startswith('PASS ') or x.endswith(':pass'))
                for g in groups for x in g['rows']), 'Control verdict failed')
    return dict(source=sm['source'],api=api['api'],sourceManifest=pin(manifest_path),checkedApi=pin(checked_path),
                finiteControls=pin(finite_path),controls=127,completeSourceReplay=True,
                protectedDeclarations=protected,unchangedProofDeclarations=proofs,
                changedDeclarations=sorted(n for n in old if n in new and old[n]!=new[n]),
                addedDeclarations=sorted(set(new)-set(old)))


def runtime_contract():
    b=read(RUNTIME_BUILD); r=b['variants']['serial-rfc']['object']
    require(b['complete'] and r['sha256']==SERIAL_SHA, 'Exact built serial runtime required')
    expected=['atomic-control-compile','atomic-control-link','serial-rfc-compile','serial-rfc-link']
    require([j['label'] for j in b['jobs']]==expected and all(j['exitCode']==0 for j in b['jobs']),
            'Runtime build incomplete')
    manifest=read(RUNTIME_BUILD.with_name('manifest.json'))
    require([j['command'] for j in b['jobs']]==[j['argv'] for j in manifest['commands']],
            'Runtime compilation/link command differs')
    require('-DP144_SINGLE_MUTATOR_RFC=1' in b['jobs'][2]['command'] and
            b['jobs'][2]['command'][-1]==r['file'], 'Serial macro/object differs')
    summary=read(ROOT/'implementation/phase144/serial-rfc-relink-results.json')
    require(summary['complete'], 'Closed serial runtime semantic receipt required')
    word=read(ROOT/'selfhost/build/phase144/serial-word-controls01/report.json')
    require(word['complete'] and len(word['jobs'])==9, 'Actual word/refusal controls missing')
    return r


def prepare(a):
    out=a.out.resolve(); require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144'),
                                 'Fresh Phase144 plan directory required')
    require(re.fullmatch(r'[a-z0-9-]+',a.label), 'Simple unique label required')
    source=source_contract(a.manifest,a.checked_api,a.controls)
    runtime=runtime_contract(); parent=read(PARENT)
    producer=pin(a.producer) if a.producer else parent['n2']
    require(producer in [parent['n1'],parent['n2']], 'Producer must be a qualified Phase143 image')
    carrier,base,carrier_inputs=R.carrier_inputs(CARRIER); retain(carrier_inputs)
    tools=read(Q.BASE)['tools']
    stem='p144-'+a.label
    paths={'n1':ROOT/'selfhost/build/phase134'/(stem+'-n1'),
           'n2':ROOT/'selfhost/build/phase134'/(stem+'-n2'),
           'q3':ROOT/'selfhost/build/phase130'/(stem+'-q3'),
           'n1-focused19':ROOT/'selfhost/build/phase111'/(stem+'-n1-focused19'),
           'n2-focused19':ROOT/'selfhost/build/phase111'/(stem+'-n2-focused19'),
           'n2-full45':ROOT/'selfhost/build/phase111'/(stem+'-n2-full45')}
    jobs=[]
    def job(name,cmd,seconds,rss=3072):
        guard=ROOT/'selfhost/build/phase144'/(stem+'-'+name+'-guard')
        require(not guard.exists() and not paths[name].exists(),'Output/guard already exists: '+name)
        argv=[str(x) for x in cmd]
        jobs.append(dict(name=name,command=argv,report=str(paths[name]/'report.json'),
            guardReport=str(guard/'process.json'),guardedCommand=[sys.executable,'-B',str(GUARD),
            '--out',str(guard),'--seconds',str(seconds),'--rss-mib',str(rss),'--available-mib','16384',
            '--file-mib','256','--cpu','3','--',*argv]))
    for name,prod in [('n1',producer['file']),('n2',paths['n1']/'program')]:
        job(name,[sys.executable,'-B',PIPE,'--image',prod,'--source',source['source']['file'],
            '--carrier-receipt',CARRIER,'--runtime',runtime['file'],'--retain-ir',
            '--out',paths[name],'--seconds','600'],660)
    job('q3',[sys.executable,'-B',Path(R.__file__),'--image',paths['n2']/'program',
        '--source',source['source']['file'],'--carrier-receipt',CARRIER,'--expected-qbe',
        paths['n2']/'program.ssa','--out',paths['q3'],'--seconds','600'],630)
    for name in ['n1-focused19','n2-focused19','n2-full45']:
        broad=name.endswith('full45'); corpus=Q.NATIVE/'full45.py' if broad else Q.NATIVE/'coverage.py'
        frozen=read(ROOT/'selfhost/tools/performance/phase111/coverage'/('full45/manifest.json' if broad else 'manifest.json'))
        names=[x['name'] for x in frozen['fixtures']]
        job(name,[sys.executable,'-B',corpus,'--image',paths[name[:2]]/'program','--runtime',runtime['file'],
            '--out',paths[name],'--mode','cache','--seconds','240','--build-seconds','30','--names',*names],600)
    for f in [__file__,PIPE,GUARD,Q.__file__,V.__file__,C.__file__,R.__file__,Q.BUILDER,Q.NATIVE/'coverage.py',
              Q.NATIVE/'native-emit.py',Q.NATIVE/'full45.py',Q.NATIVE/'derivation01.json',CARRIER]: retain(pin(f))
    plan=dict(kind='phase144-native-qualification-plan',complete=True,nativeQualified=False,targetsRun=False,
        sourceAdmission=source,producer=producer,producerQualification=pin(PARENT),runtime=runtime,
        runtimeBuild=pin(RUNTIME_BUILD),carrierReceipt=pin(CARRIER),base=base,carrier=carrier['carrier'],stamp=carrier['stamp'],
        machineTools=tools,paths={k:str(v) for k,v in paths.items()},jobs=jobs,inputs=list(V.INPUTS.values()),
        expectedFixedPoint='Q2 == Q3; Q1 may differ',runtimeScope='Pinned single Bend heap mutator; threads=1, GPU off; fixed providers only',
        semanticScope='N1 focused19; N2 focused19 and independent ordinary45. No old-QBE oracle; generated program runtime is explicitly serial.',
        unchangedDefault=True,installed=False)
    out.mkdir(parents=True);(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(prepared=True,nativeQualified=False,plan=pin(out/'plan.json'),jobs=len(jobs))))


def pipe(path,image,source,runtime,plan):
    r=read(path); require(r['kind']=='phase134-supervised-qbe-stdin-build' and r['complete'] and
        not r.get('timedOut') and r['compilerExitCode']==r['qbeExitCode']==0 and r['retainIR'], 'Native pipe failed')
    require(r['image']==image and r['source']==source and r['runtime']==runtime, 'Native pipe lineage differs')
    require(r['compilerCommand']==V.command(image,source,plan['base'],plan['carrier'],plan['stamp']),
            'Exact compiler request differs')
    require(r['irDigest']=={k:r['retainedIR'][k] for k in ['bytes','sha256']} and r['retainedIR']['bytes']>0,
            'Retained raw QBE differs from streamed product')
    require(all(r[k]['bytes']==0 for k in ['compilerStderr','qbeStderr','qbeStdout']), 'Native/QBE diagnostic')
    require(all(x in r['inputs'] for x in [image,source,runtime,pin(PIPE)]), 'Pipe method/input identity missing')
    q=r['qbeCommand']; require(q[1:]==['-t','amd64_sysv','-o',r['assembly']['file'],'-'], 'QBE argv differs')
    require([j['label'] for j in r['jobs']]==['assemble','link'] and all(j['exitCode']==0 for j in r['jobs']),
            'Machine stages incomplete')
    asm,link=[j['command'] for j in r['jobs']]
    require(asm[1:]==['-mbranches-within-32B-boundaries','-o',r['object']['file'],r['assembly']['file']], 'Assembler argv differs')
    require(link[1:]==['-no-pie',r['object']['file'],runtime['file'],'-pthread','-lm','-o',r['binary']['file']], 'Linked runtime/flags differ')
    for k,cmd in [('qbe',q),('assembler',asm),('linker',link)]:
        require(pin(cmd[0])==plan['machineTools'][k] and pin(cmd[0]) in r['inputs'],'Machine tool differs')
    return r


def seal(a):
    plan=read(a.plan); require(plan['kind']=='phase144-native-qualification-plan' and plan['complete'], 'Frozen plan required')
    require(pin(__file__) in plan['inputs'],'Planner/sealer changed after plan preparation')
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
    smoke=read(a.host_smokes); require(smoke['complete'] and smoke['passed'] and
        smoke['runtime']==plan['runtime'] and smoke['image']==b2['binary'], 'Chosen N2 NativeHost smokes required')
    require(set(smoke['gates'])=={'path','publish','batch','session'} and all(smoke['gates'].values()),
            'Four NativeHost gates required')
    result=dict(kind='phase144-native-qualification',complete=True,nativeQualified=True,targetsRun=False,
        plan=pin(a.plan),source=s['source'],api=s['api'],sourceAdmission=s,runtime=plan['runtime'],
        actualRuntimeAuthority=[plan['runtimeBuild'],pin(paths['n1']),pin(paths['n2'])],
        producer=plan['producer'],producerQualification=plan['producerQualification'],n1=b1['binary'],n2=b2['binary'],
        qbe=dict(q1=b1['retainedIR'],q2=b2['retainedIR'],q3=q3['product']),q2EqualsQ3=True,
        q1EqualsQ2=V.exact(b1['retainedIR'],b2['retainedIR']),suites=suites,hostSmokes=pin(a.host_smokes),
        inputs=list(V.INPUTS.values()),installed=False,defaultChanged=False,
        scope='Checked source; qualified native parent -> N1 -> N2; N2 reproduces complete Q2 as Q3. Two focused19 and N2 ordinary45 independent stdout/refusal gates, plus NativeHost smoke. Pinned single-mutator runtime only. No N3 machine/ELF identity, universal conformance, compiler theorem, performance or installed/default claim.')
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 receipt required')
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,nativeQualified=True,report=pin(a.out))))


def main():
    ap=argparse.ArgumentParser(description=__doc__); sub=ap.add_subparsers(dest='action',required=True)
    p=sub.add_parser('prepare')
    for k in ['manifest','checked-api','controls','out']:p.add_argument('--'+k,type=Path,required=True)
    p.add_argument('--producer',type=Path);p.add_argument('--label',required=True)
    p=sub.add_parser('seal')
    for k in ['plan','host-smokes','out']:p.add_argument('--'+k,type=Path,required=True)
    a=ap.parse_args();prepare(a) if a.action=='prepare' else seal(a)
if __name__=='__main__':main()
