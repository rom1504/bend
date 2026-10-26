"""Package exact dependency-closed verifier sources and root-owned native jobs.

This is source extraction and orchestration only. It does not run a checker,
compiler, generated program or machine tool.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('blocks', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
TOKEN = re.compile(r'\b[A-Za-z_][A-Za-z0-9_.]*\b')


def words(body):
    return set(TOKEN.findall(re.sub(r'"(?:\\.|[^"\\])*"|\#[^\n]*', ' ', body)))


def closure(blocks, roots):
    owners = {}
    for name, body in blocks.items():
        if body.startswith('type '):
            for ctor in re.findall(r'^\s+([A-Za-z0-9_.]+)\{', body, re.M):
                assert ctor not in owners
                owners[ctor] = name
    todo, seen = list(roots), set()
    while todo:
        name = todo.pop()
        if name in seen:
            continue
        seen.add(name)
        tokens = words(blocks[name])
        todo.extend(((tokens & set(blocks)) | {owners[x] for x in tokens & set(owners)}) - seen)
    return seen


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--slice', type=Path, required=True)
p.add_argument('--api', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
datum = json.loads(a.slice.read_text())
api = json.loads(a.api.read_text())
assert datum['complete'] and api['complete'] and api['checked']
source = next(x for x in api['inputs'] if x['file'].endswith('/compiler.bend'))
assert source['sha256'] == 'f74b34c50ce3b5e9065f4a0b77601fb7770debd56a8929c0d14c1ff8b29d1c86'
assert C.pin(source['file']) == source
selected_file = ROOT/'implementation/phase143/candidate.json'
selected = json.loads(selected_file.read_text())
assert selected['nativeQualified']
inputs = [C.pin(__file__), C.pin(C.__file__), C.pin(a.slice), C.pin(a.api), source,
          *datum['inputs'], *datum['files'], C.pin(selected_file), selected['native'],
          selected['runtime'], selected['preferredCarrierReceipt']]
for row in inputs:
    assert C.pin(row['file']) == row
original = C.blocks(Path(source['file']).read_text(), combine=True)
fixture = next(Path(x['file']) for x in datum['files'] if x['file'].endswith('/fixture.bend'))
workload = next(Path(x['file']) for x in datum['files'] if x['file'].endswith('/workload.bend'))
common = {**C.blocks(fixture.read_text(), combine=True), **C.blocks(workload.read_text(), combine=True)}
assert not (set(original) & set(common))
out.mkdir(parents=True)
variants, jobs = {}, []


def job(name, command, seconds, memory=3072):
    jobs.append(dict(name=name, seconds=seconds+20, command=[sys.executable, '-B',
        str(ROOT/'selfhost/tools/performance/phase111/guard.py'), '--out', str(out/(name+'-guard')),
        '--seconds', str(seconds), '--rss-mib', str(memory), '--available-mib', '16384',
        '--file-mib', '256', '--cpu', '3', '--', *map(str, command)]))


for mode in ['old', 'new']:
    entry = next(Path(x['file']) for x in datum['files'] if x['file'].endswith('/'+mode+'-main.bend'))
    extra = {**common, **C.blocks(entry.read_text(), combine=True)}
    blocks = {**original, **extra}
    needed = closure(blocks, ['main'])
    assert len(needed) < 500, 'Unexpected verifier dependency expansion'
    # Preserve exact declaration order/bodies from the checked API; test-only
    # producer/data declarations are appended in their original local order.
    text = 'import Base\n\n' + ''.join(body for name, body in original.items() if name in needed and name not in extra)
    text += '\n' + ''.join(body for name, body in extra.items() if name in needed)
    assert len(text.encode()) <= 1_000_000, 'Bounded fixture source cap'
    target = out/(mode+'.bend')
    target.write_text(text)
    expected = out/(mode+'.expected.stdout')
    expected.write_text(str(datum['expected'])+'\n')
    emission = ROOT/'selfhost/build/phase130'/('p144-'+out.name+'-'+mode+'-emit')
    build = ROOT/'selfhost/build/phase111'/('p144-'+out.name+'-'+mode+'-build')
    assert not emission.exists() and not build.exists()
    variants[mode] = dict(source=C.pin(target), expected=C.pin(expected), declarations=len(needed),
        originalDeclarations=[dict(name=n, sha256=C.hashlib.sha256(original[n].encode()).hexdigest())
            for n in original if n in needed and n not in extra],
        emission=str(emission/'report.json'), qbe=str(emission/'program.ssa'),
        build=str(build/'report.json'), binary=str(build/'program'))
    job(mode+'-emit', [sys.executable, '-B', ROOT/'selfhost/tools/performance/phase130/native-request.py',
        '--image', selected['native']['file'], '--source', target,
        '--carrier-receipt', selected['preferredCarrierReceipt']['file'], '--out', emission, '--seconds', '120'], 130)
    job(mode+'-build', [sys.executable, '-B', ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
        '--source', emission/'program.ssa', '--runtime', selected['runtime']['file'], '--out', build,
        '--expected', expected, '--seconds', '45'], 75)

manifest = dict(kind='phase144-extracted-native-verifier-plan', complete=True, checked=False, targetsRun=False,
    inputs=inputs, datum=datum, variants=variants, jobs=jobs,
    ordinary=dict(argv=['--threads','1','--gpu','off'], stdout=str(datum['expected'])+'\n', stderr='', exitCode=0),
    scope='Exact source/data extraction. Native original and candidate each build all real metadata tables, then full selected raw functions including schema/flow/joins and temporary-state reclamation. No warmed table reuse, lookup-only timer, full compiler image build or compiler speed claim. Source checking, ordinary execution and timing remain root-owned pending gates.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[C.pin(out/'manifest.json')],jobs=jobs),indent=2)+'\n')
print(json.dumps(dict(plan=C.pin(out/'jobs.json'),variants={k:dict(source=v['source'],declarations=v['declarations']) for k,v in variants.items()})))
