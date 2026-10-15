#!/usr/bin/env python3
"""Matched native B1/B2 compiler clocks; optional independent generated-C execution."""
import argparse, json, math, os, re, shutil, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
from support import ROOT, P, authenticate, native_args, pin, read, verify, unchanged
HERE = Path(__file__).resolve().parent
SCREEN = ROOT/'selfhost/build/phase90/final-screen01/report.json'

def save(file, data): Path(file).write_text(json.dumps(data, indent=2)+'\n')

def prepare(context, corpus):
    inputs = {x['file']:x for x in context['inputs']}
    def bind(value):
        item = verify(value) if isinstance(value, dict) else pin(value)
        assert inputs.setdefault(item['file'],item) == item
        return item
    bind(__file__); bind(P/'phase86/guard.py'); bind(P/'programs/support.py'); bind(sys.executable)
    screen_pin = bind(SCREEN); screen = read(screen_pin['file'])
    assert screen['complete'] and screen['passed'] and screen['inputsUnchanged']
    assert screen['nativeAdmission']['source']['sha256'] == context['source']['sha256']
    assert screen['nativeAdmission']['runtime']['sha256'] == context['roles']['b2']['admission']['runtime']['sha256']
    provenance = dict(screen=screen_pin); cases = []
    if corpus == 'screen':
        for name, row in screen['oracles'].items():
            cases.append(dict(name=name,source=bind(row['input']),oracle=bind(row['b2Oracle']),tsOracle=row['tsOracle']))
        assert len(cases) == 6
        survey_pin = bind(screen['tsSurvey']); survey = read(survey_pin['file'])
        ts = survey['roles']['typescript']; prefix = str(Path(ts['bend']['file']).parent)+'/'
        for item in survey['inputs']:
            if item.get('file','').startswith(prefix): bind(item)
        for item in ts.values():
            if isinstance(item,dict) and 'sha256' in item: bind(item)
        assert ts['base']['sha256'] == context['roles']['b2']['admission']['base']['sha256']
        provenance.update(bun=bind(screen['bun']),referenceWorker=bind(P/'phase86/reference.mjs'),survey=survey_pin)
    else:
        broad_pin = bind(ROOT/'selfhost/build/phase90/broad-token45/report.json'); broad = read(broad_pin['file'])
        runtime_pin = bind(ROOT/'selfhost/build/phase90/runtime-cpp45/report.json'); runtime = read(runtime_pin['file'])
        assert broad['complete'] and broad['pass'] and broad['inputBindingsUnchanged'] and len(broad['rows']) == 45
        assert runtime['complete'] and runtime['pass_'] and runtime['inputsUnchanged'] and len(runtime['rows']) == 45
        assert runtime['newRuntime']['sha256'] == context['roles']['b2']['admission']['runtime']['sha256']
        runtime_plan = read(bind(runtime['plan'])['file']); assert len(runtime_plan['edits']) == 2
        derived = {x['name']:x for x in runtime['rows']}; assert len(derived) == 45
        manifest_pin = bind(ROOT/'selfhost/build/phase88/broad-fixtures03/manifest.json'); manifest = read(manifest_pin['file'])
        origins = {x['id']:x for x in manifest['cases']}; bind(manifest['catalog'])
        for row in broad['rows']:
            name = row['name']; changed = derived[name]; origin = origins[name]
            assert row['passed'] and row['exactPreprocessed'] and changed['exactInverse'] and changed['exactPreprocessed']
            assert origin['source'] == row['source']
            source = bind(row['source']); parent = bind(changed['parent']); oracle = bind(changed['derived'])
            assert parent == bind(row['current'])
            text = Path(parent['file']).read_text()
            for edit in runtime_plan['edits']:
                assert text.count(edit['before']) == 1
                text = text.replace(edit['before'],edit['after'],1)
            assert text.encode() == Path(oracle['file']).read_bytes()
            old_receipt = read(bind(row['oracleReceipt'])['file'])
            old = next(x for x in old_receipt['cases'] if x['id'] == name)
            assert old['pass_'] and old['exact'] and old['executionExact'] and old['expected'] == row['expectedStdout']
            assert old['source']['sha256'] == source['sha256']
            cases.append(dict(name=name,family=row['family'],source=source,oracle=oracle,
                expectedStdout=row['expectedStdout'],original=bind(origin['original']),historicalExecution=bind(row['oracleReceipt'])))
        provenance.update(broad=broad_pin,runtimeContinuity=runtime_pin,sourceManifest=manifest_pin,
                          originalSources=len({x['original']['sha256'] for x in cases}))
        assert provenance['originalSources'] == 23
    for row in cases:
        assert re.findall(r'^import .*$',Path(row['source']['file']).read_text(),re.M) == ['import Base']
    continuity_pin = bind(ROOT/'selfhost/build/phase91/continuity01/plan.json')
    continuity = read(continuity_pin['file'])
    assert len(continuity['jsCases']) == 23 and len(continuity['cCases']) == 12
    exclusions = []
    for row in continuity['cCases']:
        source = bind(row['source']); imports = re.findall(r'^import .*$',Path(source['file']).read_text(),re.M)
        assert imports != ['import Base']
        exclusions.append(dict(name=row['name'],source=source,imports=imports,reason='Original C12 module import exceeds the frozen native entry; no silent source rewrite.'))
    provenance.update(originalCorpus=continuity_pin,originalC12Exclusions=exclusions)
    return cases, provenance, inputs

