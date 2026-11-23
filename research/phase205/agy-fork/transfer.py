"""Check every combined product. Retime exactly those that differ from the runtime-only run."""
import itertools
import json
from pathlib import Path
import resource
import sys

from trial import S, HERE

def main(out, checked_trial, rt_trial):
    out.mkdir(parents=True)
    soft,hard = resource.getrlimit(resource.RLIMIT_STACK)
    resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024 if hard < 0 else min(64*1024*1024,hard),hard))
    history = S.read(rt_trial/'results.json')
    rows = {r['id']:r for r in history['cases']}
    cases = {c['id']:c for c in S.read(S.BROAD/'timing/report.json')['cases']}
    recipes = {c['id']:c for c in S.read(S.BROAD/'recipe.json')['cases']}
    runtime = rt_trial/'runtime-opt.o'
    assert S.digest(runtime) == history['candidateRuntime']
    done = []
    ids = list(rows)
    for offset in range(0,len(ids),6):
        group = ids[offset:offset+6]
        jobs = []
        for name in group:
            original = S.read(S.BROAD/f'cases/{name}/candidate/build.json')
            jobs.append(dict(input=original['source'],out=str(out/(name+'.o'))))
        jobfile = out/f'group-{offset}.json'
        jobfile.write_text(json.dumps(jobs))
        S.execute(['/home/ai/.nvm/versions/node/v24.22.1/bin/node','--stack_size=32768',HERE/'batch.mjs',
                   checked_trial/'api/report.json',jobfile])
        for name in group:
            obj = out/(name+'.o')
            old = rows[name]
            same = S.digest(obj) == old['object']
            exe = rt_trial/name if same else out/name
            if same:
                assert S.digest(exe) == old['elf']['port']
            else:
                S.execute([S.CC,*S.FLAGS,obj,runtime,*S.LIBS,'-o',exe])
            point = cases[name]['point']
            S.timed(exe,1,point)
            row = dict(id=name,object=S.digest(obj),unchanged=same,elf=S.digest(exe))
            if not same and point['ratioEligible']:
                paths = dict(parent=S.checked(S.read(S.BROAD/f'cases/{name}/candidate/build.json')['binary']),
                             port=exe,c=S.checked(recipes[name]['products']['c']['artifact']))
                runs = {k:[] for k in paths}
                for order in itertools.permutations(paths):
                    for k in order:
                        runs[k].append(S.timed(paths[k],old['reps'][k],point))
                row['runsMs'] = runs
            done.append(row)
            (out/'transfer.json').write_text(json.dumps(done,indent=2)+'\n')
            print(name,'identical' if same else 'changed',flush=True)

if __name__=='__main__':
    main(*(Path(s).resolve() for s in sys.argv[1:]))
