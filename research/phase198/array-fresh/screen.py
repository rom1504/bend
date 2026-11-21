"""Run the two-case source ceiling with the incumbent native compiler and C oracle."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'fusion'))
from screen import BUILD, checked_tool, execute, pin, read

CASES = ['variation-local-fold-128-0', 'local-fold']
ORIGINAL = ('def bench(+n: U32, seed: U32) -> U32:\n'
            '  fold.finish(fold.loop(U32.to_nat(n), 0, ([seed : U32*128n], 0)))')
INPUTS = [[0, 17], [1, 4294967295], [127, 31], [128, 17], [128, 4294967295],
          [129, 31], [130, 0], [257, 123], [4096, 17], [8192, 123]]

def recurrence(count, seed):
    acc = 0
    words = [seed] * 128
    for i in range(count):
        slot = i % 128
        acc = (acc + words[slot]) & 0xffffffff
        words[slot] = acc ^ i
    return str(acc) + '\n'

def run(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(parents=True)
    product_root = BUILD / 'phase198/native45-01'
    manifest = product_root / 'programs.manifest.json'
    rows = {r['id']:r for r in read(manifest)['cases']}
    replacement = HERE / 'project.bend'
    emitted = {'complete':False,'scope':'source ceiling','manifest':pin(manifest),'driver':pin(__file__),
               'projection':pin(replacement),'cases':[]}
    receipt = out / 'emission.json'
    for case in CASES:
        original = rows[case]
        source = Path(checked_tool(original['source']))
        text = source.read_text()
        assert text.count(ORIGINAL) == 1
        patched = text.replace(ORIGINAL, replacement.read_text().strip())
        assert patched.split('# Phase93:',1)[1] == text.split('# Phase93:',1)[1]
        folder = out / case
        folder.mkdir()
        source2 = folder / 'main.bend'
        source2.write_text(patched)
        obj = folder / 'program.o'
        auth = read(product_root / case / 'machine/report.json')
        assert auth['complete'] and auth['binary'] == original['products']['candidate']['artifact']
        argv = next(r['command'][:] for r in auth['jobs'] if r['label'] == 'compiler')
        argv[argv.index(str(source))] = str(source2.resolve())
        with obj.open('wb') as f:
            proc = subprocess.run(argv, stdout=f, stderr=subprocess.PIPE, timeout=30)
        (folder / 'compiler.stderr').write_bytes(proc.stderr)
        proc.check_returncode()
        assert obj.read_bytes()[:4] == b'\x7fELF'
        emitted['cases'].append({'id':case,'ordinary':original['source'],'source':pin(source2),'object':pin(obj),
                                 'compiler':auth['request']['image'],'argv':argv})
    emitted['complete'] = True
    receipt.write_text(json.dumps(emitted,indent=2)+'\n')
    measurement = HERE.parent / 'fusion/time-products.py'
    spec = importlib.util.spec_from_file_location('actual_products',measurement)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    timed = out / 'timing'
    module.run(SimpleNamespace(out=timed,emission=receipt,source_ceiling=True,reverse=False))
    result = read(timed / 'report.json')
    assert result['complete']
    reference = {r['id']:r for r in read(BUILD/'phase195/references01/manifest.json')['cases']}
    boundary = []
    for row in result['rows']:
        case = row['id']
        for count,seed in INPUTS:
            expected = recurrence(count,seed)
            checks = {}
            for role,binary in row['binaries'].items():
                ref = reference[case]['products']['c'] if role == 'c' else rows[case]['products']['candidate']
                checks[role] = execute(checked_tool(binary),[count,seed],0,0,expected,ref['runtimeArgumentConvention'])[0]
            boundary.append({'case':case,'count':count,'seed':seed,'expected':expected,'checks':checks})
    (out/'report.json').write_text(json.dumps({'complete':True,'emission':pin(receipt),'timing':pin(timed/'report.json'),
             'boundaryChecks':boundary},indent=2)+'\n')

if __name__ == '__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    run(p.parse_args().out.resolve())