def summarize(rows, names, roles):
    cases = {}
    for name in names:
        group = {}
        for role in roles:
            selected = [x for x in rows if x['case']==name and x['role']==role]
            assert selected and all(x['passed'] for x in selected)
            group[role] = {metric:statistics.median([x[metric] for x in selected])
                           for metric in ['requestMs','processWallMs']}
        ratios = {}
        pairs = [('b2','b1')] + ([('b1','ts-bun'),('b2','ts-bun')] if 'ts-bun' in roles else [])
        for numerator,denominator in pairs:
            ratios[numerator+'/'+denominator] = {k:group[numerator][k]/group[denominator][k]
                if group[denominator][k]>0 else None for k in ['requestMs','processWallMs']}
        cases[name] = dict(mediansMs=group,ratios=ratios)
    geometric = {}
    for pair in next(iter(cases.values()))['ratios']:
        geometric[pair] = {}
        for metric in ['requestMs','processWallMs']:
            values = [cases[name]['ratios'][pair][metric] for name in names]
            geometric[pair][metric] = math.exp(statistics.mean(map(math.log,values))) if all(x and x>0 for x in values) else None
    return dict(cases=cases,equalCaseGeometricRatios=geometric)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--b1-build',type=Path,required=True); parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--corpus',choices=['screen','broad45'],default='screen')
    parser.add_argument('--rounds',type=int,choices=[1,2,3]); parser.add_argument('--calls',type=int,choices=[1,5],default=1)
    parser.add_argument('--live',action='store_true'); parser.add_argument('--execute',action='store_true')
    parser.add_argument('--check-only',action='store_true'); parser.add_argument('--cases')
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase92') and not out.exists()
    assert not args.execute or args.corpus == 'broad45','Execution oracles are supplied by broad45'
    context = authenticate(args.b1_build); cases,provenance,inputs = prepare(context,args.corpus)
    all_names = [x['name'] for x in cases]
    if args.cases:
        wanted = args.cases.split(','); assert len(set(wanted))==len(wanted) and set(wanted)<=set(all_names)
        cases = [x for x in cases if x['name'] in wanted]
    names = [x['name'] for x in cases]; roles = ['b1','b2','ts-bun'] if args.corpus=='screen' else ['b1','b2']
    rounds = args.rounds or (2 if args.corpus=='screen' else 1)
    out.mkdir(parents=True)
    report = dict(kind='phase92-same-source-native-compiler-comparison',complete=False,passed=False,
        checkOnly=args.check_only,executionPerformed=False,method=pin(__file__),authentication=context,
        provenance=provenance,corpus=args.corpus,cases=cases,unselected=[x for x in all_names if x not in names],
        roles=roles,rounds=rounds,calls=args.calls,live=args.live,rows=[],programExecutions=[],inputs=list(inputs.values()),
        scope='Compiler first-request and fresh-process times. Matched native stages use exact D04/source/assets and consume full C/report; same Clang O2 flags, different compiler-runtime lowering. Native Base preparation and runtime transport precede request_ms. TS/Bun includes source Base checking inside request and reports imports separately. Process wall includes executable startup, preparation, output write and teardown, excluding Python authentication. Generated-program execution is a separate correctness gate, not a runtime benchmark or broad language conformance.')
    def final_inputs():
        unchanged(context)
        for item in inputs.values(): assert pin(item['file']) == item
    save(out/'report.json',report)
    if args.check_only:
        final_inputs(); report.update(complete=True,passed=True,inputsUnchanged=True,targetJobsRun=0)
        save(out/'report.json',report); print(json.dumps(dict(complete=True,targetJobsRun=0,report=str(out/'report.json')))); return
    def guarded(label,argv,seconds=60):
        assert shutil.disk_usage(ROOT).free>=176*1024**2,'Need 160 MiB reserve plus per-job output headroom'
        directory=out/(label+'-guard')
        command=[sys.executable,'-B',str(P/'phase86/guard.py'),'--out',str(directory),'--seconds',str(seconds),
                 '--rss-mib','2048','--available-mib','4096','--cpu','3','--',*map(str,argv)]
        env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS','NODE_PATH']}
        done=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,text=True)
        process=read(directory/'process.json') if (directory/'process.json').exists() else {}
        job=dict(command=command,guard=str(directory),process=process,guardExit=done.returncode,stdout=done.stdout,stderr=done.stderr)
        assert done.returncode==0 and process.get('complete') and process.get('returncode')==0 and not process.get('stoppedFor'),job
        return job
    started=time.monotonic(); error=None
    try:
        report['executionPerformed']=True
        for rnd in range(rounds):
            for ix,case in enumerate(cases):
                order=roles[ix%len(roles):]+roles[:ix%len(roles)]
                if rnd%2: order=list(reversed(order))
                for role in order:
                    label=f'{rnd+1}-{case["name"]}-{role}'; prefix=out/label
                    row=dict(round=rnd+1,case=case['name'],role=role,passed=False); report['rows'].append(row)
                    argv=(native_args(context,role,case['source']['file'],prefix,args.calls,args.live) if role!='ts-bun'
                          else [provenance['bun']['file'],provenance['referenceWorker']['file'],'typescript',case['source']['file'],str(prefix),str(args.calls)])
                    row['argv']=argv; save(out/'report.json',report)
                    row['job']=guarded(label,argv); row['processWallMs']=1000*row['job']['process']['wallSeconds']
                    outputs=[pin(str(prefix)+f'.{i}.c') for i in range(1,args.calls+1)]
                    oracle=case['tsOracle'] if role=='ts-bun' else case['oracle']
                    row['outputs']=outputs
                    assert all((x['sha256'],x['bytes'])==(oracle['sha256'],oracle['bytes']) for x in outputs),'Complete generated C differs'
                    if role!='ts-bun':
                        assert all(Path(x['file']).read_bytes()==Path(oracle['file']).read_bytes() for x in outputs)
                        logs=(Path(row['job']['guard'])/'stderr.log').read_text()
                        calls=re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$',logs,re.M)
                        assert [int(x[0]) for x in calls]==list(range(1,args.calls+1)) and all(int(x[2])>0 for x in calls)
                        row['requestsMs']=[int(x[1]) for x in calls]; row['consumedChars']=[int(x[2]) for x in calls]
                        for key in ['base_prepare_ms','runtime_prepare_ms']:
                            values=re.findall(r'^'+key+r'=(\d+)$',logs,re.M); assert len(values)==1
                            row[key]=int(values[0])
                    else:
                        worker=read(str(prefix)+'.json'); row['worker']=pin(str(prefix)+'.json')
                        assert worker['complete'] and len(worker['calls'])==args.calls and not worker.get('error')
                        assert all(x['observation']['status']=='ok' and x['observation']['checked'] for x in worker['calls'])
                        row['requestsMs']=[x['requestMs'] for x in worker['calls']]; row['importsMs']=worker['importsMs']
                    row.update(requestMs=row['requestsMs'][0],exactC=True,passed=True)
                    save(out/'report.json',report)
                    print(json.dumps({k:row[k] for k in ['round','case','role','requestMs','processWallMs','exactC']}),flush=True)
        report['summary']=summarize(report['rows'],names,roles)
        if args.execute:
            for case in cases:
                # Both native producers emitted identical complete C; one build executes that shared product.
                selected=next(x for x in report['rows'] if x['case']==case['name'] and x['role']=='b2')
                executable=out/(case['name']+'.program'); clang=context['clang']['file']
                row=dict(case=case['name'],input=selected['outputs'][0],passed=False); report['programExecutions'].append(row)
                row['build']=guarded(case['name']+'-clang',[clang,'-isystem',str(Path(clang).parents[1]/'include/clang'),'-O2',row['input']['file'],'-o',str(executable),'-lm','-pthread'])
                row['binary']=pin(executable); row['run']=guarded(case['name']+'-execute',[str(executable),'--threads','1','--gpu','off'],20)
                stdout=Path(row['run']['guard'])/'stdout.log'; stderr=Path(row['run']['guard'])/'stderr.log'
                row.update(stdout=pin(stdout),stderr=pin(stderr),expected=case['expectedStdout'])
                assert stdout.read_text().rstrip('\n')==case['expectedStdout'],'Generated program stdout changed'
                row['passed']=True; save(out/'report.json',report)
    except BaseException as exc:
        error=exc; report['error']=f'{type(exc).__name__}: {exc}'
    try: final_inputs(); report['inputsUnchanged']=True
    except BaseException as exc: error=error or exc; report['inputVerificationError']=str(exc)
    report.update(complete=error is None,passed=error is None,elapsedSeconds=time.monotonic()-started,
                  targetJobsRun=len(report['rows'])+2*len(report['programExecutions']))
    save(out/'report.json',report)
    if error: raise error

if __name__=='__main__': main()
