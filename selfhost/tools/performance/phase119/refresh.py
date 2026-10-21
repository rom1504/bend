"""Authenticated frozen-product profile refresh; no compiler implementation work."""
import argparse, collections, importlib.util, math, os, statistics, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'selfhost/build/phase119'
def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    mod = importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)
    return mod
S = module('survey116', 'selfhost/tools/performance/phase116/survey-v2.py')
O = module('oracle112', 'selfhost/tools/performance/phase112/benchmark45/run.py')
NAMES = ['scalar-region-8192', 'variation-ray-active-256-2240', 'lexer',
         'tree-bitonic', 'coverage-list-pipeline-128', 'coverage-map-churn-128']
SAMPLER = ROOT / 'selfhost/build/phase108/profiler01/sampler.so'

def freeze():
    BASE.mkdir(exist_ok=True)
    out = BASE / 'manifest01.json'; assert not out.exists()
    paths = ['implementation/phase118/selection.json',
             'selfhost/build/phase116/manifest01.json',
             'selfhost/build/phase118/broad-screen01/report.json',
             'selfhost/build/phase118/broad-emit01/report.json',
             'selfhost/build/phase118/safe-broad-emit04/report.json',
             'selfhost/tools/performance/phase112/benchmark45/manifest01.json',
             'selfhost/build/phase111/p114-native-final02-n1-focused/5-native/report.json',
             'selfhost/build/phase111/p118-native-safe03-n1-focused/5-native/report.json']
    selection, old, screen, emission, bridge, original, prior, current = [S.read(ROOT/p) for p in paths]
    for report in [old, screen, emission, bridge, prior, current]:
        assert report['complete']
    for key in ['broad', 'sourceBridge45', 'n1', 'runtime', 'source']:
        S.verify(selection[key])
    inputs = [S.pin(ROOT/p) for p in paths] + [S.pin(__file__), S.pin(S.__file__), S.pin(O.__file__), S.pin(S.A.__file__), S.pin(SAMPLER)]
    cases = []
    for name in NAMES:
        c = next(x for x in old['cases'] if x['name'] == name)
        e = next(x for x in emission['cases'] if x['name'] == name)
        b = next(x for x in bridge['cases'] if x['name'] == name)
        o = next(x for x in original['cases'] if x['name'] == name)
        assert c['source'] == e['source'] == b['source'] == o['source']
        assert e['qbe']['sha256'] == b['qbe']['sha256'] and b['exactDiagnosticMatch'] == e['qbe']
        product = next(x['binary'] for x in screen['rows'] if x['name'] == name and x['role'] == 'candidate')
        build = next(x['report'] for x in screen['builds'] if x['name'] == name)
        S.verify(build)
        br = S.read(build['file']); assert br['complete']
        inputs += [build] + br['inputs']
        products = dict(c['products'], qbe=product)
        generated = dict(c['generated'], qbe=e['qbe'])
        for pin in [c['source'], b['qbe'], *products.values(), *generated.values()]: S.verify(pin)
        cases.append(dict(name=name, source=c['source'], expected=c['expected'], args=c['args'],
                          counts=c['counts'], products=products, generated=generated, oracle=o))
    compilers = []
    for label, receipt in [('phase114', prior), ('phase118', current)]:
        job = receipt['jobs'][0]; assert job['label'] == 'native-request'
        for pin in receipt['inputs']: S.verify(pin)
        S.verify(job['stdout'])
        inputs += receipt['inputs']
        compilers.append(dict(role=label, command=job['command'], oracle=job['stdout'], image=receipt['image']))
    assert compilers[0]['command'][1:] == compilers[1]['command'][1:]
    unique = {x['file']: x for x in inputs}
    for pin in unique.values(): S.verify(pin)
    S.save(out, dict(complete=True, head='6315f14182d887d4a7365b3977817cb995807505',
                    inputs=list(unique.values()), cases=cases, compilers=compilers,
                    scope='Historical mature C102/upstream C and current QBE118; exact source/output bridge, differing producer histories. No compiler mutation.'))
    print(out, flush=True)

