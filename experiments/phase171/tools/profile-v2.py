#!/usr/bin/env python3
"""Separate immutable profile inputs from fresh guarded build products."""
import argparse
import copy
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
TOOLS = ROOT/'selfhost/tools/profiler'
sys.path.insert(0, str(TOOLS))
from run import pin, verify
from freeze import freeze
import attribute


def read(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    with Path(path).open('x') as stream:
        json.dump(data, stream, separators=(',', ':'))
        stream.write('\n')


def same(a, b):
    return all(a[k] == b[k] for k in ('bytes', 'sha256'))


def relocate(prep, products, output):
    assert not products.exists() and not output.exists()
    ready = read(prep/'ready.json'); original = verify(ready['plan']); old = read(original)
    plan = copy.deepcopy(old)
    assert [j['label'] for j in plan['jobs']] == ['stage-ordinal-sampler', 'compile-runtime', 'link-diagnostic']
    old_runtime = old['jobs'][1]['command'][old['jobs'][1]['command'].index('-o')+1]
    changes = []
    for job, name in zip(plan['jobs'], ['sampler.so', 'runtime.o', 'program']):
        cmd = job['command']; at = cmd.index('-o')+1
        changes.append(dict(label=job['label'], old=cmd[at], new=str(products/name)))
        cmd[at] = str(products/name)
    link = plan['jobs'][2]['command']
    assert link.count(old_runtime) == 1
    link[link.index(old_runtime)] = str(products/'runtime.o')
    plan['inputs'] += [pin(original), pin(__file__)]
    plan.update(originalPlan=pin(original), productsDirectory=str(products), relocation=changes,
                scope='Original three jobs; only three -o paths and linked runtime.o input relocated. Guarded wrapper creates fresh products directory.')
    save(output, plan)
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(output), productsDirectory=str(products))))


def build(plan_path, output):
    plan = read(plan_path)
    assert not output.exists()
    for row in plan['inputs'] + plan['outputs']:
        verify(row)
    products = Path(plan['productsDirectory'])
    assert products.is_absolute() and products.is_relative_to(ROOT/'selfhost/build/phase171') and not products.exists()
    products.mkdir()  # Executed only by root under the outer guard.
    subprocess.run([sys.executable, '-B', str(TOOLS/'build-runtime.py'), '--plan', str(plan_path), '--out', str(output)], check=True)


def manifests(prep, plan_path, built, output):
    assert not output.exists()
    ready, plan, report = read(prep/'ready.json'), read(plan_path), read(built)
    assert same(plan['originalPlan'], ready['plan']) and same(report['plan'], pin(plan_path)) and report['complete']
    for key in ('method', 'image', 'source', 'imageBuild', 'owners', 'spec', 'plan'):
        verify(ready[key])
    for row in plan['inputs'] + plan['outputs'] + report['products']:
        verify(row)
    products = {row['label']: row['product'] for row in report['jobs']}
    assert set(products) == {'stage-ordinal-sampler', 'compile-runtime', 'link-diagnostic'}
    binary = verify(products['link-diagnostic']); sampler = verify(products['stage-ordinal-sampler'])
    assert binary == Path(plan['productsDirectory'])/'program' and sampler == Path(plan['productsDirectory'])/'sampler.so'
    _, _, binding = attribute.bind_owners(read(prep/'owners.json'), binary)
    output.mkdir(parents=True)
    save(output/'diagnostic-elf.json', dict(complete=True, image=pin(binary), binding=binding, build=pin(built)))
    spec = read(prep/'spec.json')
    requests = dict(full=ROOT/'selfhost/build/phase170/native-chain-final/q3/report.json',
        pilot=ROOT/'selfhost/build/phase170/qbe64-final/27-test-map-set-ops/emission/report.json')
    for name, request_path in requests.items():
        request = read(request_path)
        assert request['complete'] and not request['changedInputs'] and same(request['image'], ready['image'])
        verify(request['product']); verify(request['process']['stderr'])
        command = list(request['process']['command']); command[0] = str(binary)
        recipe = dict(cwd=str(ROOT), sampler=str(sampler), unwindTable=spec['unwindTable']['file'],
            inputs=[str(prep/'ready.json'), str(prep/'spec.json'), str(prep/'owners.json'), str(built),
                    str(plan_path), str(request_path), str(output/'diagnostic-elf.json'), str(Path(__file__).resolve())],
            scope='Same retained object and original stage plan; relocated fresh build outputs. Counters disabled.',
            workloads=[dict(name=name, timeoutSeconds=300 if name=='full' else 45,
                variants=[dict(name='installed-n2-staged', command=command, dispatchInstrumentation=True,
                    inputs=[request[k]['file'] for k in ('source', 'base', 'preparedBase', 'imageRuntime')],
                    stdout=request['product']['file'], stderr=request['process']['stderr']['file'])])])
        save(output/(name+'-recipe.json'), recipe)
        save(output/(name+'-manifest.json'), freeze(recipe, output/(name+'-recipe.json')))
    print(json.dumps(dict(complete=True, targetsRun=False, manifests=[str(output/(n+'-manifest.json')) for n in requests])))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('operation', choices=['relocate', 'build', 'manifests'])
    p.add_argument('--prep', type=Path)
    p.add_argument('--products', type=Path)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path)
    p.add_argument('--build-report', type=Path)
    a = p.parse_args()
    if a.operation == 'relocate':
        relocate(a.prep.resolve(), a.products.resolve(), a.plan.resolve())
    elif a.operation == 'build':
        build(a.plan.resolve(), a.out.resolve())
    else:
        manifests(a.prep.resolve(), a.plan.resolve(), a.build_report.resolve(), a.out.resolve())
