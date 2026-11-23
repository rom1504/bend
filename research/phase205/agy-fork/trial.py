"""Acquire a checked fork-only Phase205 compiler, emit actual objects and time both links."""
import json
import os
from pathlib import Path
import shutil
import resource
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'agy-runtime'))
import screen as S

def main(out, runtime_run):
    root, cc = S.ROOT, S.CC
    assert len(os.sched_getaffinity(0)) == 1
    pkg = root / 'selfhost/build/phase205/selected06'
    parent_src = pkg / 'compiler.bend'
    assert S.digest(parent_src) == 'd8d613fb2bf0363a48b662bb6a8c01df56c72328c03bd61d91c5fcbb04422abc'
    src = parent_src.read_text()
    anchor = '@unsafe\ndef p86_plan_annotated('
    old = 'u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))'
    assert src.count(anchor) == src.count(old) == 1
    out.mkdir(parents=True)
    source = out / 'compiler.bend'
    source.write_text(src.replace(old, 'u => agy_bf_plan(context,stops,verdict,annotated)').replace(
        anchor, (HERE / 'linearize.bend').read_text() + '\n' + anchor))
    exports = S.read(pkg / 'exports.json')
    exports['exports'] = ['p86_plan','p88_cache_prepare','x187_prepared','x198pw_plan']
    manifest = out / 'exports.json'
    manifest.write_text(json.dumps(exports))
    bun = root / 'selfhost/.assets/bin/bun'
    S.execute([bun, 'selfhost/tools/build/hosted.mjs', 'acquire', '--source', source, '--exports',
               manifest, '--out', out / 'api', '--engine', bun, '--upstream', 'selfhost/.bootstrap/upstream-phase182'])
    report = out / 'api/report.json'
    node = shutil.which('node') or '/home/ai/.nvm/versions/node/v24.22.1/bin/node'
    _, hard = resource.getrlimit(resource.RLIMIT_STACK)
    stack = 64 * 1024 * 1024
    resource.setrlimit(resource.RLIMIT_STACK, (stack if hard < 0 else min(stack, hard), hard))
    emit = root / 'research/phase205/native-unfold/object.mjs'
    port = runtime_run / 'runtime-opt.o'
    assert S.digest(port) == S.read(runtime_run / 'results.json')['candidateRuntime']
    catalog = {c['id']:c for c in S.read(S.BROAD/'timing/report.json')['cases']}
    rows = []
    for name in ('stride','mandelbrot','raytrace','variation-mandelbrot-grid-4-7','local-fold'):
        obj = out / (name + '.o')
        path = HERE/'stride.bend' if name == 'stride' else root / f'selfhost/tools/bench/catalogs/native45/fixtures/{name}.bend'
        S.execute([node, '--stack_size=32768', emit, report, path, obj])
        new = out / (name + '.fork')
        S.execute([cc,*S.FLAGS,obj,port,*S.LIBS,'-o',new])
        if name == 'stride':
            mask = (1<<32)-1
            want = ','.join(str(sum((((4294967287+i*7)**2 & mask)^37) for i in range(1<<d)) & mask) for d in [0,1,8])
            got = S.execute([new]).stdout.decode()
            assert got == want+'\n', (got,want)
            rows.append(dict(id=name,actual=got,object=S.digest(obj)))
        else:
            case = catalog[name]
            prior = S.read(S.BROAD/f'cases/{name}/candidate/build.json')
            old_obj = S.checked(prior['object'])
            parent = S.checked(prior['binary'])
            old_port = runtime_run / name
            assert S.digest(old_port) == next(x for x in S.read(runtime_run/'results.json')['cases'] if x['id']==name)['elf']['port']
            point, reps = case['point'], case['calibration']['candidate']
            paths = dict(parent=parent, runtime=old_port, both=new)
            samples = {role:[] for role in paths}
            for order in ('parent runtime both','both runtime parent','runtime both parent','parent both runtime','both parent runtime','runtime parent both'):
                for role in order.split():
                    samples[role].append(S.timed(paths[role],reps,point))
            rows.append(dict(id=name,parentObject=S.digest(old_obj),object=S.digest(obj),samples=samples,reps=reps))
        print(rows[-1],flush=True)
        (out/'results.json').write_text(json.dumps(rows,indent=2)+'\n')

if __name__ == '__main__':
    main(Path(sys.argv[1]).resolve(),Path(sys.argv[2]).resolve())
