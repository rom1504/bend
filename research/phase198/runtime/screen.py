"""Relink the same seven checked objects against isolated support libraries."""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'research/phase196/screen'))
from measure import checked_tool, execute

spec = importlib.util.spec_from_file_location('facts', HERE / 'bind-facts.py')
facts = importlib.util.module_from_spec(spec)
spec.loader.exec_module(facts)
FIXTURES = {'tree-bitonic': (3, 3), 'coverage-bst-64': (32, 0), 'lexer': (6, 17),
            'coverage-map-churn-128': (16, 17), 'coverage-expression-128': (32, 1),
            'test-rle-roundtrip': (1, 1), 'local-fold': (64, 17)}
ROLES = ['original', 'gcc3', 'clang3', 'facts', 'split']
BUILD = ROOT / 'selfhost/build'
SRC = ROOT / 'selfhost/src/runtime/qbe/runtime.c'


def read(p):
    return json.loads(Path(p).read_text())


def pin(p):
    p = Path(p)
    return {'file': str(p), 'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}


def run_cmd(command, seconds):
    start = time.monotonic()
    command = list(map(str, command))
    p = subprocess.run(command, capture_output=True, text=True, timeout=seconds)
    return {'argv': command, 'returncode': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr,
            'seconds': time.monotonic() - start}


def summarize(row, roles):
    baseline = row['byRole']['original']
    for role in roles:
        paired = [s['elapsedMs'] / b['elapsedMs'] for s,b in zip(row['byRole'][role], baseline)]
        row['stats'][role] = {'medianRatio': statistics.median(paired), 'paired': paired}


def main(args):
    assert os.sched_getaffinity(0) == {3}
    args.out.mkdir(parents=True)
    assert list(args.out.iterdir()) == []
    start = time.monotonic()
    assets_path = BUILD / 'phase194/assets.json'
    assets = read(assets_path)
    native = BUILD / 'phase195/native45-01/programs.manifest.json'
    reference = BUILD / 'phase195/references01/manifest.json'
    base = {c['id']: c for c in read(native)['cases']}
    ref = {c['id']: c for c in read(reference)['cases']}
    cc = checked_tool(assets['assets']['linker'])
    clang = checked_tool(assets['assets']['clang'])
    clang_headers = assets['toolchains']['c']['includeFlags'][-1]
    original = checked_tool(assets['assets']['qbe-runtime'])
    authority = read(BUILD / 'phase182/runtime-build02/report.json')
    assert pin(original)['sha256'] == authority['object']['sha256']
    assert any(i.get('sha256') == pin(SRC)['sha256'] for i in authority['inputs'])
    roles = list(ROLES)
    r = {'complete': False, 'pins': [pin(p) for p in [__file__,HERE/'bind-facts.py',HERE/'plan.md',
           SRC,SRC.with_name('runtime.h'),SRC.with_name('primitives.h'),native,reference,assets_path,cc,clang]],
         'builds': {}, 'refused': [], 'rows': [], 'reverse':args.reverse, 'rounds':args.rounds}
    save = lambda: (args.out/'report.json').write_text(json.dumps(r, indent=2)+'\n')
    save()
    objects = {}
    for role in list(roles):
        folder = args.out/role
        folder.mkdir()
        variant = 'original' if role in ['gcc3','clang3'] else role
        source = SRC
        if variant != 'original':
            source = folder / 'runtime.c'
            source.write_text(facts.variant(SRC.read_text(), variant))
        obj = folder/'runtime.o'
        cmd = [cc,'-O2' if role not in ['gcc3','clang3'] else '-O3']
        if role == 'clang3':
            cmd = [clang,'-O3','--target=x86_64-linux-gnu','--sysroot=/','-nostdinc',
                   '-isystem',clang_headers,'-isystem','/usr/include/x86_64-linux-gnu','-isystem','/usr/include']
        cmd += ['-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1','-I',SRC.parent,'-c',source,'-o',obj]
        proc = run_cmd(cmd,40)
        r['builds'][role] = {'source':pin(source),'compile':proc}
        save()
        if proc['returncode']:
            assert role == 'clang3', proc
            r['refused'].append(role)
            roles.remove(role)
            continue
        objects[role] = obj
        r['builds'][role]['object'] = pin(obj)
        if role == 'original':
            assert obj.read_bytes() == Path(original).read_bytes(), 'Incumbent object mismatch'
    for case, alternate in FIXTURES.items():
        c = base[case]; independent = ref[case]['products']['c']; point = c['point']
        assert c['source'] == ref[case]['source'] and c['expectedFile'] == ref[case]['expectedFile']
        product = c['products']['candidate']
        program_obj = checked_tool(product['generatedSource'])
        frozen_exe = checked_tool(product['artifact'])
        row = {'case':case,'source':c['source'],'programObject':pin(program_obj),'baseline':pin(frozen_exe),
               'binaries':{},'oracles':[],'links':{},'byRole':{k:[] for k in roles},'stats':{}}
        r['rows'].append(row)
        for role in roles:
            exe = args.out/role/case
            p = run_cmd([cc,*assets['toolchains']['x86']['linkerFlags'],program_obj,objects[role],
                         *assets['toolchains']['x86']['libraries'],'-o',exe],15)
            assert not p['returncode'], p
            row['links'][role] = p
            row['binaries'][role] = pin(exe)
            if role == 'original':
                assert exe.read_bytes() == Path(frozen_exe).read_bytes(), 'Qualification source/ELF mismatch'
        for idx,inputs in enumerate([point['runtimeArgs'],list(alternate)]):
            reps = int(idx == 0)
            oracle,value=execute(checked_tool(independent['artifact']),inputs,reps,0,
                                 point['expectedStdout'] if idx == 0 else None,independent['runtimeArgumentConvention'])
            matches={role:execute(row['binaries'][role]['file'],inputs,reps,0,value)[0] for role in roles}
            row['oracles'].append({'args':inputs,'c':oracle,'checks':matches})
        pilot=point['repetitions']
        row['pilots']=[]
        for _ in range(12):
            observed,_=execute(frozen_exe,point['runtimeArgs'],pilot,4,point['expectedStdout'])
            elapsed=observed['elapsedMs']
            row['pilots'].append({'repetitions':pilot,**observed})
            if 120<=elapsed<=380:break
            pilot=max(1,math.ceil(pilot*185/max(1,elapsed)))
        else:raise RuntimeError('calibration failed: '+case)
        row['repetitions']=pilot
        order = list(reversed(roles)) if args.reverse else roles[:]
        for n in range(args.rounds):
            shift = (n+len(r['rows'])) % len(order)
            for role in order[shift:] + order[:shift]:
                observed,_=execute(row['binaries'][role]['file'],point['runtimeArgs'],pilot,4,point['expectedStdout'])
                assert observed['elapsedMs'] >= 75, observed
                row['byRole'][role].append(observed)
        summarize(row,roles)
        save()
    r['complete']=True
    r['seconds']=time.monotonic()-start
    save()
    print('ratios',[(row['case'],{k:round(s['medianRatio'],3) for k,s in row['stats'].items()}) for row in r['rows']])

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=5)
    p.add_argument('--reverse',action='store_true')
    main(p.parse_args())
