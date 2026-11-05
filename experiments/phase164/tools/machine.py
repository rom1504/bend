#!/usr/bin/env python3
"""Build frozen QBE and use the maintained complete-result/count oracle."""
import argparse
import json
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
sys.path.insert(0, str(ROOT / 'selfhost/tools/bench'))
from common import pin, verify, require, run, write_json, fresh_output
import bench

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--emission', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--timing-rounds', type=int, default=0)
a = p.parse_args()
require(0 <= a.timing_rounds <= 6, 'Bounded timing rounds required')
data = json.loads(a.emission.read_text())
require(data['complete'], 'Incomplete emission')
out = fresh_output(a.out, ROOT)
report = dict(complete=False, inputs=[pin(__file__), pin(a.emission), pin(bench.__file__)],
              rows=[], scope='Frozen original IO programs. Same runtime/toolchain; exact '
              'independent value/count checks. Optional fixed native45 batches, not a broad score.')

def save():
    write_json(out / 'report.json', report)

def execute(image, point, stem, seconds):
    verify(image)
    argv = [image['file'], '--threads', '1', '--gpu', 'off', '--',
            str(point['repetitions']), str(point['warmups']), *map(str, point['runtimeArgs'])]
    job = run(argv, cwd=ROOT, stdout=out / (stem + '.stdout'),
              stderr=out / (stem + '.stderr'), seconds=seconds)
    require(job['complete'], 'Native process failed ' + stem)
    ms = bench.observation(Path(job['stdout']['file']).read_bytes(),
                           Path(job['stderr']['file']).read_bytes(), job['exitCode'],
                           point, job['seconds'])
    return dict(**job, internalMilliseconds=ms, point=point)

try:
    for index, case in enumerate(data['rows']):
        row = dict(name=case['name'], family=case['family'], complete=False,
                   products={}, samples=[], source=case['source'], expected=case['expected'])
        report['rows'].append(row)
        verify(case['source']); verify(case['expected'])
        report['inputs'] += [case['source'], case['expected']]
        for role in ['baseline', 'candidate']:
            ir = case['products'][role]['ir']; verify(ir); report['inputs'].append(ir)
            dest = out / (case['name'] + '-' + role)
            job = run([sys.executable, '-B', 'selfhost/tools/build/native.py', '--assets',
                       'selfhost/manifests/assets-native.json', '--ir', ir['file'],
                       '--target', 'qbe', '--out', str(dest), '--seconds', '45'], cwd=ROOT,
                      stdout=out / (dest.name + '.build.stdout'),
                      stderr=out / (dest.name + '.build.stderr'), seconds=50)
            require(job['complete'], 'Machine construction failed ' + dest.name)
            receipt = json.loads((dest / 'report.json').read_text())
            require(receipt['complete'], 'Incomplete machine receipt')
            image = receipt['binary']
            observed = execute(image, dict(case['point'], repetitions=1, warmups=0), dest.name + '.check', 15)
            row['products'][role] = dict(build=pin(dest / 'report.json'),
                                        buildSeconds=receipt['wallSeconds'], binary=image,
                                        execution=observed)
            save()
        for pair in range(a.timing_rounds):
            for role in (['baseline', 'candidate'] if (index + pair) % 2 == 0 else ['candidate', 'baseline']):
                observed = execute(row['products'][role]['binary'], case['point'],
                                   f'{index}-{pair}-{role}', 15)
                row['samples'].append(dict(role=role, pair=pair, **observed)); save()
        if a.timing_rounds:
            row['medianMilliseconds'] = {role: statistics.median(s['internalMilliseconds']
                for s in row['samples'] if s['role'] == role) for role in ['baseline', 'candidate']}
            row['runtimeRatio'] = (row['medianMilliseconds']['candidate'] /
                row['medianMilliseconds']['baseline']) if row['medianMilliseconds']['baseline'] else None
            row['resolved'] = min(row['medianMilliseconds'].values()) >= 100
        row['complete'] = True; save()
    report['inputs'].append(pin(ROOT / 'selfhost/tools/build/native.py'))
    report['complete'] = True
except Exception as error:
    report['error'] = str(error)
    raise
finally:
    save()
    print(json.dumps(dict(complete=report['complete'], rows=len(report['rows']), error=report.get('error'))))
