"""Relink qualified Phase143 objects against two pinned runtimes; no emission.

prepare is metadata-only. run requires the root-owned CPU3 process-tree guard.
These are semantic observations, deliberately not kernel timing measurements.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase144'
SELF = Path(__file__).resolve()
SAFETY = ['nt-reverse', 'string-reverse-heldout', 'higher-order-capture',
          'non-tail-list', 'arrays-io', 'pure-aggregate']
ENV = {'PATH': '/usr/bin:/bin', 'LANG': 'C', 'LC_ALL': 'C', 'TZ': 'UTC'}

def require(ok, why):
    if not ok: raise RuntimeError(why)

def pin(path):
    path = Path(path).absolute()
    data = path.read_bytes()
    return dict(file=str(path), canonicalPath=str(path.resolve()), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())

def verify(item):
    actual = pin(item['file'])
    require(all(actual[k] == item[k] for k in ['bytes', 'sha256']), 'Input changed: '+item['file'])
    require('canonicalPath' not in item or actual['canonicalPath'] == item['canonicalPath'], 'Realpath changed')
    return Path(actual['canonicalPath'])

def same(a, b):
    return (a['sha256'], a['bytes'], Path(a['file']).resolve()) == (b['sha256'], b['bytes'], Path(b['file']).resolve())

def read(path): return json.loads(Path(path).read_text())
def save(path, value): Path(path).write_text(json.dumps(value, indent=2)+'\n')
def arg(command, name): return command[command.index(name)+1]

def prepare(out):
    require(not out.exists() and out.resolve().is_relative_to(RAW), 'Fresh phase144 output required')
    inputs = {}
    def keep(item):
        p = verify(item) if isinstance(item, dict) else Path(item)
        identity = pin(p); inputs[identity['file']] = identity
        return identity
    qpin = keep(ROOT/'implementation/phase143/qualification.json'); q = read(qpin['file'])
    require(q['complete'] and q['nativeQualified'], 'Phase143 not qualified')
    keep(q['source']); image = keep(q['n2'])
    old_receipt = keep(ROOT/'selfhost/build/phase128/runtime-borrow01/report.json')
    old = read(old_receipt['file']); require(old['complete'] and old['status'] == 0, 'Parent runtime incomplete')
    old_runtime = keep(old['object']); keep(old['source'])
    build_pin = keep(RAW/'serial-rfc01/build.json'); built = read(build_pin['file'])
    require(built['complete'] and len(built['jobs']) == 4 and all(j['exitCode'] == 0 for j in built['jobs']), 'Runtime build incomplete')
    for item in built['inputs']: keep(item)
    manifest_pin = next(i for i in built['inputs'] if i['file'].endswith('/serial-rfc01/manifest.json'))
    manifest = read(verify(manifest_pin))
    require(manifest['complete'] and [j['command'] for j in built['jobs']] == [j['argv'] for j in manifest['commands']], 'Runtime recipe differs')
    for item in manifest['outputs']: keep(item)
    new_runtime = keep(built['variants']['serial-rfc']['object'])
    cc = keep('/usr/bin/x86_64-linux-gnu-gcc-10')
    require(any(same(cc, i) for i in built['inputs']), 'Linker driver not admitted')
    keep(Path('/usr/bin/ld').resolve())
    cases = []; inherited = []; cost = {}
    for suite, count in [('focused19',19), ('full45',45)]:
        suite_pin = keep(ROOT/f'selfhost/build/phase111/p143-n2-{suite}/report.json')
        require(any(same(suite_pin, i) for i in q['inputs']), 'Suite not in qualification')
        report = read(suite_pin['file'])
        require(report['complete'] and report['passed'] and len(report['rows']) == count, 'Suite incomplete')
        require([j['name'] for j in report['jobs']] == report['names'] == [r['name'] for r in report['rows']], 'Suite order differs')
        cost[suite] = dict(executionSeconds=sum(r.get('executionSeconds',0) for r in report['rows']),
                           maximumSeconds=max(r.get('executionSeconds',0) for r in report['rows']),
                           wholeAcquisitionSeconds=report['seconds'])
        for row, job in zip(report['rows'], report['jobs']):
            source = keep(arg(job['command'],'--source'))
            require(any(same(source, i) for i in report['inputs']), 'Source missing from suite')
            if row['expectedRefusal']:
                require(row['status'] == 'source-refused' and job['exitCode'] == 1 and not row['built'] and not row['executed'], 'Unexpected refusal artifact')
                keep(row['emission'])
                inherited.append(dict(name=row['name'], source=source, historicalExpected=row['expected'],
                                      suite=suite_pin, scope='Compiler-stage refusal has no object; not rerun or newly qualified by runtime relinking.'))
                continue
            require(row['status'] == 'passed' and job['exitCode'] == 0, 'Historical case failed')
            require(row['semanticPass'] and row['compiled'] and row['built'] and row['executed'], 'Case not qualified')
            ep = keep(row['emission']); emission = read(ep['file'])
            bp = keep(row['build']); build = read(bp['file'])
            require(emission['complete'] and same(emission['image'], image) and same(emission['buildReport'], bp), 'Emission identity differs')
            require(all(emission['gates'][k] == 'passed' for k in ['emission','comparison','build','semantics']), 'Emission gate failed')
            require(build['complete'] and build['outputExact'] and not build['perProgramC'] and not build['cproc'], 'Object build not qualified')
            product = keep(row['product']); obj = keep(build['object']); binary = keep(row['binary'])
            expected = keep(arg(job['command'], '--expected')); observation = keep(row['observation'])
            require(same(product, emission['product']) and same(binary, build['binary']), 'Product joins differ')
            require(all(any(same(x,i) for i in build['inputs']) for x in [product,expected,old_runtime]), 'Build source/oracle/runtime differs')
            require(all(any(same(x,i) for i in emission['inputs']) for x in [source,expected,old_runtime]), 'Emission input joins differ')
            require(verify(expected).read_bytes() == row['expected']['stdout'].encode() == verify(observation).read_bytes(), 'Independent oracle differs')
            require(row['expected']['exitCode'] == 0 and row['expected']['stderr'] == '', 'Unexpected ordinary oracle')
            links = [j for j in build['jobs'] if j['label'] == 'link']; runs = [j for j in build['jobs'] if j['label'] == 'execute']
            require(len(links) == len(runs) == 1, 'Ambiguous old commands')
            link = links[0]['command']; run = runs[0]
            require(Path(link[0]).resolve() == Path(cc['canonicalPath']) and link[1:] == ['-no-pie',obj['file'],old_runtime['file'],'-pthread','-lm','-o',binary['file']], 'Old linker policy differs')
            require(run['command'] == [binary['file'],'--threads','1','--gpu','off'] and run['exitCode'] == 0, 'Old execution policy differs')
            keep(run['stderr']); require(verify(run['stderr']).read_bytes() == b'', 'Old stderr not empty')
            cases.append(dict(id=suite+'-'+row['name'], name=row['name'], suite=suite, source=source,
                object=obj, qbe=product, expectedStdout=expected, emission=ep, build=bp,
                previousExecutionSeconds=row['executionSeconds'], safety=suite=='focused19' and row['name'] in SAFETY))
    require(len(cases) == 61 and len(inherited) == 3 and sum(c['safety'] for c in cases) == 6, 'Wrong case coverage')
    keep(SELF)
    result = dict(kind='phase144-relink-plan-v01', complete=True, preparedOnly=True, targetsRun=False,
        qualification=qpin, runtimeBuild=build_pin, compilerImage=image, compilerSource=q['source'],
        runtimes=dict(atomic=old_runtime, serial=new_runtime), cc=cc, cases=cases, inheritedCompilerRefusals=inherited,
        priorCosts=cost, inputs=list(inputs.values()), method=pin(SELF), environment=ENV,
        executionArgs=['--threads','1','--gpu','off'], cpu=3, childDeadlineSeconds=10,
        scope='Relink only61 existing qualified objects. Six safety cases first, then remaining55. No source emission; no fresh claim for three compiler-stage refusals. Process observations are correctness costs, not kernel timings.')
    out.mkdir(); save(out/'plan.json', result); print(json.dumps(dict(plan=pin(out/'plan.json'), cases=61, safety=6, priorCosts=cost)))

def run(plan_path, out, group, prior):
    plan_pin=pin(plan_path); plan=read(plan_path)
    require(plan['complete'] and same(plan['method'],pin(SELF)), 'Plan or method changed')
    require(os.sched_getaffinity(0) == {3}, 'Root CPU3 guard required')
    require(not out.exists() and out.resolve().is_relative_to(RAW), 'Fresh phase144 output required')
    for item in plan['inputs']: verify(item)
    out.mkdir(); started=time.monotonic()
    result=dict(kind='phase144-relink-semantics-v01', complete=False, passed=False, group=group,
        plan=plan_pin, method=pin(SELF), inputs=plan['inputs'], environment=ENV,
        affinity=sorted(os.sched_getaffinity(0)), jobs=[], cases=[], refusals=[], inheritedCompilerRefusals=plan['inheritedCompilerRefusals'],
        timingScope='Whole child wall costs only; no kernel performance estimates or compiler throughput.', startedEpoch=time.time())
    def child(label, command, expected, exitcode=0, stderr=b''):
        before=time.monotonic(); epoch=time.time(); timedout=False
        process=subprocess.Popen(command, cwd=ROOT, env=ENV, stdin=subprocess.DEVNULL,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
        try: stdout, errors=process.communicate(timeout=plan['childDeadlineSeconds'])
        except subprocess.TimeoutExpired:
            timedout=True; os.killpg(process.pid,signal.SIGKILL); stdout,errors=process.communicate()
        elapsed=time.monotonic()-before
        prefix=out/str(len(result['jobs'])); so=prefix.with_suffix('.stdout'); se=prefix.with_suffix('.stderr')
        so.write_bytes(stdout); se.write_bytes(errors)
        ok=not timedout and process.returncode==exitcode and stdout==expected and errors==stderr
        job=dict(label=label, command=command, exitCode=process.returncode, expectedExitCode=exitcode,
            seconds=elapsed, startedEpoch=epoch, finishedEpoch=time.time(), timedOut=timedout,
            stdout=pin(so),stderr=pin(se),passed=ok)
        result['jobs'].append(job); save(out/'report.json',result)
        require(ok,'Child/oracle failed: '+label)
        return job
    try:
        if group=='full':
            require(prior is not None,'Safety receipt required')
            prior_pin=pin(prior); previous=read(prior)
            require(previous['complete'] and previous['passed'] and previous['group']=='safety' and same(previous['plan'],plan_pin),'Safety prerequisite differs')
            require([x['id'] for x in previous['cases']] == [c['id'] for c in plan['cases'] if c['safety']], 'Safety set differs')
            for c in previous['cases']:
                for role in ['atomic','serial']: verify(c['images'][role])
            result['safetyReceipt']=prior_pin; result['cases']=previous['cases']; result['refusals']=previous['refusals']
        else: require(prior is None,'Unexpected safety prerequisite')
        for case in plan['cases']:
            if case['safety'] != (group=='safety'): continue
            directory=out/case['id']; directory.mkdir(); images={}
            expected=verify(case['expectedStdout']).read_bytes()
            for role in ['atomic','serial']:
                binary=directory/role
                command=[plan['cc']['canonicalPath'],'-no-pie',case['object']['file'],plan['runtimes'][role]['file'],'-pthread','-lm','-o',str(binary)]
                child(case['id']+'-'+role+'-link',command,b'')
                images[role]=pin(binary)
                child(case['id']+'-'+role+'-execute',[str(binary)]+plan['executionArgs'],expected)
            result['cases'].append(dict(id=case['id'],name=case['name'],suite=case['suite'], object=case['object'], images=images, expected=case['expectedStdout'], passed=True))
        if group=='safety':
            binary=result['cases'][0]['images']['serial']['file']
            for flags in [['--threads','2'],['--gpu','on'],['--gpu','4GB']]:
                job=child('CLI-refusal-'+'-'.join(flags),[binary]+flags,b'',1,b'bend: Phase111 ABI v1 requires --threads 1 --gpu off\n')
                result['refusals'].append(job)
        require(len(result['cases']) == (6 if group=='safety' else 61) and len(result['refusals'])==3,'Incomplete selected coverage')
        for item in plan['inputs']: verify(item)
        result['complete']=result['passed']=True
    except Exception as error:
        result['error']=str(error); raise
    finally:
        result['seconds']=time.monotonic()-started; result['finishedEpoch']=time.time()
        save(out/'report.json',result)
    print(json.dumps(dict(report=pin(out/'report.json'),complete=True,cases=len(result['cases']),seconds=result['seconds'])))

if __name__=='__main__':
    parser=argparse.ArgumentParser(); sub=parser.add_subparsers(dest='mode',required=True)
    p=sub.add_parser('prepare'); p.add_argument('--out',type=Path,required=True)
    p=sub.add_parser('run'); p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--group',choices=['safety','full'],required=True);p.add_argument('--prior',type=Path)
    a=parser.parse_args()
    if a.mode=='prepare':prepare(a.out.absolute())
    else:run(a.plan.absolute(),a.out.absolute(),a.group,a.prior)
