"""Prepare existing guarded tools; seal clean timing after independent builds.

This is source/manifest transport only. It never compiles or runs a target.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
CASES = ('compiler-tag', 'record-transfer')
PY = str(Path(sys.executable).resolve())
BUN = str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    with Path(path).open('x') as stream:
        stream.write(json.dumps(value, indent=2)+'\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--repetitions', type=int, default=100000)
    p.add_argument('--seal', action='store_true')
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase131')
    assert 1 <= a.repetitions <= 10_000_000
    stem = out.name
    reports = {(role,name): ROOT/f'selfhost/build/phase111/p131-{stem}-{role}-{name}-build/report.json'
               for role in ('baseline','candidate') for name in CASES}
    if a.seal:
        plan = read(out/'jobs.json'); inputs = [pin(out/'jobs.json'), pin(__file__), pin(HERE/'oracle.json')]
        assert plan['repetitions'] == a.repetitions
        workloads = []
        for name in CASES:
            variants = []
            for role in ('baseline','candidate'):
                file = reports[(role,name)]; report = read(file)
                assert report['complete'] and report['outputExact']
                for item in report['inputs']+[report['binary']]:
                    assert pin(item['file']) == item
                inputs += [pin(file), report['binary']]
                variants.append(dict(name=role,binary=report['binary'],
                    command=[report['binary']['file'],'--threads','1','--gpu','off','--',str(a.repetitions)],
                    expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',
                        prefix=f'1\n{a.repetitions % (1 << 32)}\n'),
                        stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
            workloads.append(dict(name=name,timeoutSeconds=15,variants=variants))
        save(out/'timing-manifest.json',dict(schema='bend-native-profile-workloads-v1',
            cwd=str(ROOT),inputs=inputs,workloads=workloads,
            scope='Two matched source programs; clean sequential CPU3 same-runtime aligned binaries, independent ordinary oracle passed before timing. Whole-child CPU/wall time includes startup; final stdout integer is internal milliseconds. No whole-compiler performance claim.'))
        print(json.dumps(dict(sealed=True,targetsRun=False,manifest=str(out/'timing-manifest.json'))))
        return
    assert not out.exists(); out.mkdir()
    jobs = []
    def job(name, command, seconds=90, rss=2048):
        guarded = [PY,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
            '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib',str(rss),
            '--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]
        jobs.append(dict(name=name,command=guarded,dependsOn=jobs[-1]['name'] if jobs else None))
    candidate = ROOT/'selfhost/build/phase111/p131-regions-api02/report.json'
    baseline = ROOT/'selfhost/build/phase111/p130-mode-api01/report.json'
    runtime = ROOT/'selfhost/build/phase128/runtime-borrow01/report.json'
    candidate_source = ROOT/'selfhost/build/phase131/regions-source02/manifest.json'
    baseline_source = ROOT/'selfhost/build/phase130/mode-source01/manifest.json'
    job('finite',[BUN,HERE/'finite.mjs',candidate,out/'finite',
        '{"p131rg_controls":13,"p128bl_controls":7,"p128br_call_controls":10}'],60)
    for role,api,source in [('baseline',baseline,baseline_source),('candidate',candidate,candidate_source)]:
        emitted = ROOT/f'selfhost/build/phase118/p131-{stem}-{role}-emit'
        job(role+'-emit',['env',f'P118_CASE_MANIFEST={HERE / "cases.json"}',
            f'P118_RUNTIME_REPORT={runtime}',BUN,
            ROOT/'selfhost/tools/performance/phase128/emit-entry.mjs',api,source,emitted,*CASES],120,3072)
        for name in CASES:
            job(role+'-'+name+'-build',[PY,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
                '--source',emitted/(name+'.ssa'),'--runtime',ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o',
                '--out',reports[(role,name)].parent,'--expected',HERE/'expected.stdout','--seconds','30'],75)
    job('admission',[BUN,ROOT/'selfhost/tools/performance/phase128/diagnose-calls.mjs',candidate,
        HERE/'compiler-tag.bend',out/'admission.json','p98_tag_eq','p98_tag_eq_read',
        'p131_packet_query','p131_packet_read','p131_opaque_count','p131_opaque_escape'],90,3072)
    jobs.append(dict(name='seal',command=[PY,'-B',str(Path(__file__).resolve()),'--out',str(out),
        '--repetitions',str(a.repetitions),'--seal'],dependsOn='admission',targetsRun=False))
    job('timing',[PY,'-B',ROOT/'selfhost/tools/profiler/run.py','--manifest',out/'timing-manifest.json',
        '--out',out/'timing','--modes','clean','--rounds','3'],190)
    inputs=[pin(__file__),pin(HERE/'cases.json'),pin(HERE/'oracle.json'),pin(HERE/'expected.stdout'),
        *[pin(x) for x in (candidate,baseline,candidate_source,baseline_source,runtime)]]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,repetitions=a.repetitions,
        inputs=inputs,jobs=jobs,execution='Root serial CPU3 lane; execute in order, stop after any failure. No automatic execution by preparer.',
        requiredReview='After admission inspect positive selected readers and opaque negatives; fallback-only correctness is not success. If clean medians are below100ms, use a fresh plan with more repetitions before performance claims.'))
    print(json.dumps(dict(complete=True,targetsRun=False,jobs=str(out/'jobs.json'))))


if __name__ == '__main__': main()