def main():
    p = argparse.ArgumentParser(); p.add_argument('mode', choices=['freeze','clean','native','compiler'])
    p.add_argument('--out', type=Path); a = p.parse_args()
    if a.mode == 'freeze': freeze(); return
    assert sorted(os.sched_getaffinity(0)) == [3]
    out = a.out.resolve(); assert out.is_relative_to(BASE) and not out.exists(); out.mkdir()
    manifest = BASE/'manifest01.json'; m = S.read(manifest)
    for pin in m['inputs']: S.verify(pin)
    for c in m['cases']:
        for pin in [c['source'], *c['products'].values()]: S.verify(pin)
    report = dict(complete=False, mode=a.mode, inputs=[S.pin(manifest), S.pin(__file__)], rows=[], started=time.time(),
                  scope='Clean clocks separate from physical-PC sampling; no inclusive stack or allocation-count claims.')
    save = lambda: S.save(out/'report.json', report)
    save()
    if a.mode == 'compiler':
        # Two clean observations and four sampled observations per unchanged image.
        for i, period in enumerate([0, 8000, 13000, 8000, 13000, 0]):
            order = m['compilers'][i%2:] + m['compilers'][:i%2]
            for c in order:
                stem = c['role']+'-'+str(i); cmd = c['command']; env = dict(os.environ); sample = out/(stem+'.samples')
                if period: env.update(LD_PRELOAD=str(SAMPLER), BEND_SAMPLE_OUT=str(sample), BEND_SAMPLE_PERIOD_US=str(period))
                t = time.monotonic(); r = subprocess.run(cmd, capture_output=True, env=env, cwd=ROOT, timeout=30); wall=time.monotonic()-t
                (out/(stem+'.stdout')).write_bytes(r.stdout); (out/(stem+'.stderr')).write_bytes(r.stderr)
                row = dict(case='compiler-lexer-scan', role=c['role'], round=i, periodUs=period, command=cmd,
                           product=c['image'], seconds=wall, status=r.returncode,
                           correct=r.returncode==0 and not r.stderr and r.stdout==Path(c['oracle']['file']).read_bytes(),
                           stdout=S.pin(out/(stem+'.stdout')), stderr=S.pin(out/(stem+'.stderr')))
                report['rows'].append(row); save(); assert row['correct']
                if period: attach_profile(row, sample, cmd[0], out/stem)
                save(); print(stem, round(wall,3), row.get('samples'), flush=True)
    else:
        clean = S.read(BASE/'clean01/report.json') if a.mode=='native' else None
        for ci,c in enumerate(m['cases']):
            roles = ['upstream_c','selfhost_c','qbe']
            for rnd in ([8000,13000] if clean else range(3)):
                shift = (ci+rnd)%3
                for role in roles[shift:]+roles[:shift]:
                    reps = c['counts']['repetitions']*4
                    if clean:
                        median = statistics.median(x['elapsedMs'] for x in clean['rows'] if x['case']==c['name'] and x['role']==role)
                        reps = max(1, math.ceil(reps*7000/median))
                    assert reps < 2**31
                    one = dict(c['oracle'], repetitions=reps, warmups=32)
                    product = c['products'][role]; stem = c['name']+'-'+role+'-'+str(rnd)
                    cmd = S.command(role, product, c, reps, 32, None)
                    env = dict(os.environ); sample = out/(stem+'.samples')
                    if clean: env.update(LD_PRELOAD=str(SAMPLER), BEND_SAMPLE_OUT=str(sample), BEND_SAMPLE_PERIOD_US=str(rnd))
                    t=time.monotonic(); r=subprocess.run(cmd,capture_output=True,env=env,cwd=ROOT,timeout=35); wall=time.monotonic()-t
                    (out/(stem+'.stdout')).write_bytes(r.stdout); (out/(stem+'.stderr')).write_bytes(r.stderr)
                    row=dict(case=c['name'],role=role,round=rnd,command=cmd,product=product,repetitions=reps,warmups=32,
                             status=r.returncode,wallSeconds=wall,stdout=S.pin(out/(stem+'.stdout')),stderr=S.pin(out/(stem+'.stderr')))
                    report['rows'].append(row); save()
                    row['elapsedMs']=O.observation(r.stdout,r.stderr,r.returncode,one,wall);row['correct']=True
                    if clean: attach_profile(row,sample,product['file'],out/stem)
                    save();print(stem,row['elapsedMs'],row.get('samples'),flush=True)
    for pin in m['inputs']: S.verify(pin)
    for c in m['cases']:
        for pin in c['products'].values(): S.verify(pin)
    report.update(complete=True, seconds=time.time()-report['started']);save()

def attach_profile(row, sample, binary, stem):
    analysis=S.analyze(sample,binary); path=Path(str(stem)+'.analysis.json'); S.save(path,analysis)
    row.update(profile=S.pin(sample),analysis=S.pin(path),samples=analysis['header']['samples'],
               overruns=analysis['header']['overruns'],dropped=analysis['header']['dropped'],
               usable=analysis['usable'],coverage=analysis['coverage'])

if __name__=='__main__': main()
