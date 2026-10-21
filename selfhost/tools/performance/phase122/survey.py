"""Profile authenticated existing products; all compiler implementations stay unchanged."""
import argparse, importlib.util, math, os, statistics, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT/'selfhost/build/phase122'
def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT/path)
    mod = importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)
    return mod
S = module('survey116', 'selfhost/tools/performance/phase116/survey-v2.py')
O = module('oracle112', 'selfhost/tools/performance/phase112/benchmark45/run.py')
NAMES = ['test-rle-roundtrip', 'test-evening-program', 'tree-bitonic', 'lexer',
         'coverage-map-churn-128', 'coverage-bst-64', 'coverage-record-aggregation-256',
         'variation-ray-active-256-2240', 'scalar-region-8192', 'editdist']
SAMPLER = ROOT/'selfhost/build/phase108/profiler01/sampler.so'

def freeze():
    BASE.mkdir(exist_ok=True)
    out = BASE/'manifest01.json'; assert not out.exists()
    files = ['implementation/phase121/candidate.json',
             'selfhost/build/phase121/broad-screen04/report.json',
             'selfhost/build/phase118/p121-broad-emit04/report.json',
             'selfhost/tools/performance/phase112/benchmark45/manifest01.json',
             'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json',
             'selfhost/build/phase99/phase102-runtime-products04/report.json']
    candidate, screen, emission, original, counts, mature = [S.read(ROOT/p) for p in files]
    assert all(x['complete'] for x in [candidate, screen, emission, mature])
    assert candidate['source'] == emission['source'] and candidate['runtime'] == emission['runtime']
    inputs = [S.pin(ROOT/p) for p in files] + [S.pin(__file__), S.pin(S.__file__), S.pin(O.__file__),
              S.pin(S.A.__file__), S.pin(SAMPLER), candidate['source'], candidate['api'], candidate['runtime']]
    cases = []
    for name in NAMES:
        c = next(x for x in original['cases'] if x['name']==name)
        e = next(x for x in emission['cases'] if x['name']==name)
        m = next(x for x in mature['cases'] if x['id']==name)
        assert e['verified'] and m['passed'] and c['source'] == e['source'] == m['source']
        product = next(x['binary'] for x in screen['rows'] if x['name']==name and x['role']=='candidate')
        build = next(x['report'] for x in screen['builds'] if x['name']==name)
        S.verify(build); br = S.read(build['file']); assert br['complete'] and br['binary']==product
        inputs += [build, *br['inputs']]
        products = dict(qbe=product, upstream_c=c['upstream']['binary'], selfhost_c=m['products']['own']['binary'])
        generated = dict(qbe=e['qbe'], upstream_c=c['upstream']['generatedC'], selfhost_c=m['products']['own']['c'])
        for item in [c['source'], c['expectedStdoutEvidence'], *products.values(), *generated.values()]: S.verify(item)
        cases.append(dict(name=name, family=c['family'], source=c['source'], expected=c['expectedStdout'],
                          args=c['runtimeArgs'], counts=counts['cases'][name], products=products,
                          generated=generated, oracle=c))
    unique = {x['file']:x for x in inputs}
    for item in unique.values(): S.verify(item)
    S.save(out, dict(complete=True, head='920d69170d8e34c335381d78bb9129e019e1f9aa', inputs=list(unique.values()), cases=cases,
       scope='Current QBE121, mature selfhost C102 and pinned upstream C; identical sources/arguments/oracles, differing compiler vintages and toolchains.'))
    print(str(out))

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['freeze','clean','profile'])
    p.add_argument('--out', type=Path)
    p.add_argument('--clean', type=Path)
    p.add_argument('--names', nargs='+')
    a = p.parse_args()
    if a.mode=='freeze': freeze(); return
    assert sorted(os.sched_getaffinity(0)) == [3]
    out = a.out.resolve(); assert not out.exists() and out.is_relative_to(BASE); out.mkdir()
    manifest = BASE/'manifest01.json'; m = S.read(manifest)
    selected = [c for c in m['cases'] if not a.names or c['name'] in a.names]
    if a.names: assert len(selected)==len(a.names)
    for item in m['inputs']: S.verify(item)
    for c in selected:
        for item in [c['source'], *c['products'].values()]: S.verify(item)
    clean = S.read(a.clean) if a.mode=='profile' else None
    if clean: assert clean['complete'] and clean['mode']=='clean' and clean['inputs'][0]==S.pin(manifest)
    r = dict(complete=False, mode=a.mode, inputs=[S.pin(manifest), S.pin(__file__)]+([S.pin(a.clean)] if clean else []),
             rows=[], started=time.time(), scope='Clean runtime and physical-PC samples kept separate; no inclusive-stack or allocation-count inference.')
    save = lambda: S.save(out/'report.json',r)
    save()
    for ci,c in enumerate(selected):
        roles = ['qbe','upstream_c','selfhost_c']
        for index,period in enumerate([8000,13000] if clean else [0,0,0]):
            shift = (ci+index)%len(roles)
            for role in roles[shift:]+roles[:shift]:
                reps = c['counts']['repetitions']*4
                if clean:
                    median = statistics.median(x['elapsedMs'] for x in clean['rows'] if x['case']==c['name'] and x['role']==role)
                    reps = max(1,math.ceil(reps*5500/median))
                assert 0 < reps < 2**31
                warm = 32; product=c['products'][role]; stem=c['name']+'-'+role+'-'+str(index)
                cmd=S.command(role,product,c,reps,warm,None); env=dict(os.environ); sample=out/(stem+'.samples')
                if clean: env.update(LD_PRELOAD=str(SAMPLER), BEND_SAMPLE_OUT=str(sample), BEND_SAMPLE_PERIOD_US=str(period))
                t=time.monotonic(); child=subprocess.run(cmd,capture_output=True,env=env,cwd=ROOT,timeout=35); wall=time.monotonic()-t
                (out/(stem+'.stdout')).write_bytes(child.stdout); (out/(stem+'.stderr')).write_bytes(child.stderr)
                row=dict(case=c['name'],role=role,round=index,periodUs=period,product=product,command=cmd,repetitions=reps,
                         warmups=warm,status=child.returncode,wallSeconds=wall,stdout=S.pin(out/(stem+'.stdout')),stderr=S.pin(out/(stem+'.stderr')))
                r['rows'].append(row); save()
                row.update(elapsedMs=O.observation(child.stdout,child.stderr,child.returncode,
                           dict(c['oracle'],repetitions=reps,warmups=warm),wall),correct=True)
                if clean:
                    analysis=S.analyze(sample,product['file']); dest=out/(stem+'.analysis.json'); S.save(dest,analysis)
                    row.update(profile=S.pin(sample),analysis=S.pin(dest),samples=analysis['header']['samples'],
                               usable=analysis['usable'],overruns=analysis['header']['overruns'],dropped=analysis['header']['dropped'])
                save(); print(stem,row['elapsedMs'],row.get('samples'),flush=True)
    for item in m['inputs']: S.verify(item)
    for c in selected:
        for product in c['products'].values(): S.verify(product)
    r.update(complete=True,seconds=time.time()-r['started']);save()

if __name__=='__main__':main()
