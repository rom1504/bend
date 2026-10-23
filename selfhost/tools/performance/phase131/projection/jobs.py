"""Prepare per-job root guards, then seal calibrated timings from pilot evidence.

No target execution here. Run the jobs in order, without an outer guard.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
PY=str(Path(sys.executable).resolve())
BUN=str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')
CASES=('projection-string','projection-list')
DIGEST=3516497831


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path):return json.loads(Path(path).read_text())
def save(path,value):
    with Path(path).open('x') as stream:stream.write(json.dumps(value,indent=2)+'\n')
def verify(item):assert pin(item['file'])==item


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--seal',choices=['pilot','timing'])
    ap.add_argument('--candidate-api',type=Path,default=ROOT/'selfhost/build/phase111/p131-projection-api03/report.json')
    ap.add_argument('--candidate-source',type=Path,default=ROOT/'selfhost/build/phase131/projection-source03/manifest.json')
    a=ap.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase131')
    if a.seal:
        plan=read(out/'jobs.json');inputs=[pin(out/'jobs.json'),pin(__file__),pin(HERE/'cases-v02.json')]
        binaries={}
        for role in ('baseline','candidate'):
            for name in CASES:
                report_path=Path(plan['buildReports'][role][name]);r=read(report_path)
                assert r['complete'] and r['outputExact']
                for item in r['inputs']+[r['binary']]:verify(item)
                inputs += [pin(report_path),r['binary']];binaries[role,name]=r['binary']
        repeats={name:2048 for name in CASES}
        if a.seal=='timing':
            pilot=read(out/'pilot/report.json');assert pilot['complete'] and pilot['passed']
            inputs.append(pin(out/'pilot/report.json'))
            for name in CASES:
                times=[r['wallSeconds'] for r in pilot['rows'] if r['workload']==name and r['mode']=='clean' and r['correct']]
                assert len(times)==2 and min(times)>0
                repeats[name]=min(1_000_000,max(2048,math.ceil(2048*0.35/min(times))))
        def manifest(long_prefix=False):
            workloads=[]
            for name in CASES:
                count=1 if long_prefix else repeats[name];warm=0 if long_prefix else 2
                args=[str(count),str(warm),'4096' if long_prefix else '128','0']
                prefix=f'{DIGEST}\n{(DIGEST*warm)&0xffffffff}\n{(DIGEST*count)&0xffffffff}\n'
                variants=[dict(name=role,binary=binaries[role,name],
                    command=[binaries[role,name]['file'],'--threads','1','--gpu','off','--',*args],
                    expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix=prefix),
                        stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest())))
                    for role in ('baseline','candidate')]
                workloads.append(dict(name=name,timeoutSeconds=30,variants=variants))
            return dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=inputs,
                workloads=workloads,scope='Same annotated source, same runtime/aligned toolchain; independent ordinary oracle already passed. Clean child CPU/wall plus consumed timed digest. No full compiler performance claim.',
                repetitions=repeats,calibration='Pilot clean whole-child times; target at least350ms for faster variant, capped at1000000 repetitions. Report actual durations; no confidence claims.')
        save(out/(a.seal+'-manifest.json'),manifest())
        if a.seal=='pilot':save(out/'long-prefix-manifest.json',manifest(True))
        print(json.dumps(dict(complete=True,targetsRun=False,seal=a.seal,repetitions=repeats)));return
    assert not out.exists();out.mkdir(parents=True)
    baseline=ROOT/'selfhost/build/phase111/p130-mode-api01/report.json'
    baseline_source=ROOT/'selfhost/build/phase130/mode-source01/manifest.json'
    runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/report.json'
    for api,source in [(baseline,baseline_source),(a.candidate_api,a.candidate_source)]:
        r,m=read(api),read(source);assert r['complete'] and r['checked'] and m['source'] in r['inputs']
        for item in r['inputs']+[r['api']]:verify(item)
    jobs=[];reports={role:{} for role in ('baseline','candidate')};emissions={}
    def add(name,command,seconds=120,rss=3072,guard=True):
        command=list(map(str,command))
        if guard:command=[PY,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
            '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib',str(rss),
            '--available-mib','16384','--file-mib','128','--cpu','3','--',*command]
        jobs.append(dict(name=name,command=command,dependsOn=jobs[-1]['name'] if jobs else None))
    for role,api,source in [('baseline',baseline,baseline_source),('candidate',a.candidate_api,a.candidate_source)]:
        emitted=ROOT/f'selfhost/build/phase118/p131-{out.name}-{role}-emit';emissions[role]=emitted
        add(role+'-emit',['env',f'P118_CASE_MANIFEST={HERE/"cases-v02.json"}',f'P118_RUNTIME_REPORT={runtime}',
            BUN,ROOT/'selfhost/tools/performance/phase128/emit-entry.mjs',api,source,emitted,*CASES],180,4096)
        for name in CASES:
            build=ROOT/f'selfhost/build/phase111/p131-{out.name}-{role}-{name}-build';reports[role][name]=str(build/'report.json')
            add(role+'-'+name+'-build',[PY,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
                '--source',emitted/(name+'.ssa'),'--runtime',ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o',
                '--out',build,'--expected',HERE/'expected.stdout','--seconds','30'],75,2048)
    for name,owner,consumer in [('projection-string','String.cmp','String.order'),('projection-list','p131l_cmp','p131l_query')]:
        add(name+'-admission',[BUN,ROOT/'selfhost/tools/performance/phase128/diagnose-calls.mjs',a.candidate_api,
            HERE/(name+'-v02.bend'),out/(name+'-admission.json'),owner,consumer],120,4096)
        add(name+'-inspect',[PY,'-B',HERE/'inspect.py','--parent-ssa',emissions['baseline']/(name+'.ssa'),
            '--candidate-ssa',emissions['candidate']/(name+'.ssa'),'--out',out/(name+'-inspect.json'),
            '--owner',owner,'--consumer',consumer],guard=False)
    add('seal-pilot',[PY,'-B',__file__,'--out',out,'--seal','pilot'],guard=False)
    for mode,rounds in [('long-prefix',1),('pilot',1)]:
        add(mode,[PY,'-B',ROOT/'selfhost/tools/profiler/run.py','--manifest',out/(mode+'-manifest.json'),
            '--out',out/mode,'--modes','clean','--rounds',str(rounds)],150,2048)
    add('seal-timing',[PY,'-B',__file__,'--out',out,'--seal','timing'],guard=False)
    add('timing',[PY,'-B',ROOT/'selfhost/tools/profiler/run.py','--manifest',out/'timing-manifest.json',
        '--out',out/'timing','--modes','clean','--rounds','5'],240,2048)
    add('comparison',[PY,'-B',ROOT/'selfhost/tools/profiler/compare.py','--report',out/'timing/report.json',
        '--reference','baseline','--out',out/'comparison.json'],guard=False)
    inputs=[pin(__file__),pin(HERE/'cases-v02.json'),pin(HERE/'expected.stdout'),
        *map(pin,[baseline,baseline_source,a.candidate_api,a.candidate_source,runtime])]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,jobs=jobs,inputs=inputs,buildReports=reports,
        execution='Root executes each command serially, stopping at failure. Each target job has its own CPU3 process-tree guard; use NO outer guard.',
        interpretation='Inspect admission and actual hot callsites before claiming composition; correct outputs with fallback are a negative optimization result. Preserve all failed attempts.'))
    print(json.dumps(dict(complete=True,targetsRun=False,jobs=str(out/'jobs.json'),count=len(jobs))))


if __name__=='__main__':main()
