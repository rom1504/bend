#!/usr/bin/env python3
"""Guarded saved-C experiments against exact compiler23/upstream acquisitions."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('survey', ROOT/'selfhost/tools/performance/phase68/parity-survey/run.py')
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
S = R.S


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--case', choices=['numeric','array','closures','tree','map','lexer'], required=True)
    p.add_argument('--variant', action='append', required=True, help='unique label=derived-C-path')
    p.add_argument('--evidence', type=Path, action='append', required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=0, help='Default: one rotation per role')
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase69') and not out.exists()
    products, pins = R.products()
    recipe = products[(a.case,'selfhost')]['recipe']
    assert {k:os.environ.get(k) for k in recipe['compilerEnvironment']} == recipe['compilerEnvironment']
    sources = {}
    for v in a.variant:
        label, path = v.split('=',1)
        assert label not in ('selfhost','upstream') and label not in sources
        assert label and all(c.isalnum() or c in '-_' for c in label)
        sources[label] = S.identity(Path(path))
    pins += [S.identity(__file__), *sources.values(), *[S.identity(p) for p in a.evidence]]
    roles = ['selfhost', *sources, 'upstream']
    rounds = a.rounds or len(roles)
    assert rounds >= 3
    count = dict(numeric=77504,array=61440,closures=57888,tree=1280,map=1152,lexer=448)[a.case]
    warm = count//8//16*16
    R.verify(pins)
    out.mkdir(parents=True)
    S.save(out/'plan.json',dict(case=a.case,inputs=pins,roles=roles,rounds=rounds,repetitions=count,warmups=warm,
        scope='Saved-C causality experiment only, not a compiler implementation or general conformance claim.'))
    result = dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),builds=[],controls=[],records=[])
    executables = {role:products[(a.case,role)]['executable'] for role in ('selfhost','upstream')}
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(command,dest,seconds=60):
                return guard.run(['taskset','-c','3',*map(str,command)],dest,time.monotonic()+seconds)
            for label, source in sources.items():
                dest = out/label
                dest.mkdir()
                exe = dest/'program'
                build = run([recipe['clang'],*recipe['clangArgs'],source['path'],*recipe['linkArgs'],'-o',exe],dest/'build',120)
                result['builds'].append(dict(role=label,source=source,process=build))
                S.save(out/'report.json',result)
                assert build['complete'], label
                executables[label] = S.identity(exe)
                for threads,n in ((1,1),(1,17),(4,17)):
                    d = dest/f'control-{threads}-{n}'
                    process = run([exe,'--threads',threads,'--gpu','off','--',n,0],d)
                    obs = R.observed(d,process,a.case,n)
                    obs['correct'] = obs['correct'] and not (d/'stderr.log').read_text()
                    result['controls'].append(dict(role=label,threads=threads,repetitions=n,process=process,**obs))
                    S.save(out/'report.json',result)
                    assert obs['correct'], (label,threads,n)
            for rnd in range(rounds):
                shift = rnd % len(roles)
                for role in roles[shift:]+roles[:shift]:
                    dest = out/f'round-{rnd}-{role}'
                    exe = executables[role]
                    assert S.identity(exe['path']) == exe
                    process = run([exe['path'],'--threads',1,'--gpu','off','--',count,warm],dest)
                    obs = R.observed(dest,process,a.case,count,warm)
                    correct = obs['correct'] and not (dest/'stderr.log').read_text()
                    ms = int(obs['stdout'][3]) if correct else None
                    row = dict(role=role,round=rnd,executable=exe,process=process,**obs,elapsedMs=ms)
                    row['qualified'] = bool(correct and 100 <= ms <= process['wallSeconds']*1000+2)
                    result['records'].append(row)
                    S.save(out/'report.json',result)
                    assert row['qualified'], (role,rnd)
            result['mediansMs'] = {role:statistics.median(r['elapsedMs'] for r in result['records'] if r['role']==role) for role in roles}
        R.verify(pins)
        result['complete'] = True
    except BaseException as e:
        result['error'] = repr(e)
        raise
    finally:
        result['finished'] = time.time()
        S.save(out/'report.json',result)
    print(json.dumps(dict(case=a.case,mediansMs=result['mediansMs'])))


if __name__ == '__main__':
    main()
